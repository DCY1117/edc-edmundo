/**
 * Contract Negotiation Extension
 * 
 * EDC-compatible extension for managing contract negotiations and agreements.
 * Implements the Dataspace Protocol for contract negotiation between connectors.
 * 
 * Endpoints (EDC Protocol Compliant):
 * - POST /v3/contractnegotiations - Initiate negotiation
 * - GET /v3/contractnegotiations/:id - Get negotiation status
 * - GET /v3/contractnegotiations - List all negotiations
 * - POST /v3/contractnegotiations/:id/request - Request contract (consumer)
 * - POST /v3/contractnegotiations/:id/offer - Offer contract (provider)
 * - POST /v3/contractnegotiations/:id/accept - Accept offer (consumer)
 * - POST /v3/contractnegotiations/:id/finalize - Finalize agreement
 * - POST /v3/contractnegotiations/complete - Complete full flow (simplified)
 * - GET /v3/contractagreements - List agreements
 * - GET /v3/contractagreements/:id - Get agreement details
 * 
 * EDC References:
 * - Management API: https://eclipse-edc.github.io/docs/#/submodule/Connector/docs/developer/management-api
 * - Contract Negotiation: https://github.com/eclipse-edc/Connector/tree/main/spi/control-plane/contract-spi
 */

const { ExtensionManifest } = require('../core/ExtensionManifest');
const express = require('express');
const { authenticateToken, optionalAuth } = require('../../src/middleware/auth');
const { ContractNegotiationService } = require('./NegotiationService');
const { ConnectorSimulator } = require('./ConnectorSimulator');

module.exports = new ExtensionManifest({
  name: 'contract-negotiation-extension',
  version: '1.0.0',
  description: 'EDC Contract Negotiation Protocol implementation',
  provides: ['ContractNegotiationAPI'],
  requires: ['DatabasePool'],
  
  initialize: async (context) => {
    console.log('[Contract Negotiation Extension] Initializing...');
    
    const pool = context.getService('DatabasePool');
    const negotiationService = new ContractNegotiationService(pool);
    const connectorSimulator = new ConnectorSimulator(pool);
    
    // Register services
    context.registerService('ContractNegotiationService', negotiationService);
    context.registerService('ConnectorSimulator', connectorSimulator);
    
    // Start auto-negotiation listener for simulated connectors
    connectorSimulator.startAutoNegotiationListener();
    
    // Register simulated connectors based on users in the database
    try {
      const usersResult = await pool.query('SELECT id, username, connector_id, display_name FROM users ORDER BY id');
      
      for (const user of usersResult.rows) {
        connectorSimulator.registerConnector({
          id: user.connector_id,
          name: user.display_name || user.username,
          behavior: 'auto-accept',
          responseTime: 2000
        });
      }
      
      console.log(`[Contract Negotiation Extension] Registered ${usersResult.rows.length} connectors from users`);
    } catch (error) {
      console.error('[Contract Negotiation Extension] Error loading users for connectors:', error.message);
      
      // Fallback to default connectors if database query fails
      connectorSimulator.registerConnector({
        id: 'conn-user1-demo',
        name: 'User 1 Demo Connector',
        behavior: 'auto-accept',
        responseTime: 2000
      });
      
      connectorSimulator.registerConnector({
        id: 'conn-user2-demo',
        name: 'User 2 Demo Connector',
        behavior: 'auto-accept',
        responseTime: 2000
      });
      
      console.log('[Contract Negotiation Extension] Registered 2 fallback connectors');
    }
    
    // Create Express router
    const router = express.Router();
    
    // CORS preflight
    router.options('*', (req, res) => {
      res.status(204).end();
    });

    // ==================== NEGOTIATION ENDPOINTS ====================

    /**
     * POST /v3/contractnegotiations
     * Initiate a new contract negotiation
     * 
     * Supports two formats:
     * 1. Simple format:
     * {
     *   "assetId": "asset-id-123",
     *   "providerId": "conn-provider-demo",
     *   "policyId": "policy-id-001" (optional)
     * }
     * 
     * 2. EDC format:
     * {
     *   "@context": {...},
     *   "@type": "ContractRequest",
     *   "counterPartyAddress": "http://provider-url",
     *   "protocol": "dataspace-protocol-http",
     *   "policy": {
     *     "@id": "offer-id",
     *     "@type": "Offer",
     *     "assigner": "provider-id",
     *     "target": "asset-id"
     *   }
     * }
     */
    router.post('/v3/contractnegotiations', authenticateToken, async (req, res) => {
      try {
        let assetId, providerId, policyId;
        const consumerId = req.user.connectorId;

        // Check if it's EDC format (has counterPartyAddress and policy)
        if (req.body.counterPartyAddress && req.body.policy) {
          console.log('[Contract Negotiation API] EDC format detected');
          
          // Extract data from EDC format
          const policy = req.body.policy;
          assetId = policy.target;
          
          // Extract provider ID from counterPartyAddress or assigner
          providerId = policy.assigner;
          
          // Use the policy ID
          policyId = policy['@id'];
          
          console.log('[Contract Negotiation API] Extracted from EDC format:');
          console.log(`  - assetId: ${assetId}`);
          console.log(`  - providerId: ${providerId}`);
          console.log(`  - policyId: ${policyId}`);
        } else {
          // Simple format
          console.log('[Contract Negotiation API] Simple format detected');
          ({ assetId, providerId, policyId } = req.body);
        }

        if (!assetId || !providerId) {
          return res.status(400).json({
            error: 'Bad Request',
            message: 'Missing required fields: assetId and providerId (or valid EDC format with policy.target and policy.assigner)'
          });
        }

        console.log(`[Contract Negotiation API] Initiating negotiation`);
        console.log(`[Contract Negotiation API] Consumer: ${consumerId}, Provider: ${providerId}`);
        console.log(`[Contract Negotiation API] Asset: ${assetId}`);

        const negotiation = await negotiationService.initiateNegotiation(
          assetId,
          consumerId,
          providerId,
          policyId
        );

        res.status(201).json(negotiation);

      } catch (error) {
        console.error('[Contract Negotiation API] Error:', error.message);
        res.status(500).json({
          error: 'Negotiation Error',
          message: error.message
        });
      }
    });

    /**
     * GET /v3/contractnegotiations/:id
     * Get negotiation status
     */
    router.get('/v3/contractnegotiations/:id', authenticateToken, async (req, res) => {
      try {
        const { id } = req.params;
        
        const negotiation = await negotiationService.getNegotiation(id);
        
        res.status(200).json(negotiation);

      } catch (error) {
        if (error.message.includes('not found')) {
          return res.status(404).json({
            error: 'Not Found',
            message: error.message
          });
        }
        
        console.error('[Contract Negotiation API] Error:', error.message);
        res.status(500).json({
          error: 'Server Error',
          message: error.message
        });
      }
    });

    /**
     * GET /v3/contractnegotiations
     * List all negotiations for the authenticated user
     * Query params:
     * - role: 'consumer' | 'provider' (default: both)
     */
    router.get('/v3/contractnegotiations', optionalAuth, async (req, res) => {
      try {
        // If no user, return all negotiations
        const connectorId = req.user?.connectorId;
        const role = req.query.role;

        let negotiations = [];

        if (!connectorId) {
          // No authentication - return all negotiations
          negotiations = await negotiationService.getAllNegotiations();
        } else {
          // Authenticated - filter by connector
          if (!role || role === 'consumer') {
            const consumerNegotiations = await negotiationService.getNegotiationsForConsumer(connectorId);
            negotiations = [...negotiations, ...consumerNegotiations.map(n => ({ ...n, role: 'consumer' }))];
          }

          if (!role || role === 'provider') {
            const providerNegotiations = await negotiationService.getNegotiationsForProvider(connectorId);
            negotiations = [...negotiations, ...providerNegotiations.map(n => ({ ...n, role: 'provider' }))];
          }
        }

        res.status(200).json({
          count: negotiations.length,
          negotiations
        });

      } catch (error) {
        console.error('[Contract Negotiation API] Error:', error.message);
        res.status(500).json({
          error: 'Server Error',
          message: error.message
        });
      }
    });

    /**
     * POST /v3/contractnegotiations/:id/offer
     * Provider offers contract
     */
    router.post('/v3/contractnegotiations/:id/offer', authenticateToken, async (req, res) => {
      try {
        const { id } = req.params;
        const { terms } = req.body;

        const negotiation = await negotiationService.offerContract(id, terms || {});

        res.status(200).json(negotiation);

      } catch (error) {
        console.error('[Contract Negotiation API] Error:', error.message);
        res.status(400).json({
          error: 'Negotiation Error',
          message: error.message
        });
      }
    });

    /**
     * POST /v3/contractnegotiations/:id/accept
     * Consumer accepts offer
     */
    router.post('/v3/contractnegotiations/:id/accept', authenticateToken, async (req, res) => {
      try {
        const { id } = req.params;

        const negotiation = await negotiationService.acceptOffer(id);

        res.status(200).json(negotiation);

      } catch (error) {
        console.error('[Contract Negotiation API] Error:', error.message);
        res.status(400).json({
          error: 'Negotiation Error',
          message: error.message
        });
      }
    });

    /**
     * POST /v3/contractnegotiations/:id/agree
     * Move to AGREED state
     */
    router.post('/v3/contractnegotiations/:id/agree', authenticateToken, async (req, res) => {
      try {
        const { id } = req.params;

        const negotiation = await negotiationService.agreeContract(id);

        res.status(200).json(negotiation);

      } catch (error) {
        console.error('[Contract Negotiation API] Error:', error.message);
        res.status(400).json({
          error: 'Negotiation Error',
          message: error.message
        });
      }
    });

    /**
     * POST /v3/contractnegotiations/:id/verify
     * Verify contract terms
     */
    router.post('/v3/contractnegotiations/:id/verify', authenticateToken, async (req, res) => {
      try {
        const { id } = req.params;

        const negotiation = await negotiationService.verifyContract(id);

        res.status(200).json(negotiation);

      } catch (error) {
        console.error('[Contract Negotiation API] Error:', error.message);
        res.status(400).json({
          error: 'Negotiation Error',
          message: error.message
        });
      }
    });

    /**
     * POST /v3/contractnegotiations/:id/finalize
     * Finalize negotiation and create agreement
     */
    router.post('/v3/contractnegotiations/:id/finalize', authenticateToken, async (req, res) => {
      try {
        const { id } = req.params;
        const { terms } = req.body;

        const agreement = await negotiationService.finalizeNegotiation(id, terms || {});

        res.status(200).json(agreement);

      } catch (error) {
        console.error('[Contract Negotiation API] Error:', error.message);
        res.status(400).json({
          error: 'Negotiation Error',
          message: error.message
        });
      }
    });

    /**
     * POST /v3/contractnegotiations/complete
     * Complete full negotiation flow in one step (simplified for demo)
     * 
     * Body:
     * {
     *   "assetId": "asset-id-123",
     *   "providerId": "conn-provider-demo"
     * }
     */
    router.post('/v3/contractnegotiations/complete', authenticateToken, async (req, res) => {
      try {
        const { assetId, providerId } = req.body;
        const consumerId = req.user.connectorId;

        if (!assetId || !providerId) {
          return res.status(400).json({
            error: 'Bad Request',
            message: 'Missing required fields: assetId, providerId'
          });
        }

        console.log(`[Contract Negotiation API] Starting complete negotiation flow`);
        console.log(`[Contract Negotiation API] Consumer: ${consumerId}, Provider: ${providerId}, Asset: ${assetId}`);

        const agreement = await negotiationService.completeNegotiation(
          assetId,
          consumerId,
          providerId
        );

        res.status(201).json({
          success: true,
          message: 'Contract negotiation completed successfully',
          agreement
        });

      } catch (error) {
        console.error('[Contract Negotiation API] Error:', error.message);
        res.status(500).json({
          error: 'Negotiation Error',
          message: error.message
        });
      }
    });

    /**
     * DELETE /v3/contractnegotiations/:id
     * Terminate negotiation
     */
    router.delete('/v3/contractnegotiations/:id', authenticateToken, async (req, res) => {
      try {
        const { id } = req.params;
        const { reason } = req.body;

        const negotiation = await negotiationService.terminateNegotiation(id, reason);

        res.status(200).json(negotiation);

      } catch (error) {
        console.error('[Contract Negotiation API] Error:', error.message);
        res.status(400).json({
          error: 'Negotiation Error',
          message: error.message
        });
      }
    });

    // ==================== AGREEMENT ENDPOINTS ====================

    /**
     * GET /v3/contractagreements
     * List all active agreements for the authenticated user
     */
    router.get('/v3/contractagreements', authenticateToken, async (req, res) => {
      try {
        const consumerId = req.user.connectorId;

        const agreements = await negotiationService.getAgreementsForConsumer(consumerId);

        res.status(200).json({
          count: agreements.length,
          agreements
        });

      } catch (error) {
        console.error('[Contract Negotiation API] Error:', error.message);
        res.status(500).json({
          error: 'Server Error',
          message: error.message
        });
      }
    });

    /**
     * GET /v3/contractagreements/:id
     * Get agreement details
     */
    router.get('/v3/contractagreements/:id', authenticateToken, async (req, res) => {
      try {
        const { id } = req.params;

        const agreement = await negotiationService.getAgreement(id);

        res.status(200).json(agreement);

      } catch (error) {
        if (error.message.includes('not found')) {
          return res.status(404).json({
            error: 'Not Found',
            message: error.message
          });
        }

        console.error('[Contract Negotiation API] Error:', error.message);
        res.status(500).json({
          error: 'Server Error',
          message: error.message
        });
      }
    });

    // ==================== CONNECTOR SIMULATOR ENDPOINTS ====================

    /**
     * GET /v3/simulator/connectors
     * List all simulated connectors
     */
    router.get('/v3/simulator/connectors', optionalAuth, async (req, res) => {
      try {
        const connectors = connectorSimulator.getConnectors();
        
        // Get stats for each connector
        const connectorsWithStats = await Promise.all(
          connectors.map(async (conn) => {
            const stats = await connectorSimulator.getConnectorStats(conn.id);
            return { ...conn, stats };
          })
        );

        res.status(200).json({
          count: connectorsWithStats.length,
          connectors: connectorsWithStats
        });

      } catch (error) {
        console.error('[Connector Simulator API] Error:', error.message);
        res.status(500).json({
          error: 'Server Error',
          message: error.message
        });
      }
    });

    /**
     * GET /v3/simulator/connectors/:id
     * Get specific simulated connector
     */
    router.get('/v3/simulator/connectors/:id', optionalAuth, async (req, res) => {
      try {
        const { id } = req.params;
        const connector = connectorSimulator.getConnector(id);

        if (!connector) {
          return res.status(404).json({
            error: 'Not Found',
            message: `Connector ${id} not found`
          });
        }

        const stats = await connectorSimulator.getConnectorStats(id);

        res.status(200).json({
          ...connector,
          stats
        });

      } catch (error) {
        console.error('[Connector Simulator API] Error:', error.message);
        res.status(500).json({
          error: 'Server Error',
          message: error.message
        });
      }
    });

    /**
     * POST /v3/simulator/connectors
     * Register a new simulated connector
     * 
     * Body:
     * {
     *   "id": "provider-connector-custom",
     *   "name": "Custom Provider",
     *   "behavior": "auto-accept",
     *   "responseTime": 2000
     * }
     */
    router.post('/v3/simulator/connectors', optionalAuth, async (req, res) => {
      try {
        const config = req.body;

        if (!config.name) {
          return res.status(400).json({
            error: 'Bad Request',
            message: 'Connector name is required'
          });
        }

        const connectorId = connectorSimulator.registerConnector(config);
        const connector = connectorSimulator.getConnector(connectorId);

        res.status(201).json({
          success: true,
          message: 'Connector registered successfully',
          connector
        });

      } catch (error) {
        console.error('[Connector Simulator API] Error:', error.message);
        res.status(500).json({
          error: 'Server Error',
          message: error.message
        });
      }
    });

    /**
     * POST /v3/simulator/connectors/:id/toggle
     * Activate/deactivate a simulated connector
     */
    router.post('/v3/simulator/connectors/:id/toggle', optionalAuth, async (req, res) => {
      try {
        const { id } = req.params;
        const connector = connectorSimulator.getConnector(id);

        if (!connector) {
          return res.status(404).json({
            error: 'Not Found',
            message: `Connector ${id} not found`
          });
        }

        connector.isActive = !connector.isActive;

        res.status(200).json({
          success: true,
          message: `Connector ${connector.isActive ? 'activated' : 'deactivated'}`,
          connector
        });

      } catch (error) {
        console.error('[Connector Simulator API] Error:', error.message);
        res.status(500).json({
          error: 'Server Error',
          message: error.message
        });
      }
    });

    /**
     * POST /v3/simulator/negotiate-demo
     * Run a complete demo negotiation between two simulated connectors
     * 
     * Body:
     * {
     *   "assetId": "asset-id-123",
     *   "consumerId": "user-conn-user1-demo",
     *   "providerId": "provider-connector-alpha"
     * }
     */
    router.post('/v3/simulator/negotiate-demo', optionalAuth, async (req, res) => {
      try {
        const { assetId, providerId } = req.body;
        const consumerId = req.user.connectorId;

        if (!assetId || !providerId) {
          return res.status(400).json({
            error: 'Bad Request',
            message: 'assetId and providerId are required'
          });
        }

        // Check if provider is simulated
        const provider = connectorSimulator.getConnector(providerId);
        if (!provider) {
          return res.status(400).json({
            error: 'Bad Request',
            message: `Provider ${providerId} is not a simulated connector. Available: ${
              connectorSimulator.getConnectors().map(c => c.id).join(', ')
            }`
          });
        }

        console.log(`[Connector Simulator API] Starting demo negotiation`);
        console.log(`[Connector Simulator API] Consumer: ${consumerId}`);
        console.log(`[Connector Simulator API] Provider: ${providerId} (${provider.behavior})`);

        // Initiate negotiation
        const negotiation = await negotiationService.initiateNegotiation(
          assetId,
          consumerId,
          providerId
        );

        // The simulator will automatically handle the rest based on provider behavior

        res.status(201).json({
          success: true,
          message: 'Demo negotiation started. Check status with GET /v3/contractnegotiations/:id',
          negotiation,
          provider: {
            id: provider.id,
            name: provider.name,
            behavior: provider.behavior,
            expectedOutcome: provider.behavior === 'auto-reject' ? 'Will be declined' : 'Will be accepted'
          }
        });

      } catch (error) {
        console.error('[Connector Simulator API] Error:', error.message);
        res.status(500).json({
          error: 'Server Error',
          message: error.message
        });
      }
    });

    // Register router as a service so it can be mounted by the server
    context.registerService('ContractNegotiationRouter', router);
    
    console.log('[Contract Negotiation Extension] Initialized successfully');
    console.log('[Contract Negotiation Extension] Endpoints available:');
    console.log('  - POST   /v3/contractnegotiations');
    console.log('  - GET    /v3/contractnegotiations');
    console.log('  - GET    /v3/contractnegotiations/:id');
    console.log('  - POST   /v3/contractnegotiations/complete');
    console.log('  - GET    /v3/contractagreements');
    console.log('  - GET    /v3/contractagreements/:id');
    console.log('  - GET    /v3/simulator/connectors');
    console.log('  - POST   /v3/simulator/connectors');
    console.log('  - POST   /v3/simulator/negotiate-demo');
    
    return { negotiationService, connectorSimulator };
  }
});
