/**
 * Model Execution Service
 * 
 * Handles HTTP invocation of executable AI models registered in the data space.
 * Provides functionality to resolve endpoints, execute models, and track results.
 * 
 * Features:
 * - HTTP client for model endpoint invocation
 * - Timeout and retry support
 * - Error normalization
 * - Execution tracking and history
 */

const axios = require('axios');
const { v4: uuidv4 } = require('uuid');

class ExecutionService {
  constructor(pool) {
    this.pool = pool;
    this.defaultTimeout = 30000; // 30 seconds
    this.maxRetries = 0; // No retries by default to keep it simple
  }

  /**
   * Resolve executable asset metadata from catalog
   * @param {string} assetId - Asset identifier
   * @returns {Promise<Object>} Asset metadata with execution endpoint
   */
  async resolveExecutableAsset(assetId) {
    const result = await this.pool.query(`
      SELECT 
        a.id,
        a.name,
        a.version,
        a.asset_type,
        a.owner,
        da.execution_endpoint,
        da.execution_method,
        da.execution_timeout,
        da.is_executable,
        da.type as data_address_type,
        m.task,
        m.algorithm,
        m.framework,
        m.input_features
      FROM assets a
      INNER JOIN data_addresses da ON a.id = da.asset_id
      LEFT JOIN ml_metadata m ON a.id = m.asset_id
      WHERE a.id = $1
    `, [assetId]);

    if (result.rows.length === 0) {
      throw new Error(`Asset not found: ${assetId}`);
    }

    const asset = result.rows[0];

    if (!asset.is_executable || !asset.execution_endpoint) {
      throw new Error(`Asset is not executable or missing execution endpoint: ${assetId}`);
    }

    return asset;
  }

  /**
   * Check if user has permission to execute a model
   * User can execute if:
   * 1. They own the model (local execution)
   * 2. They have a finalized contract for the model (negotiated access)
   * 
   * @param {string} assetId - Asset identifier
   * @param {string} connectorId - User's connector ID
   * @returns {Promise<boolean>} True if user has permission
   */
  async checkExecutionPermission(assetId, connectorId) {
    // Check 1: Is user the owner of the asset?
    const ownerCheck = await this.pool.query(`
      SELECT COUNT(*) as count
      FROM assets
      WHERE id = $1 AND owner = $2
    `, [assetId, connectorId]);

    if (parseInt(ownerCheck.rows[0].count) > 0) {
      console.log(`[Execution Service] User ${connectorId} owns asset ${assetId} - Permission granted`);
      return true;
    }

    // Check 2: Does user have a finalized contract agreement for this asset?
    const agreementCheck = await this.pool.query(`
      SELECT COUNT(*) as count
      FROM contract_agreements
      WHERE consumer_id = $1
      AND asset_id = $2
      AND state = 'FINALIZED'
      AND (end_date IS NULL OR end_date > CURRENT_TIMESTAMP)
    `, [connectorId, assetId]);

    if (parseInt(agreementCheck.rows[0].count) > 0) {
      console.log(`[Execution Service] User ${connectorId} has valid contract agreement for asset ${assetId} - Permission granted`);
      return true;
    }

    console.log(`[Execution Service] User ${connectorId} does NOT own asset ${assetId} and has no valid contract - Permission denied`);
    return false;
  }

  /**
   * Execute a model via HTTP invocation
   * @param {string} assetId - Asset identifier
   * @param {Object} payload - Input data for model
   * @param {Object} options - Execution options (timeout, headers, etc.)
   * @param {string} userId - User making the request
   * @param {string} connectorId - Connector ID of the user
   * @returns {Promise<Object>} Execution result
   */
  async executeModel(assetId, payload, options = {}, userId = null, connectorId = null) {
    const executionId = uuidv4();
    const startTime = Date.now();

    try {
      // Step 1: Resolve asset metadata
      console.log(`[Execution Service] Resolving asset: ${assetId}`);
      const asset = await this.resolveExecutableAsset(assetId);

      // Step 2: Check execution permissions (SECURITY)
      if (connectorId) {
        console.log(`[Execution Service] Checking execution permission for ${connectorId}`);
        const hasPermission = await this.checkExecutionPermission(assetId, connectorId);
        
        if (!hasPermission) {
          throw new Error(
            `Access denied: User ${connectorId} does not have permission to execute asset ${assetId}. ` +
            `You must either own the model or have a negotiated contract to execute it.`
          );
        }
      }

      // Step 3: Create execution record (status: pending)
      await this.createExecutionRecord(executionId, assetId, userId, connectorId, payload, 'pending');

      // Step 4: Update status to running
      await this.updateExecutionStatus(executionId, 'running', Date.now());

      // Step 5: Prepare HTTP request
      const timeout = options.timeout || asset.execution_timeout || this.defaultTimeout;
      const method = (options.method || asset.execution_method || 'POST').toUpperCase();
      const headers = {
        'Content-Type': 'application/json',
        'User-Agent': 'AIModelHub-Orchestrator/1.0',
        ...(options.headers || {})
      };

      console.log(`[Execution Service] Invoking ${method} ${asset.execution_endpoint}`);
      console.log(`[Execution Service] Timeout: ${timeout}ms`);

      // Step 6: Execute HTTP request
      const axiosConfig = {
        method,
        url: asset.execution_endpoint,
        data: payload,
        headers,
        timeout,
        validateStatus: () => true // Don't throw on any status code
      };

      const response = await axios(axiosConfig);
      const executionTime = Date.now() - startTime;

      console.log(`[Execution Service] Response status: ${response.status}`);
      console.log(`[Execution Service] Execution time: ${executionTime}ms`);

      // Step 7: Handle response based on status code
      if (response.status >= 200 && response.status < 300) {
        // Success
        await this.updateExecutionSuccess(
          executionId,
          response.data,
          executionTime,
          response.status,
          Date.now()
        );

        return {
          executionId,
          status: 'success',
          assetId,
          assetName: asset.name,
          output: response.data,
          executionTimeMs: executionTime,
          httpStatus: response.status,
          timestamp: new Date().toISOString()
        };
      } else {
        // HTTP error (4xx, 5xx)
        const errorMessage = this.extractErrorMessage(response);
        await this.updateExecutionError(
          executionId,
          errorMessage,
          `HTTP_${response.status}`,
          response.status,
          Date.now()
        );

        return {
          executionId,
          status: 'error',
          assetId,
          assetName: asset.name,
          error: {
            message: errorMessage,
            code: `HTTP_${response.status}`,
            httpStatus: response.status,
            details: response.data
          },
          executionTimeMs: executionTime,
          timestamp: new Date().toISOString()
        };
      }

    } catch (error) {
      const executionTime = Date.now() - startTime;
      console.error(`[Execution Service] Error executing model:`, error.message);

      // Handle different types of errors
      let errorCode = 'EXECUTION_ERROR';
      let errorMessage = error.message;
      let status = 'error';

      if (error.code === 'ECONNABORTED' || error.message.includes('timeout')) {
        errorCode = 'TIMEOUT';
        status = 'timeout';
        errorMessage = `Execution timeout after ${executionTime}ms`;
      } else if (error.code === 'ECONNREFUSED') {
        errorCode = 'CONNECTION_REFUSED';
        errorMessage = 'Cannot connect to model endpoint';
      } else if (error.code === 'ENOTFOUND') {
        errorCode = 'ENDPOINT_NOT_FOUND';
        errorMessage = 'Model endpoint not found (DNS error)';
      }

      // Update execution record with error
      await this.updateExecutionError(
        executionId,
        errorMessage,
        errorCode,
        null,
        Date.now()
      );

      return {
        executionId,
        status,
        assetId,
        error: {
          message: errorMessage,
          code: errorCode,
          details: error.response?.data || error.message
        },
        executionTimeMs: executionTime,
        timestamp: new Date().toISOString()
      };
    }
  }

  /**
   * Get execution status by ID
   * @param {string} executionId - Execution identifier
   * @returns {Promise<Object>} Execution details
   */
  async getExecutionStatus(executionId) {
    const result = await this.pool.query(`
      SELECT 
        me.*,
        a.name as asset_name,
        a.version as asset_version,
        a.asset_type
      FROM model_executions me
      LEFT JOIN assets a ON me.asset_id = a.id
      WHERE me.id = $1
    `, [executionId]);

    if (result.rows.length === 0) {
      throw new Error(`Execution not found: ${executionId}`);
    }

    return result.rows[0];
  }

  /**
   * Get execution history for an asset
   * @param {string} assetId - Asset identifier
   * @param {number} limit - Maximum number of results
   * @returns {Promise<Array>} List of executions
   */
  async getExecutionHistory(assetId, limit = 20) {
    const result = await this.pool.query(`
      SELECT 
        id,
        asset_id,
        user_id,
        connector_id,
        status,
        input_payload,
        output_payload,
        error_message,
        error_code,
        http_status_code,
        execution_time_ms,
        created_at,
        started_at,
        completed_at
      FROM model_executions
      WHERE asset_id = $1
      ORDER BY created_at DESC
      LIMIT $2
    `, [assetId, limit]);

    return result.rows;
  }

  /**
   * Extract error message from HTTP response
   * @private
   */
  extractErrorMessage(response) {
    if (response.data) {
      if (typeof response.data === 'string') {
        return response.data.substring(0, 500); // Limit length
      }
      if (response.data.error) {
        return response.data.error;
      }
      if (response.data.message) {
        return response.data.message;
      }
      if (response.data.detail) {
        return response.data.detail;
      }
    }
    return `HTTP ${response.status}: ${response.statusText}`;
  }

  /**
   * Create initial execution record
   * @private
   */
  async createExecutionRecord(executionId, assetId, userId, connectorId, inputPayload, status) {
    await this.pool.query(`
      INSERT INTO model_executions 
        (id, asset_id, user_id, connector_id, status, input_payload, created_at)
      VALUES ($1, $2, $3, $4, $5, $6, NOW())
    `, [executionId, assetId, userId, connectorId, status, JSON.stringify(inputPayload)]);
  }

  /**
   * Update execution status to running
   * @private
   */
  async updateExecutionStatus(executionId, status, startedAt) {
    await this.pool.query(`
      UPDATE model_executions 
      SET status = $1, started_at = to_timestamp($2 / 1000.0)
      WHERE id = $3
    `, [status, startedAt, executionId]);
  }

  /**
   * Update execution with success result
   * @private
   */
  async updateExecutionSuccess(executionId, outputPayload, executionTime, httpStatus, completedAt) {
    await this.pool.query(`
      UPDATE model_executions 
      SET 
        status = 'success',
        output_payload = $1,
        execution_time_ms = $2,
        http_status_code = $3,
        completed_at = to_timestamp($4 / 1000.0)
      WHERE id = $5
    `, [JSON.stringify(outputPayload), executionTime, httpStatus, completedAt, executionId]);
  }

  /**
   * Update execution with error
   * @private
   */
  async updateExecutionError(executionId, errorMessage, errorCode, httpStatus, completedAt) {
    await this.pool.query(`
      UPDATE model_executions 
      SET 
        status = CASE 
          WHEN $2 = 'TIMEOUT' THEN 'timeout'
          ELSE 'error'
        END,
        error_message = $1,
        error_code = $2,
        http_status_code = $3,
        completed_at = to_timestamp($4 / 1000.0)
      WHERE id = $5
    `, [errorMessage, errorCode, httpStatus, completedAt, executionId]);
  }
}

module.exports = { ExecutionService };
