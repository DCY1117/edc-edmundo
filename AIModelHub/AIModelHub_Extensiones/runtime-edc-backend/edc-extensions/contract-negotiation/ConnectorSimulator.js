/**
 * Connector Simulator - Remote EDC Connector Emulation
 * 
 * Simulates a remote EDC connector that can act as Provider or Consumer.
 * Enables testing of full contract negotiation flow between two connectors
 * without requiring actual EDC infrastructure.
 * 
 * Features:
 * - Automatic response to negotiation requests
 * - Configurable behavior (auto-accept, delay, rejection scenarios)
 * - EDC Dataspace Protocol compatibility
 * - Multi-connector support (simulate multiple participants)
 */

const { v4: uuidv4 } = require('uuid');

class ConnectorSimulator {
  constructor(pool) {
    this.pool = pool;
    this.connectors = new Map();
    this.negotiationHandlers = new Map();
    this.autoNegotiate = true; // Auto-respond to negotiations
    this.responseDelay = 2000; // Simulate network delay (ms)
  }

  /**
   * Register a simulated remote connector
   * @param {Object} config - Connector configuration
   * @returns {string} Connector ID
   */
  registerConnector(config) {
    const connectorId = config.id || `sim-connector-${uuidv4()}`;
    
    const connector = {
      id: connectorId,
      name: config.name || `Simulated Connector ${connectorId}`,
      endpoint: config.endpoint || `http://localhost:9000/dsp/${connectorId}`,
      behavior: config.behavior || 'auto-accept', // auto-accept, auto-reject, manual
      assets: config.assets || [],
      policies: config.policies || [],
      responseTime: config.responseTime || this.responseDelay,
      isActive: true,
      createdAt: new Date()
    };

    this.connectors.set(connectorId, connector);
    console.log(`[Connector Simulator] Registered: ${connectorId} (${connector.behavior})`);
    
    return connectorId;
  }

  /**
   * Get all registered simulated connectors
   */
  getConnectors() {
    return Array.from(this.connectors.values());
  }

  /**
   * Get specific connector
   */
  getConnector(connectorId) {
    return this.connectors.get(connectorId);
  }

  /**
   * Simulate Provider response to negotiation request
   * Called automatically when a negotiation is initiated
   */
  async handleNegotiationRequest(negotiationId, negotiationData) {
    const providerId = negotiationData.provider_id;
    const connector = this.connectors.get(providerId);

    if (!connector) {
      console.log(`[Connector Simulator] Provider ${providerId} not simulated, skipping auto-response`);
      return null;
    }

    if (!connector.isActive) {
      console.log(`[Connector Simulator] Provider ${providerId} is inactive`);
      return null;
    }

    console.log(`[Connector Simulator] ${providerId} received negotiation request ${negotiationId}`);
    console.log(`[Connector Simulator] Behavior: ${connector.behavior}`);

    // Simulate network delay
    await this.delay(connector.responseTime);

    switch (connector.behavior) {
      case 'auto-accept':
        return await this.autoAcceptNegotiation(negotiationId, negotiationData);
      
      case 'auto-reject':
        return await this.autoRejectNegotiation(negotiationId, negotiationData);
      
      case 'auto-offer':
        return await this.autoOfferContract(negotiationId, negotiationData);
      
      case 'slow-accept':
        await this.delay(5000); // Extra delay
        return await this.autoAcceptNegotiation(negotiationId, negotiationData);
      
      case 'manual':
        console.log(`[Connector Simulator] ${providerId} waiting for manual action`);
        return { status: 'pending', message: 'Waiting for manual action' };
      
      default:
        return await this.autoOfferContract(negotiationId, negotiationData);
    }
  }

  /**
   * Auto-accept negotiation (Provider side)
   * Moves negotiation through: REQUESTED → OFFERED → AGREED → FINALIZED
   */
  async autoAcceptNegotiation(negotiationId, negotiationData) {
    console.log(`[Connector Simulator] Auto-accepting negotiation ${negotiationId}`);

    try {
      // Step 1: Provider offers contract
      const offerId = `offer-${uuidv4()}`;
      await this.pool.query(`
        UPDATE contract_negotiations
        SET state = 'OFFERED',
            contract_offer_id = $1,
            updated_at = NOW()
        WHERE id = $2
      `, [offerId, negotiationId]);

      console.log(`[Connector Simulator] State: REQUESTED → OFFERED`);
      await this.delay(1000);

      // Step 2: Consumer (simulated) accepts
      await this.pool.query(`
        UPDATE contract_negotiations
        SET state = 'ACCEPTED',
            updated_at = NOW()
        WHERE id = $1
      `, [negotiationId]);

      console.log(`[Connector Simulator] State: OFFERED → ACCEPTED`);
      await this.delay(1000);

      // Step 3: Provider agrees
      await this.pool.query(`
        UPDATE contract_negotiations
        SET state = 'AGREED',
            updated_at = NOW()
        WHERE id = $1
      `, [negotiationId]);

      console.log(`[Connector Simulator] State: ACCEPTED → AGREED`);
      await this.delay(1000);

      // Step 4: Finalize and create agreement
      const agreementId = `agreement-${uuidv4()}`;
      
      await this.pool.query(`
        INSERT INTO contract_agreements (
          id,
          asset_id,
          provider_id,
          consumer_id,
          policy_id,
          state,
          signing_date,
          start_date,
          created_at
        )
        SELECT 
          $1,
          asset_id,
          provider_id,
          counterparty_id,
          policy_id,
          'FINALIZED',
          NOW(),
          NOW(),
          NOW()
        FROM contract_negotiations
        WHERE id = $2
      `, [agreementId, negotiationId]);

      await this.pool.query(`
        UPDATE contract_negotiations
        SET state = 'FINALIZED',
            contract_agreement_id = $1,
            finalized_at = NOW(),
            updated_at = NOW()
        WHERE id = $2
      `, [agreementId, negotiationId]);

      console.log(`[Connector Simulator] State: AGREED → FINALIZED`);
      console.log(`[Connector Simulator] Agreement created: ${agreementId}`);

      return {
        status: 'success',
        negotiationId,
        agreementId,
        finalState: 'FINALIZED'
      };

    } catch (error) {
      console.error(`[Connector Simulator] Error in auto-accept:`, error);
      throw error;
    }
  }

  /**
   * Auto-reject negotiation (Provider side)
   */
  async autoRejectNegotiation(negotiationId, negotiationData) {
    console.log(`[Connector Simulator] Auto-rejecting negotiation ${negotiationId}`);

    await this.pool.query(`
      UPDATE contract_negotiations
      SET state = 'DECLINED',
          error_detail = 'Provider declined the negotiation request',
          finalized_at = NOW()
      WHERE id = $1
    `, [negotiationId]);

    return {
      status: 'rejected',
      negotiationId,
      finalState: 'DECLINED',
      reason: 'Provider declined the negotiation request'
    };
  }

  /**
   * Offer contract (Provider side) - waits for consumer acceptance
   */
  async autoOfferContract(negotiationId, negotiationData) {
    console.log(`[Connector Simulator] Offering contract for negotiation ${negotiationId}`);

    const offerId = `offer-${uuidv4()}`;

    await this.pool.query(`
      UPDATE contract_negotiations
      SET state = 'OFFERED',
          provider_offer_id = $1,
          provider_offered_at = NOW()
      WHERE id = $2
    `, [offerId, negotiationId]);

    return {
      status: 'offered',
      negotiationId,
      offerId,
      currentState: 'OFFERED',
      message: 'Contract offered, waiting for consumer acceptance'
    };
  }

  /**
   * Simulate Consumer accepting an offer
   */
  async consumerAcceptOffer(negotiationId) {
    console.log(`[Connector Simulator] Consumer accepting offer ${negotiationId}`);

    await this.delay(this.responseDelay);

    await this.pool.query(`
      UPDATE contract_negotiations
      SET state = 'ACCEPTED',
          consumer_accepted_at = NOW()
      WHERE id = $1
    `, [negotiationId]);

    // If auto-negotiate is on, continue the flow
    if (this.autoNegotiate) {
      await this.delay(1000);
      await this.providerAgreeToContract(negotiationId);
    }

    return { status: 'accepted', negotiationId };
  }

  /**
   * Provider agrees to accepted contract
   */
  async providerAgreeToContract(negotiationId) {
    console.log(`[Connector Simulator] Provider agreeing to contract ${negotiationId}`);

    await this.pool.query(`
      UPDATE contract_negotiations
      SET state = 'AGREED',
          provider_agreed_at = NOW()
      WHERE id = $1
    `, [negotiationId]);

    // Auto-finalize
    if (this.autoNegotiate) {
      await this.delay(1000);
      await this.finalizeAgreement(negotiationId);
    }

    return { status: 'agreed', negotiationId };
  }

  /**
   * Finalize agreement
   */
  async finalizeAgreement(negotiationId) {
    console.log(`[Connector Simulator] Finalizing agreement for ${negotiationId}`);

    const agreementId = `agreement-${uuidv4()}`;

    // Create agreement
    await this.pool.query(`
      INSERT INTO contract_agreements (
        id,
        asset_id,
        provider_id,
        consumer_id,
        policy_id,
        state,
        signing_date,
        start_date,
        created_at
      )
      SELECT 
        $1,
        asset_id,
        provider_id,
        counterparty_id,
        policy_id,
        'FINALIZED',
        NOW(),
        NOW(),
        NOW()
      FROM contract_negotiations
      WHERE id = $2
    `, [agreementId, negotiationId]);

    // Update negotiation
    await this.pool.query(`
      UPDATE contract_negotiations
      SET state = 'FINALIZED',
          agreement_id = $1,
          finalized_at = NOW()
      WHERE id = $2
    `, [agreementId, negotiationId]);

    return { status: 'finalized', negotiationId, agreementId };
  }

  /**
   * Start automated negotiation flow
   * Listens for new negotiations and responds automatically
   */
  startAutoNegotiationListener() {
    console.log('[Connector Simulator] Starting auto-negotiation listener');
    
    // Poll for REQUESTED negotiations every 2 seconds
    setInterval(async () => {
      try {
        const result = await this.pool.query(`
          SELECT * FROM contract_negotiations
          WHERE state = 'REQUESTED'
          ORDER BY created_at ASC
        `);

        for (const negotiation of result.rows) {
          // Check if provider is simulated
          if (this.connectors.has(negotiation.provider_id)) {
            await this.handleNegotiationRequest(negotiation.id, negotiation);
          }
        }
      } catch (error) {
        console.error('[Connector Simulator] Error in auto-negotiation listener:', error);
      }
    }, 2000);
  }

  /**
   * Utility: Delay helper
   */
  delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  /**
   * Get negotiation statistics for a connector
   */
  async getConnectorStats(connectorId) {
    const result = await this.pool.query(`
      SELECT 
        state,
        COUNT(*) as count
      FROM contract_negotiations
      WHERE provider_id = $1 OR counterparty_id = $1
      GROUP BY state
    `, [connectorId]);

    return result.rows.reduce((acc, row) => {
      acc[row.state] = parseInt(row.count);
      return acc;
    }, {});
  }

  /**
   * Reset all simulated connectors
   */
  reset() {
    this.connectors.clear();
    console.log('[Connector Simulator] All connectors cleared');
  }
}

module.exports = { ConnectorSimulator };
