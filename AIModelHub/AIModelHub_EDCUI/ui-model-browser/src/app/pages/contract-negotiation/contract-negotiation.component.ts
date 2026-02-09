import { Component, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { interval, Subscription } from 'rxjs';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../../environments/environment';
import { AuthService } from '../../shared/services/auth.service';

interface SimulatedConnector {
  id: string;
  name: string;
  endpoint: string;
  behavior: string;
  responseTime: number;
  isActive: boolean;
  stats?: any;
}

interface Negotiation {
  id: string;
  state: string;
  asset_id: string;
  provider_id: string;
  counterparty_id: string;
  agreement_id?: string;
  created_at: string;
  finalized_at?: string;
  error_detail?: string;
}

interface Asset {
  id: string;
  name: string;
  owner: string;
}

@Component({
  selector: 'app-contract-negotiation',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './contract-negotiation.component.html',
  styleUrls: ['./contract-negotiation.component.scss']
})
export class ContractNegotiationComponent implements OnInit, OnDestroy {
  // Data
  connectors: SimulatedConnector[] = [];
  availableProviders: SimulatedConnector[] = []; // Connectors excluding current user
  negotiations: Negotiation[] = [];
  assets: Asset[] = [];
  
  // UI State
  activeTab: 'connectors' | 'negotiations' | 'demo' = 'demo';
  loading = false;
  message: string | null = null;
  messageType: 'success' | 'error' | 'info' = 'info';
  
  // Demo form
  selectedAssetId: string = '';
  selectedProviderId: string = '';
  
  // New connector form
  showNewConnectorForm = false;
  newConnector = {
    name: '',
    behavior: 'auto-accept',
    responseTime: 2000
  };
  
  // Auto-refresh
  private refreshSubscription?: Subscription;
  autoRefresh = true;

  // Make Object available in template
  Object = Object;

  getObjectKeys(obj: any): string[] {
    return Object.keys(obj || {});
  }

  getSelectedConnector(): SimulatedConnector | undefined {
    return this.connectors.find(c => c.id === this.selectedProviderId);
  }
  
  constructor(
    private http: HttpClient,
    private authService: AuthService
  ) {}
  
  ngOnInit(): void {
    this.loadData();
    this.startAutoRefresh();
  }
  
  ngOnDestroy(): void {
    this.stopAutoRefresh();
  }

  // ==================== HELPER METHODS ====================

  updateSelectedAssetId(value: string): void {
    this.selectedAssetId = value;
  }

  updateSelectedProviderId(value: string): void {
    this.selectedProviderId = value;
    // Reload assets when provider changes to show only their contracted assets
    this.selectedAssetId = ''; // Reset asset selection
    this.loadAssets();
  }

  updateNewConnectorName(value: string): void {
    this.newConnector.name = value;
  }

  updateNewConnectorBehavior(value: string): void {
    this.newConnector.behavior = value;
  }

  updateNewConnectorResponseTime(value: number): void {
    this.newConnector.responseTime = value;
  }
  
  // ==================== DATA LOADING ====================
  
  async loadData(): Promise<void> {
    await Promise.all([
      this.loadConnectors(),
      this.loadNegotiations(),
      this.loadAssets()
    ]);
  }
  
  async loadConnectors(): Promise<void> {
    try {
      const token = localStorage.getItem('token');
      const response = await this.http.get<any>(
        `${environment.runtime.managementApiUrl}/v3/simulator/connectors`,
        { headers: { Authorization: `Bearer ${token}` } }
      ).toPromise();
      
      this.connectors = response.connectors || [];
      
      // Filter out current user from available providers
      const currentUserConnectorId = this.authService.getConnectorId();
      this.availableProviders = this.connectors.filter(
        connector => connector.id !== currentUserConnectorId
      );
      
      console.log('Loaded connectors:', this.connectors.length);
      console.log('Available providers (excluding current user):', this.availableProviders.length);
    } catch (error) {
      console.error('Error loading connectors:', error);
      this.showMessage('Error loading connectors', 'error');
    }
  }
  
  async loadNegotiations(): Promise<void> {
    try {
      const token = localStorage.getItem('token');
      const response = await this.http.get<any>(
        `${environment.runtime.managementApiUrl}/v3/contractnegotiations`,
        { headers: { Authorization: `Bearer ${token}` } }
      ).toPromise();
      
      this.negotiations = response.negotiations || [];
      console.log('Loaded negotiations:', this.negotiations.length);
    } catch (error) {
      console.error('Error loading negotiations:', error);
    }
  }
  
  async loadAssets(): Promise<void> {
    try {
      const token = localStorage.getItem('token');
      
      // If a provider is selected, load only their assets with contracts
      if (this.selectedProviderId) {
        const response = await this.http.get<any>(
          `${environment.runtime.managementApiUrl}/v3/assets/provider/${this.selectedProviderId}`,
          { headers: { Authorization: `Bearer ${token}` } }
        ).toPromise();
        
        this.assets = response || [];
        console.log(`Loaded ${this.assets.length} assets with contracts from provider: ${this.selectedProviderId}`);
      } else {
        // No provider selected, load all assets
        const response = await this.http.get<any>(
          `${environment.runtime.managementApiUrl}/v3/assets`,
          { headers: { Authorization: `Bearer ${token}` } }
        ).toPromise();
        
        this.assets = response || [];
        console.log(`Loaded ${this.assets.length} total assets`);
      }
      
      // Pre-select first asset if available
      if (this.assets.length > 0 && !this.selectedAssetId) {
        this.selectedAssetId = this.assets[0].id;
      }
    } catch (error) {
      console.error('Error loading assets:', error);
      this.assets = [];
    }
  }
  
  // ==================== AUTO REFRESH ====================
  
  startAutoRefresh(): void {
    if (this.autoRefresh) {
      this.refreshSubscription = interval(5000).subscribe(() => {
        this.loadNegotiations();
        this.loadConnectors();
      });
    }
  }
  
  stopAutoRefresh(): void {
    if (this.refreshSubscription) {
      this.refreshSubscription.unsubscribe();
    }
  }
  
  toggleAutoRefresh(): void {
    this.autoRefresh = !this.autoRefresh;
    if (this.autoRefresh) {
      this.startAutoRefresh();
    } else {
      this.stopAutoRefresh();
    }
  }
  
  // ==================== DEMO ACTIONS ====================
  
  async startDemoNegotiation(): Promise<void> {
    if (!this.selectedAssetId || !this.selectedProviderId) {
      this.showMessage('Please select an asset and a provider', 'error');
      return;
    }
    
    this.loading = true;
    this.message = null;
    
    try {
      const token = localStorage.getItem('token');
      const response = await this.http.post<any>(
        `${environment.runtime.managementApiUrl}/v3/simulator/negotiate-demo`,
        {
          assetId: this.selectedAssetId,
          providerId: this.selectedProviderId
        },
        { headers: { Authorization: `Bearer ${token}` } }
      ).toPromise();
      
      this.showMessage(
        `Negotiation started! ID: ${response.negotiation.id}. Check the Negotiations tab to see progress.`,
        'success'
      );
      
      // Switch to negotiations tab
      this.activeTab = 'negotiations';
      
      // Reload data
      await this.loadNegotiations();
      
    } catch (error: any) {
      console.error('Error starting demo:', error);
      this.showMessage(error.error?.message || 'Error starting demo negotiation', 'error');
    } finally {
      this.loading = false;
    }
  }
  
  // ==================== CONNECTOR ACTIONS ====================
  
  async toggleConnector(connectorId: string): Promise<void> {
    try {
      const token = localStorage.getItem('token');
      await this.http.post(
        `${environment.runtime.managementApiUrl}/v3/simulator/connectors/${connectorId}/toggle`,
        {},
        { headers: { Authorization: `Bearer ${token}` } }
      ).toPromise();
      
      await this.loadConnectors();
      this.showMessage('Connector status updated', 'success');
    } catch (error) {
      console.error('Error toggling connector:', error);
      this.showMessage('Error updating connector', 'error');
    }
  }
  
  async createConnector(): Promise<void> {
    if (!this.newConnector.name) {
      this.showMessage('Connector name is required', 'error');
      return;
    }
    
    this.loading = true;
    
    try {
      const token = localStorage.getItem('token');
      await this.http.post(
        `${environment.runtime.managementApiUrl}/v3/simulator/connectors`,
        this.newConnector,
        { headers: { Authorization: `Bearer ${token}` } }
      ).toPromise();
      
      this.showMessage('Connector created successfully', 'success');
      this.showNewConnectorForm = false;
      this.resetNewConnectorForm();
      await this.loadConnectors();
      
    } catch (error) {
      console.error('Error creating connector:', error);
      this.showMessage('Error creating connector', 'error');
    } finally {
      this.loading = false;
    }
  }
  
  resetNewConnectorForm(): void {
    this.newConnector = {
      name: '',
      behavior: 'auto-accept',
      responseTime: 2000
    };
  }
  
  // ==================== HELPER METHODS ====================
  
  setActiveTab(tab: 'connectors' | 'negotiations' | 'demo'): void {
    this.activeTab = tab;
  }
  
  toggleNewConnectorForm(): void {
    this.showNewConnectorForm = !this.showNewConnectorForm;
  }
  
  showMessage(text: string, type: 'success' | 'error' | 'info'): void {
    this.message = text;
    this.messageType = type;
    
    setTimeout(() => {
      this.message = null;
    }, 5000);
  }
  
  getStateColor(state: string): string {
    const colors: { [key: string]: string } = {
      'REQUESTED': 'blue',
      'OFFERED': 'purple',
      'ACCEPTED': 'orange',
      'AGREED': 'teal',
      'VERIFIED': 'indigo',
      'FINALIZED': 'green',
      'DECLINED': 'red',
      'TERMINATED': 'gray'
    };
    return colors[state] || 'gray';
  }
  
  getBehaviorColor(behavior: string): string {
    const colors: { [key: string]: string } = {
      'auto-accept': 'green',
      'auto-reject': 'red',
      'auto-offer': 'blue',
      'slow-accept': 'yellow',
      'manual': 'gray'
    };
    return colors[behavior] || 'gray';
  }
  
  getBehaviorDescription(behavior: string): string {
    const descriptions: { [key: string]: string } = {
      'auto-accept': 'Automatically accepts all negotiations',
      'auto-reject': 'Automatically rejects all negotiations',
      'auto-offer': 'Makes offer, waits for acceptance',
      'slow-accept': 'Accepts after 5 second delay',
      'manual': 'Requires manual intervention'
    };
    return descriptions[behavior] || 'Unknown behavior';
  }
  
  formatDate(dateString: string): string {
    if (!dateString) return '-';
    const date = new Date(dateString);
    return date.toLocaleString();
  }
  
  getTimeSince(dateString: string): string {
    if (!dateString) return '-';
    const date = new Date(dateString);
    const now = new Date();
    const seconds = Math.floor((now.getTime() - date.getTime()) / 1000);
    
    if (seconds < 60) return `${seconds}s ago`;
    if (seconds < 3600) return `${Math.floor(seconds / 60)}m ago`;
    if (seconds < 86400) return `${Math.floor(seconds / 3600)}h ago`;
    return `${Math.floor(seconds / 86400)}d ago`;
  }
  
  async refreshData(): Promise<void> {
    this.loading = true;
    await this.loadData();
    this.loading = false;
    this.showMessage('Data refreshed', 'info');
  }
  
  getAssetName(assetId: string): string {
    const asset = this.assets.find(a => a.id === assetId);
    return asset ? asset.name : assetId;
  }
  
  getConnectorName(connectorId: string): string {
    const connector = this.connectors.find(c => c.id === connectorId);
    return connector ? connector.name : connectorId;
  }
}
