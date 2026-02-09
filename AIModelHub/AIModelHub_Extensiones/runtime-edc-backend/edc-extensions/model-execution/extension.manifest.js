/**
 * Model Execution Extension
 * 
 * EDC extension that provides model execution capabilities through HTTP invocation.
 * Simulates EDC Connector behavior for executing AI models registered as assets.
 * 
 * Endpoints:
 * - POST /v3/models/execute - Execute a model by assetId
 * - GET /v3/models/executions/:id - Get execution status
 * - GET /v3/models/executions - List executions for an asset
 * - GET /v3/models/executable - List all executable assets
 * 
 * EDC Equivalent: Custom extension (no direct EDC equivalent)
 */

const { ExtensionManifest } = require('../core/ExtensionManifest');
const express = require('express');
const { authenticateToken, optionalAuth } = require('../../src/middleware/auth');
const { ExecutionService } = require('./ExecutionService');

module.exports = new ExtensionManifest({
  name: 'model-execution-extension',
  version: '1.0.0',
  description: 'HTTP invocation service for executable AI models',
  provides: ['ModelExecutionAPI'],
  requires: ['DatabasePool'],
  
  initialize: async (context) => {
    console.log('[Model Execution Extension] Initializing...');
    
    const pool = context.getService('DatabasePool');
    const executionService = new ExecutionService(pool);
    
    // Register service in context for other extensions
    context.registerService('ExecutionService', executionService);
    
    // Create Express router for Execution API
    const router = express.Router();
    
    // CORS preflight handler
    router.options('*', (req, res) => {
      res.status(204).end();
    });
    
    // ==================== EXECUTION ENDPOINTS ====================
    
    /**
     * POST /v3/models/execute
     * Execute a model by assetId
     * 
     * Request body:
     * {
     *   "assetId": "asset-id-123",
     *   "input": { ... model input data ... },
     *   "options": {
     *     "timeout": 60000,  // optional
     *     "headers": {}      // optional
     *   }
     * }
     * 
     * Response:
     * {
     *   "executionId": "exec-uuid",
     *   "status": "success" | "error" | "timeout",
     *   "assetId": "asset-id-123",
     *   "assetName": "Model Name",
     *   "output": { ... model output ... },  // on success
     *   "error": { ... error details ... },   // on error
     *   "executionTimeMs": 1234,
     *   "timestamp": "2026-01-22T..."
     * }
     */
    router.post('/v3/models/execute', authenticateToken, async (req, res) => {
      try {
        const { assetId, input, options } = req.body;
        
        // Validation
        if (!assetId) {
          return res.status(400).json({
            error: 'Bad Request',
            message: 'Missing required field: assetId'
          });
        }
        
        if (!input) {
          return res.status(400).json({
            error: 'Bad Request',
            message: 'Missing required field: input'
          });
        }
        
        console.log(`[Model Execution API] Executing model: ${assetId}`);
        console.log(`[Model Execution API] User: ${req.user.username} (${req.user.connectorId})`);
        
        // Execute model
        const result = await executionService.executeModel(
          assetId,
          input,
          options || {},
          req.user.userId,
          req.user.connectorId
        );
        
        // Return appropriate status code
        const statusCode = result.status === 'success' ? 200 : 
                          result.status === 'timeout' ? 504 : 500;
        
        res.status(statusCode).json(result);
        
      } catch (error) {
        console.error('[Model Execution API] Error:', error.message);
        res.status(500).json({
          error: 'Execution Error',
          message: error.message,
          details: error.stack
        });
      }
    });
    
    /**
     * GET /v3/models/executions/:id
     * Get execution status and details by execution ID
     * 
     * Response:
     * {
     *   "id": "exec-uuid",
     *   "asset_id": "asset-id-123",
     *   "asset_name": "Model Name",
     *   "status": "success",
     *   "input_payload": { ... },
     *   "output_payload": { ... },
     *   "execution_time_ms": 1234,
     *   "created_at": "2026-01-22T...",
     *   "completed_at": "2026-01-22T..."
     * }
     */
    router.get('/v3/models/executions/:id', authenticateToken, async (req, res) => {
      try {
        const { id } = req.params;
        
        console.log(`[Model Execution API] Fetching execution: ${id}`);
        
        const execution = await executionService.getExecutionStatus(id);
        
        res.status(200).json(execution);
        
      } catch (error) {
        if (error.message.includes('not found')) {
          return res.status(404).json({
            error: 'Not Found',
            message: error.message
          });
        }
        
        console.error('[Model Execution API] Error:', error.message);
        res.status(500).json({
          error: 'Server Error',
          message: error.message
        });
      }
    });
    
    /**
     * GET /v3/models/executions?assetId=xxx&limit=20
     * Get execution history for an asset
     * 
     * Query params:
     * - assetId (required): Asset identifier
     * - limit (optional): Maximum results (default: 20)
     * 
     * Response: Array of execution records
     */
    router.get('/v3/models/executions', authenticateToken, async (req, res) => {
      try {
        const { assetId, limit } = req.query;
        
        if (!assetId) {
          return res.status(400).json({
            error: 'Bad Request',
            message: 'Missing required query parameter: assetId'
          });
        }
        
        const maxLimit = parseInt(limit, 10) || 20;
        console.log(`[Model Execution API] Fetching execution history for asset: ${assetId}`);
        
        const history = await executionService.getExecutionHistory(assetId, maxLimit);
        
        res.status(200).json({
          assetId,
          count: history.length,
          executions: history
        });
        
      } catch (error) {
        console.error('[Model Execution API] Error:', error.message);
        res.status(500).json({
          error: 'Server Error',
          message: error.message
        });
      }
    });
    
    /**
     * GET /v3/models/executable
     * List all executable assets that the user has permission to execute
     * 
     * Response: Array of executable assets with endpoint information
     * - For authenticated users: shows their own models + models with active contracts
     * - For unauthenticated: shows all executable models (discovery only)
     */
    router.get('/v3/models/executable', optionalAuth, async (req, res) => {
      try {
        console.log('[Model Execution API] Fetching executable assets');
        
        let query;
        let params = [];
        
        if (req.user && req.user.connectorId) {
          // Authenticated user: show owned models + contracted models
          console.log(`[Model Execution API] Filtering for user: ${req.user.connectorId}`);
          
          query = `
            SELECT 
              a.id,
              a.name,
              a.version,
              a.asset_type,
              a.owner,
              a.description,
              a.short_description,
              da.execution_endpoint,
              da.execution_method,
              da.execution_timeout,
              m.task,
              m.algorithm,
              m.framework,
              m.input_features,
              a.created_at,
              CASE 
                WHEN a.owner = $1 THEN 'owned'
                ELSE 'contracted'
              END as access_type
            FROM assets a
            INNER JOIN data_addresses da ON a.id = da.asset_id
            LEFT JOIN ml_metadata m ON a.id = m.asset_id
            WHERE da.is_executable = true
              AND da.execution_endpoint IS NOT NULL
              AND (
                -- User owns the asset
                a.owner = $1
                OR
                -- User has a valid contract agreement
                EXISTS (
                  SELECT 1
                  FROM contract_agreements ca
                  WHERE ca.asset_id = a.id
                  AND ca.consumer_id = $1
                  AND ca.state = 'FINALIZED'
                  AND (ca.end_date IS NULL OR ca.end_date > CURRENT_TIMESTAMP)
                )
              )
            ORDER BY access_type, a.created_at DESC
          `;
          params = [req.user.connectorId];
        } else {
          // Unauthenticated: show all (for discovery only, not execution)
          query = `
            SELECT 
              a.id,
              a.name,
              a.version,
              a.asset_type,
              a.owner,
              a.description,
              a.short_description,
              da.execution_endpoint,
              da.execution_method,
              da.execution_timeout,
              m.task,
              m.algorithm,
              m.framework,
              m.input_features,
              a.created_at
            FROM assets a
            INNER JOIN data_addresses da ON a.id = da.asset_id
            LEFT JOIN ml_metadata m ON a.id = m.asset_id
            WHERE da.is_executable = true
              AND da.execution_endpoint IS NOT NULL
            ORDER BY a.created_at DESC
          `;
        }
        
        const result = await pool.query(query, params);
        
        res.status(200).json({
          count: result.rows.length,
          assets: result.rows,
          filtered: !!req.user,
          note: req.user ? 'Showing owned models and models with active contracts' : 'Discovery mode - authentication required for execution'
        });
        
      } catch (error) {
        console.error('[Model Execution API] Error:', error.message);
        res.status(500).json({
          error: 'Server Error',
          message: error.message
        });
      }
    });
    
    /**
     * GET /v3/assets/:id/executable
     * Check if a specific asset is executable and get execution metadata
     * 
     * Response:
     * {
     *   "isExecutable": true,
     *   "executionEndpoint": "...",
     *   "executionMethod": "POST",
     *   "executionTimeout": 30000,
     *   "inputSchema": { ... }
     * }
     */
    router.get('/v3/assets/:id/executable', optionalAuth, async (req, res) => {
      try {
        const { id } = req.params;
        
        const result = await pool.query(`
          SELECT 
            a.id,
            a.name,
            da.is_executable,
            da.execution_endpoint,
            da.execution_method,
            da.execution_timeout,
            m.input_features
          FROM assets a
          LEFT JOIN data_addresses da ON a.id = da.asset_id
          LEFT JOIN ml_metadata m ON a.id = m.asset_id
          WHERE a.id = $1
        `, [id]);
        
        if (result.rows.length === 0) {
          return res.status(404).json({
            error: 'Not Found',
            message: `Asset not found: ${id}`
          });
        }
        
        const asset = result.rows[0];
        
        res.status(200).json({
          assetId: asset.id,
          assetName: asset.name,
          isExecutable: asset.is_executable || false,
          executionEndpoint: asset.execution_endpoint,
          executionMethod: asset.execution_method,
          executionTimeout: asset.execution_timeout,
          inputSchema: asset.input_features
        });
        
      } catch (error) {
        console.error('[Model Execution API] Error:', error.message);
        res.status(500).json({
          error: 'Server Error',
          message: error.message
        });
      }
    });
    
    // Register router in context
    context.registerService('ModelExecutionRouter', router);
    
    console.log('[Model Execution Extension] Initialized successfully');
    console.log('[Model Execution Extension] Endpoints:');
    console.log('  POST   /v3/models/execute');
    console.log('  GET    /v3/models/executions/:id');
    console.log('  GET    /v3/models/executions?assetId=xxx');
    console.log('  GET    /v3/models/executable');
    console.log('  GET    /v3/assets/:id/executable');
  },
  
  start: async (context) => {
    console.log('[Model Execution Extension] Started');
  }
});
