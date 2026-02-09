import { Component, OnInit, OnDestroy, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatTabsModule } from '@angular/material/tabs';
import { MatListModule } from '@angular/material/list';
import { MatChipsModule } from '@angular/material/chips';
import { MatExpansionModule } from '@angular/material/expansion';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { CatalogStateService } from '../../../shared/services/catalog-state.service';
import { ContractNegotiationService } from '../../../shared/services/contract-negotiation.service';
import { NotificationService } from '../../../shared/services/notification.service';
import { interval, timer, Subscription, from } from 'rxjs';
import { switchMap, takeUntil, tap, catchError } from 'rxjs/operators';

interface ContractOffer {
  '@id': string;
  '@type': string;
  contractId: string;
  accessPolicyId: string;
  contractPolicyId: string;
  accessPolicy: any;
  contractPolicy: any;
}

interface CatalogDetailData {
  assetId: string;
  properties: any;
  originator: string;
  participantId?: string;
  endpointUrl?: string;
  contractOffers: ContractOffer[];
  contractCount: number;
  catalogView?: boolean;
  returnUrl?: string;
  selectedTabIndex?: number;
}

/**
 * Catalog Detail Component
 * Shows asset information and contract offers for negotiation
 * Similar to dataspace-connector-interface contract-offers-viewer
 */
@Component({
  selector: 'app-catalog-detail',
  standalone: true,
  imports: [
    CommonModule,
    MatCardModule,
    MatButtonModule,
    MatIconModule,
    MatTabsModule,
    MatListModule,
    MatChipsModule,
    MatExpansionModule,
    MatProgressBarModule
  ],
  templateUrl: './catalog-detail.component.html',
  styleUrl: './catalog-detail.component.scss'
})
export class CatalogDetailComponent implements OnInit, OnDestroy {
  private router = inject(Router);
  private catalogStateService = inject(CatalogStateService);
  private contractNegotiationService = inject(ContractNegotiationService);
  private notificationService = inject(NotificationService);

  data: CatalogDetailData | null = null;
  selectedTabIndex = 0;

  // Negotiation state management
  runningNegotiations = new Map<string, { id: string; offerId: string }>();
  finishedNegotiations = new Map<string, { id: string; state: string }>();
  private pollingSubscription?: Subscription;

  ngOnInit(): void {
    console.log('[Catalog Detail] Component initialized');
    
    // Get data from service
    this.data = this.catalogStateService.getCurrentItem();
    console.log('[Catalog Detail] Data from service:', this.data);

    // Check if we have the required data
    if (!this.data || !this.data.assetId) {
      console.error('[Catalog Detail] No data available, redirecting to catalog');
      this.router.navigate(['/catalog']);
      return;
    }

    // Set selected tab index if provided
    if (this.data.selectedTabIndex !== undefined) {
      this.selectedTabIndex = this.data.selectedTabIndex;
      console.log('[Catalog Detail] Tab index set to:', this.selectedTabIndex);
    }

    console.log('[Catalog Detail] Successfully loaded data for asset:', this.data.assetId);
  }

  ngOnDestroy(): void {
    // Clean up polling subscription
    this.cleanupPolling();
  }

  backToList(): void {
    const returnUrl = this.data?.returnUrl || '/catalog';
    this.router.navigate([returnUrl]);
  }

  getPolicyAction(policy: any): string {
    if (!policy?.policy) return 'N/A';
    const permissions = policy.policy['odrl:permission'];
    if (Array.isArray(permissions) && permissions.length > 0) {
      return permissions[0]['odrl:action'] || 'N/A';
    }
    return 'N/A';
  }

  getPolicyConstraints(policy: any): any[] {
    if (!policy?.policy) return [];
    const permissions = policy.policy['odrl:permission'];
    if (Array.isArray(permissions) && permissions.length > 0) {
      return permissions[0]['odrl:constraint'] || [];
    }
    return [];
  }

  formatConstraint(constraint: any): string {
    const leftOperand = constraint['odrl:leftOperand'] || '';
    const operator = constraint['odrl:operator'] || '';
    const rightOperand = constraint['odrl:rightOperand'] || '';
    return `${leftOperand} ${operator} ${rightOperand}`;
  }

  viewPolicyJson(policy: any): void {
    console.log('[Catalog Detail] Policy JSON:', policy);
    // TODO: Open dialog with JSON viewer
  }

  negotiateContract(offer: ContractOffer): void {
    if (!this.data) {
      console.error('[Catalog Detail] No data available for negotiation');
      return;
    }

    console.log('[Catalog Detail] Negotiating contract:', offer);
    this.notificationService.showInfo('Initiating contract negotiation...');

    // Get provider ID from participantId or extract from properties
    const providerId = this.data.participantId || 
                      this.data.properties?.owner || 
                      this.data.originator;
    
    const counterPartyAddress = this.data.endpointUrl || 
                               `http://provider-connector/${providerId}`;

    console.log('[Catalog Detail] Provider ID:', providerId);
    console.log('[Catalog Detail] Counter party address:', counterPartyAddress);

    // Prepare negotiation request
    const negotiationRequest = {
      '@type': 'ContractRequest',
      'counterPartyAddress': counterPartyAddress,
      'protocol': 'dataspace-protocol-http',
      'policy': {
        '@id': offer['@id'],
        '@type': 'Offer',
        'assigner': providerId,
        'target': this.data.assetId
      }
    };

    console.log('[Catalog Detail] Negotiation request:', negotiationRequest);

    // Initiate negotiation
    this.contractNegotiationService.initiate(negotiationRequest).subscribe({
      next: (response) => {
        const negotiationId = response['@id'] || response.id;
        console.log('[Catalog Detail] Negotiation initiated:', negotiationId);
        
        // Mark negotiation as running
        this.finishedNegotiations.delete(offer['@id']);
        this.runningNegotiations.set(offer['@id'], {
          id: negotiationId,
          offerId: offer['@id']
        });

        this.notificationService.showInfo(`Negotiation started: ${negotiationId}`);
        
        // Start polling negotiation state
        this.checkActiveNegotiations(negotiationId, offer['@id']);
      },
      error: (error) => {
        console.error('[Catalog Detail] Error starting negotiation:', error);
        this.notificationService.showError('Error starting negotiation');
      }
    });
  }

  checkActiveNegotiations(negotiationId: string, offerId: string): void {
    // Timeout after 30 seconds
    const timeout$ = timer(30000).pipe(
      tap(() => {
        if (this.runningNegotiations.has(offerId)) {
          this.notificationService.showWarning(
            `Negotiation [${negotiationId}] timed out after 30 seconds.`
          );
          this.runningNegotiations.delete(offerId);
        }
      })
    );

    // Poll every 2 seconds
    this.pollingSubscription = interval(2000).pipe(
      takeUntil(timeout$),
      switchMap(() => from([...this.runningNegotiations.values()])),
      switchMap(negotiation =>
        this.contractNegotiationService.get(negotiation.id).pipe(
          catchError(error => {
            console.error('[Catalog Detail] Polling error:', error);
            this.notificationService.showError('Error polling negotiation');
            return from([]);
          })
        )
      )
    ).subscribe({
      next: (negotiation: any) => {
        if (!negotiation || !negotiation['@id']) return;

        const state = negotiation.state || 'UNKNOWN';
        console.log(`[Catalog Detail] Negotiation ${negotiation['@id']} state: ${state}`);

        // Check if negotiation is finished
        if (state === 'FINALIZED' || state === 'VERIFIED' || state === 'TERMINATED') {
          const offerId = negotiation.policy?.['@id'] || 
                         [...this.runningNegotiations.entries()]
                           .find(([_, v]) => v.id === negotiation['@id'])?.[0];

          if (offerId) {
            this.runningNegotiations.delete(offerId);
            this.finishedNegotiations.set(offerId, {
              id: negotiation['@id'],
              state: state
            });

            if (state === 'FINALIZED' || state === 'VERIFIED') {
              this.notificationService.showInfo(
                `Contract negotiation completed successfully: ${negotiation['@id']}`
              );
            } else {
              this.notificationService.showWarning(
                `Contract negotiation terminated: ${negotiation['@id']}`
              );
            }

            // Clean up if no more active negotiations
            if (this.runningNegotiations.size === 0) {
              this.cleanupPolling();
            }
          }
        }
      },
      error: (error) => {
        console.error('[Catalog Detail] Subscription error:', error);
      }
    });
  }

  isBusy(offer: ContractOffer): boolean {
    return this.runningNegotiations.has(offer['@id']);
  }

  isNegotiated(offer: ContractOffer): boolean {
    return this.finishedNegotiations.has(offer['@id']);
  }

  getNegotiationState(offer: ContractOffer): string {
    const finished = this.finishedNegotiations.get(offer['@id']);
    return finished ? finished.state : '';
  }

  private cleanupPolling(): void {
    if (this.pollingSubscription) {
      this.pollingSubscription.unsubscribe();
      this.pollingSubscription = undefined;
    }
  }

  getPropertyKeys(): string[] {
    if (!this.data?.properties) return [];
    return Object.keys(this.data.properties).filter(key => 
      !['name', 'version', 'contentType', 'description', 'shortDescription', 
        'keywords', 'byteSize', 'format', 'type', 'owner'].includes(key)
    );
  }

  isArray(value: any): boolean {
    return Array.isArray(value);
  }

  isObject(value: any): boolean {
    return value !== null && typeof value === 'object' && !Array.isArray(value);
  }

  getEntries(obj: any): { key: string; value: any }[] {
    if (!obj || typeof obj !== 'object') return [];
    return Object.entries(obj).map(([key, value]) => ({ key, value }));
  }
}
