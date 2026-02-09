/**
 * Contract Negotiation Service
 * 
 * Implements EDC Contract Negotiation Protocol for dataspace interoperability.
 * Manages the state machine for contract negotiations between providers and consumers.
 * 
 * EDC Negotiation Flow:
 * 1. REQUESTED - Consumer initiates negotiation request
 * 2. OFFERED - Provider responds with contract offer
 * 3. ACCEPTED - Consumer accepts the offer
 * 4. AGREED - Both parties agree on terms
 * 5. VERIFIED - Contract terms are verified
 * 6. FINALIZED - Contract agreement is created and active
 * 
 * References:
 * - EDC Connector: https://github.com/eclipse-edc/Connector
 * - Dataspace Protocol: https://docs.internationaldataspaces.org/
 */

const { v4: uuidv4 } = require('uuid');

class ContractNegotiationService {
  constructor(pool) {
    this.pool = pool;
    this.protocol = 'dataspace-protocol-http';
  }

  /**
   * Initiate contract negotiation (Consumer side)
   * @param {string} assetId - Asset to negotiate for
   * @param {string} consumerId - Consumer connector ID
   * @param {string} providerId - Provider connector ID
   * @param {string} policyId - Policy to apply (optional)
   * @returns {Promise<Object>} Negotiation record
   */
  async initiateNegotiation(assetId, consumerId, providerId, policyId = null) {
    const negotiationId = `negotiation-${uuidv4()}`;
    
    console.log(`[Contract Negotiation] Initiating negotiation ${negotiationId}`);
    console.log(`[Contract Negotiation] Consumer: ${consumerId}, Provider: ${providerId}, Asset: ${assetId}`);

    // Validate asset exists and belongs to provider
    const assetCheck = await this.pool.query(`
      SELECT id, name, owner 
      FROM assets 
      WHERE id = $1
    `, [assetId]);

    if (assetCheck.rows.length === 0) {
      throw new Error(`Asset not found: ${assetId}`);
    }

    const asset = assetCheck.rows[0];
    
    if (asset.owner !== providerId) {
      throw new Error(`Asset ${assetId} is not owned by provider ${providerId}. Owner is: ${asset.owner}`);
    }

    // Check if there's already a finalized agreement
    const existingAgreement = await this.pool.query(`
      SELECT id 
      FROM contract_agreements 
      WHERE consumer_id = $1 
      AND asset_id = $2 
      AND state = 'FINALIZED'
      AND (end_date IS NULL OR end_date > CURRENT_TIMESTAMP)
    `, [consumerId, assetId]);

    if (existingAgreement.rows.length > 0) {
      throw new Error(`Active agreement already exists for asset ${assetId}`);
    }

    // Get policy from contract definition if not provided
    if (!policyId) {
      const policyResult = await this.pool.query(`
        SELECT cd.access_policy_id
        FROM contract_definitions cd
        JOIN contract_definition_assets cda ON cd.id = cda.contract_definition_id
        WHERE cda.asset_id = $1
        LIMIT 1
      `, [assetId]);

      if (policyResult.rows.length > 0) {
        policyId = policyResult.rows[0].access_policy_id;
      }
    }

    // Create negotiation record
    const result = await this.pool.query(`
      INSERT INTO contract_negotiations (
        id,
        counterparty_id,
        state,
        asset_id,
        provider_id,
        policy_id,
        protocol,
        created_at
      ) VALUES ($1, $2, 'REQUESTED', $3, $4, $5, $6, NOW())
      RETURNING *
    `, [negotiationId, consumerId, assetId, providerId, policyId, this.protocol]);

    console.log(`[Contract Negotiation] Created negotiation in REQUESTED state`);
    return result.rows[0];
  }

  /**
   * Provider responds with offer (Provider side)
   * @param {string} negotiationId - Negotiation identifier
   * @param {Object} terms - Contract terms (optional)
   * @returns {Promise<Object>} Updated negotiation
   */
  async offerContract(negotiationId, terms = {}) {
    console.log(`[Contract Negotiation] Provider offering contract for ${negotiationId}`);

    // Get negotiation
    const negotiation = await this.getNegotiation(negotiationId);

    if (negotiation.state !== 'REQUESTED') {
      throw new Error(`Invalid state transition: ${negotiation.state} -> OFFERED`);
    }

    // Create contract offer
    const offerId = `offer-${uuidv4()}`;
    await this.pool.query(`
      INSERT INTO contract_offers (
        id,
        negotiation_id,
        asset_id,
        policy_id,
        provider_id,
        terms,
        state,
        valid_until
      ) VALUES ($1, $2, $3, $4, $5, $6, 'PENDING', NOW() + INTERVAL '7 days')
    `, [
      offerId,
      negotiationId,
      negotiation.asset_id,
      negotiation.policy_id,
      negotiation.provider_id,
      JSON.stringify(terms)
    ]);

    // Update negotiation state
    const result = await this.pool.query(`
      UPDATE contract_negotiations
      SET state = 'OFFERED',
          contract_offer_id = $1,
          updated_at = NOW()
      WHERE id = $2
      RETURNING *
    `, [offerId, negotiationId]);

    console.log(`[Contract Negotiation] Contract offered, state: OFFERED`);
    return result.rows[0];
  }

  /**
   * Consumer accepts offer (Consumer side)
   * @param {string} negotiationId - Negotiation identifier
   * @returns {Promise<Object>} Updated negotiation
   */
  async acceptOffer(negotiationId) {
    console.log(`[Contract Negotiation] Consumer accepting offer for ${negotiationId}`);

    const negotiation = await this.getNegotiation(negotiationId);

    if (negotiation.state !== 'OFFERED') {
      throw new Error(`Invalid state transition: ${negotiation.state} -> ACCEPTED`);
    }

    // Update offer state
    if (negotiation.contract_offer_id) {
      await this.pool.query(`
        UPDATE contract_offers
        SET state = 'ACCEPTED'
        WHERE id = $1
      `, [negotiation.contract_offer_id]);
    }

    // Update negotiation state
    const result = await this.pool.query(`
      UPDATE contract_negotiations
      SET state = 'ACCEPTED',
          updated_at = NOW()
      WHERE id = $1
      RETURNING *
    `, [negotiationId]);

    console.log(`[Contract Negotiation] Offer accepted, state: ACCEPTED`);
    return result.rows[0];
  }

  /**
   * Both parties agree (automatic transition)
   * @param {string} negotiationId - Negotiation identifier
   * @returns {Promise<Object>} Updated negotiation
   */
  async agreeContract(negotiationId) {
    console.log(`[Contract Negotiation] Moving to AGREED state for ${negotiationId}`);

    const negotiation = await this.getNegotiation(negotiationId);

    if (negotiation.state !== 'ACCEPTED') {
      throw new Error(`Invalid state transition: ${negotiation.state} -> AGREED`);
    }

    const result = await this.pool.query(`
      UPDATE contract_negotiations
      SET state = 'AGREED',
          updated_at = NOW()
      WHERE id = $1
      RETURNING *
    `, [negotiationId]);

    console.log(`[Contract Negotiation] Contract agreed, state: AGREED`);
    return result.rows[0];
  }

  /**
   * Verify contract terms (automatic verification)
   * @param {string} negotiationId - Negotiation identifier
   * @returns {Promise<Object>} Updated negotiation
   */
  async verifyContract(negotiationId) {
    console.log(`[Contract Negotiation] Verifying contract for ${negotiationId}`);

    const negotiation = await this.getNegotiation(negotiationId);

    if (negotiation.state !== 'AGREED') {
      throw new Error(`Invalid state transition: ${negotiation.state} -> VERIFIED`);
    }

    const result = await this.pool.query(`
      UPDATE contract_negotiations
      SET state = 'VERIFIED',
          updated_at = NOW()
      WHERE id = $1
      RETURNING *
    `, [negotiationId]);

    console.log(`[Contract Negotiation] Contract verified, state: VERIFIED`);
    return result.rows[0];
  }

  /**
   * Finalize negotiation and create agreement
   * @param {string} negotiationId - Negotiation identifier
   * @param {Object} agreementTerms - Final agreement terms
   * @returns {Promise<Object>} Contract agreement
   */
  async finalizeNegotiation(negotiationId, agreementTerms = {}) {
    console.log(`[Contract Negotiation] Finalizing negotiation ${negotiationId}`);

    const negotiation = await this.getNegotiation(negotiationId);

    if (negotiation.state !== 'VERIFIED') {
      throw new Error(`Invalid state transition: ${negotiation.state} -> FINALIZED`);
    }

    // Create contract agreement
    const agreementId = `agreement-${uuidv4()}`;
    
    const agreement = await this.pool.query(`
      INSERT INTO contract_agreements (
        id,
        consumer_id,
        provider_id,
        asset_id,
        policy_id,
        negotiation_id,
        state,
        terms,
        signing_date,
        start_date
      ) VALUES ($1, $2, $3, $4, $5, $6, 'FINALIZED', $7, NOW(), NOW())
      RETURNING *
    `, [
      agreementId,
      negotiation.counterparty_id,
      negotiation.provider_id,
      negotiation.asset_id,
      negotiation.policy_id,
      negotiationId,
      JSON.stringify(agreementTerms)
    ]);

    // Update negotiation state
    await this.pool.query(`
      UPDATE contract_negotiations
      SET state = 'FINALIZED',
          contract_agreement_id = $1,
          finalized_at = NOW(),
          updated_at = NOW()
      WHERE id = $2
    `, [agreementId, negotiationId]);

    console.log(`[Contract Negotiation] Negotiation finalized, agreement created: ${agreementId}`);
    return agreement.rows[0];
  }

  /**
   * Complete negotiation flow in one step (for simplified demo)
   * @param {string} assetId - Asset to negotiate for
   * @param {string} consumerId - Consumer connector ID
   * @param {string} providerId - Provider connector ID
   * @returns {Promise<Object>} Final contract agreement
   */
  async completeNegotiation(assetId, consumerId, providerId) {
    console.log(`[Contract Negotiation] Starting complete negotiation flow`);
    console.log(`[Contract Negotiation] Asset: ${assetId}, Consumer: ${consumerId}, Provider: ${providerId}`);

    // Step 1: Initiate
    const negotiation = await this.initiateNegotiation(assetId, consumerId, providerId);
    
    // Step 2: Offer
    await this.offerContract(negotiation.id, { duration: 'unlimited' });
    
    // Step 3: Accept
    await this.acceptOffer(negotiation.id);
    
    // Step 4: Agree
    await this.agreeContract(negotiation.id);
    
    // Step 5: Verify
    await this.verifyContract(negotiation.id);
    
    // Step 6: Finalize
    const agreement = await this.finalizeNegotiation(negotiation.id, {
      access_type: 'execution',
      unlimited: true
    });

    console.log(`[Contract Negotiation] Complete flow finished successfully`);
    return agreement;
  }

  /**
   * Get negotiation by ID
   * @param {string} negotiationId - Negotiation identifier
   * @returns {Promise<Object>} Negotiation record
   */
  async getNegotiation(negotiationId) {
    const result = await this.pool.query(`
      SELECT cn.*, a.name as asset_name, a.owner as asset_owner
      FROM contract_negotiations cn
      LEFT JOIN assets a ON cn.asset_id = a.id
      WHERE cn.id = $1
    `, [negotiationId]);

    if (result.rows.length === 0) {
      throw new Error(`Negotiation not found: ${negotiationId}`);
    }

    return result.rows[0];
  }

  /**
   * Get all negotiations for a consumer
   * @param {string} consumerId - Consumer connector ID
   * @returns {Promise<Array>} List of negotiations
   */
  async getNegotiationsForConsumer(consumerId) {
    const result = await this.pool.query(`
      SELECT cn.*, a.name as asset_name, a.owner as asset_owner
      FROM contract_negotiations cn
      LEFT JOIN assets a ON cn.asset_id = a.id
      WHERE cn.counterparty_id = $1
      ORDER BY cn.created_at DESC
    `, [consumerId]);

    return result.rows;
  }

  /**
   * Get all negotiations (for unauthenticated access)
   * @returns {Promise<Array>} List of all negotiations
   */
  async getAllNegotiations() {
    const result = await this.pool.query(`
      SELECT cn.*, a.name as asset_name, a.owner as asset_owner
      FROM contract_negotiations cn
      LEFT JOIN assets a ON cn.asset_id = a.id
      ORDER BY cn.created_at DESC
    `);

    return result.rows;
  }

  /**
   * Get all negotiations for a provider
   * @param {string} providerId - Provider connector ID
   * @returns {Promise<Array>} List of negotiations
   */
  async getNegotiationsForProvider(providerId) {
    const result = await this.pool.query(`
      SELECT cn.*, a.name as asset_name
      FROM contract_negotiations cn
      LEFT JOIN assets a ON cn.asset_id = a.id
      WHERE cn.provider_id = $1
      ORDER BY cn.created_at DESC
    `, [providerId]);

    return result.rows;
  }

  /**
   * Get contract agreement by ID
   * @param {string} agreementId - Agreement identifier
   * @returns {Promise<Object>} Agreement record
   */
  async getAgreement(agreementId) {
    const result = await this.pool.query(`
      SELECT ca.*, a.name as asset_name
      FROM contract_agreements ca
      LEFT JOIN assets a ON ca.asset_id = a.id
      WHERE ca.id = $1
    `, [agreementId]);

    if (result.rows.length === 0) {
      throw new Error(`Agreement not found: ${agreementId}`);
    }

    return result.rows[0];
  }

  /**
   * Get all active agreements for a consumer
   * @param {string} consumerId - Consumer connector ID
   * @returns {Promise<Array>} List of agreements
   */
  async getAgreementsForConsumer(consumerId) {
    const result = await this.pool.query(`
      SELECT ca.*, a.name as asset_name, a.owner as provider_id
      FROM contract_agreements ca
      LEFT JOIN assets a ON ca.asset_id = a.id
      WHERE ca.consumer_id = $1
      AND ca.state = 'FINALIZED'
      AND (ca.end_date IS NULL OR ca.end_date > CURRENT_TIMESTAMP)
      ORDER BY ca.created_at DESC
    `, [consumerId]);

    return result.rows;
  }

  /**
   * Check if consumer has valid agreement for asset
   * @param {string} consumerId - Consumer connector ID
   * @param {string} assetId - Asset identifier
   * @returns {Promise<boolean>} True if valid agreement exists
   */
  async hasValidAgreement(consumerId, assetId) {
    const result = await this.pool.query(`
      SELECT has_valid_agreement($1, $2) as has_agreement
    `, [consumerId, assetId]);

    return result.rows[0].has_agreement;
  }

  /**
   * Terminate negotiation
   * @param {string} negotiationId - Negotiation identifier
   * @param {string} reason - Termination reason
   * @returns {Promise<Object>} Updated negotiation
   */
  async terminateNegotiation(negotiationId, reason = 'Terminated by user') {
    console.log(`[Contract Negotiation] Terminating negotiation ${negotiationId}: ${reason}`);

    const result = await this.pool.query(`
      UPDATE contract_negotiations
      SET state = 'TERMINATED',
          error_detail = $1,
          updated_at = NOW()
      WHERE id = $2
      RETURNING *
    `, [reason, negotiationId]);

    return result.rows[0];
  }

  /**
   * Auto-complete negotiation for local testing
   * Simulates the full EDC negotiation flow instantly
   * @param {string} negotiationId - Negotiation identifier
   * @param {string} assetId - Asset identifier
   * @param {string} providerId - Provider connector ID
   * @param {string} policyId - Policy identifier
   * @returns {Promise<void>}
   */
  async autoCompleteNegotiation(negotiationId, assetId, providerId, policyId) {
    console.log(`[Contract Negotiation] 🤖 AUTO-COMPLETING negotiation ${negotiationId}`);
    
    // Step 1: REQUESTED → FINALIZED (skip intermediate steps for local testing)
    await this.pool.query(`
      UPDATE contract_negotiations
      SET state = 'FINALIZED',
          updated_at = NOW()
      WHERE id = $1
    `, [negotiationId]);
    
    console.log(`[Contract Negotiation] ✓ Updated state to FINALIZED`);

    // Step 2: Create contract agreement
    const agreementId = `agreement-${uuidv4()}`;
    const consumerResult = await this.pool.query(`
      SELECT counterparty_id FROM contract_negotiations WHERE id = $1
    `, [negotiationId]);
    
    const consumerId = consumerResult.rows[0].counterparty_id;
    
    await this.pool.query(`
      INSERT INTO contract_agreements (
        id,
        negotiation_id,
        consumer_id,
        provider_id,
        asset_id,
        policy_id,
        state,
        start_date,
        signing_date,
        created_at
      ) VALUES ($1, $2, $3, $4, $5, $6, 'FINALIZED', NOW(), NOW(), NOW())
    `, [agreementId, negotiationId, consumerId, providerId, assetId, policyId]);
    
    console.log(`[Contract Negotiation] ✓ Created agreement ${agreementId}`);
    console.log(`[Contract Negotiation] 🎉 Negotiation auto-completed successfully!`);
  }
}

module.exports = { ContractNegotiationService };
