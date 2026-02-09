/**
 * Model Execution Service
 * 
 * Angular service for executing AI models through the orchestrator API.
 * Handles model execution requests, status tracking, and result retrieval.
 */

import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';

/**
 * Model execution request payload
 */
export interface ModelExecutionRequest {
  assetId: string;
  input: any;
  options?: {
    timeout?: number;
    headers?: Record<string, string>;
  };
}

/**
 * Model execution response
 */
export interface ModelExecutionResponse {
  executionId: string;
  status: 'success' | 'error' | 'timeout' | 'running' | 'pending';
  assetId: string;
  assetName?: string;
  output?: any;
  error?: {
    message: string;
    code: string;
    httpStatus?: number;
    details?: any;
  };
  executionTimeMs?: number;
  timestamp: string;
}

/**
 * Execution history item
 */
export interface ExecutionHistoryItem {
  id: string;
  asset_id: string;
  user_id: string;
  connector_id: string;
  status: string;
  input_payload: any;
  output_payload?: any;
  error_message?: string;
  error_code?: string;
  http_status_code?: number;
  execution_time_ms?: number;
  created_at: string;
  started_at?: string;
  completed_at?: string;
}

/**
 * Executable asset metadata
 */
export interface ExecutableAsset {
  id: string;
  name: string;
  version: string;
  asset_type: string;
  owner: string;
  description?: string;
  short_description?: string;
  execution_endpoint: string;
  execution_method: string;
  execution_timeout: number;
  task?: string;
  algorithm?: string;
  framework?: string;
  input_features?: any;
  created_at: string;
}

/**
 * Asset executable info
 */
export interface AssetExecutableInfo {
  assetId: string;
  assetName: string;
  isExecutable: boolean;
  executionEndpoint?: string;
  executionMethod?: string;
  executionTimeout?: number;
  inputSchema?: any;
}

@Injectable({
  providedIn: 'root'
})
export class ModelExecutionService {
  private readonly http = inject(HttpClient);
  
  private readonly BASE_URL = `${environment.runtime.managementApiUrl}/v3/models`;

  /**
   * Execute a model by assetId
   * @param request Execution request with assetId and input data
   * @returns Observable with execution result
   */
  executeModel(request: ModelExecutionRequest): Observable<ModelExecutionResponse> {
    return this.http.post<ModelExecutionResponse>(
      `${this.BASE_URL}/execute`,
      request
    );
  }

  /**
   * Get execution status by execution ID
   * @param executionId Unique execution identifier
   * @returns Observable with execution details
   */
  getExecutionStatus(executionId: string): Observable<any> {
    return this.http.get<any>(
      `${this.BASE_URL}/executions/${executionId}`
    );
  }

  /**
   * Get execution history for an asset
   * @param assetId Asset identifier
   * @param limit Maximum number of results (default: 20)
   * @returns Observable with execution history
   */
  getExecutionHistory(assetId: string, limit: number = 20): Observable<{
    assetId: string;
    count: number;
    executions: ExecutionHistoryItem[];
  }> {
    return this.http.get<{
      assetId: string;
      count: number;
      executions: ExecutionHistoryItem[];
    }>(
      `${this.BASE_URL}/executions?assetId=${encodeURIComponent(assetId)}&limit=${limit}`
    );
  }

  /**
   * Get list of all executable assets
   * @returns Observable with list of executable assets
   */
  getExecutableAssets(): Observable<{
    count: number;
    assets: ExecutableAsset[];
  }> {
    return this.http.get<{
      count: number;
      assets: ExecutableAsset[];
    }>(
      `${this.BASE_URL}/executable`
    );
  }

  /**
   * Check if a specific asset is executable
   * @param assetId Asset identifier
   * @returns Observable with executable info
   */
  checkAssetExecutable(assetId: string): Observable<AssetExecutableInfo> {
    return this.http.get<AssetExecutableInfo>(
      `${environment.runtime.managementApiUrl}/v3/assets/${encodeURIComponent(assetId)}/executable`
    );
  }
}
