import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

import { MLAsset } from '../../shared/models/ml-asset';
import { MlAssetsService } from '../../shared/services/ml-assets.service';

type InputMode = 'single' | 'dataset';

interface RankingRow {
  rank: number;
  model: string;
  score: number;
  accuracy: number;
  latency: string;
  cost: string;
  top?: boolean;
}

@Component({
  selector: 'app-model-benchmarking',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './model-benchmarking.component.html',
  styleUrl: './model-benchmarking.component.scss'
})
export class ModelBenchmarkingComponent implements OnInit {
  private readonly mlAssetsService = inject(MlAssetsService);

  inputMode: InputMode = 'single';
  sampleInput = '{"sepal_length": 5.1, "sepal_width": 3.5, "petal_length": 1.4, "petal_width": 0.2}';
  selectedFileName = '';
  isRunning = false;
  statusMessage = 'Demo mode: actions are simulated for preview only.';

  modelPoolAssets: MLAsset[] = [];
  selectedAssetIds: string[] = [];
  isLoadingAssets = false;
  assetsError = '';

  rankingRows: RankingRow[] = [
    { rank: 1, model: 'Iris-V2', score: 0.87, accuracy: 0.93, latency: '280ms', cost: '$0.011', top: true },
    { rank: 2, model: 'Sentinel-Edge', score: 0.84, accuracy: 0.91, latency: '260ms', cost: '$0.015' },
    { rank: 3, model: 'Atlas-Lite', score: 0.78, accuracy: 0.88, latency: '410ms', cost: '$0.013' },
    { rank: 4, model: 'Forge-XL', score: 0.72, accuracy: 0.84, latency: '390ms', cost: '$0.009' }
  ];

  ngOnInit(): void {
    this.loadModelPool();
  }

  get selectedCount(): number {
    return this.selectedAssetIds.length;
  }

  loadModelPool(): void {
    this.isLoadingAssets = true;
    this.assetsError = '';

    this.mlAssetsService.getMachinelearningAssets().subscribe({
      next: (assets) => {
        this.modelPoolAssets = assets;
        this.selectedAssetIds = assets.slice(0, 3).map((asset) => asset.id);
        this.isLoadingAssets = false;
      },
      error: () => {
        this.modelPoolAssets = this.buildDemoAssets();
        this.selectedAssetIds = this.modelPoolAssets.slice(0, 3).map((asset) => asset.id);
        this.isLoadingAssets = false;
        this.assetsError = 'Unable to load live assets. Showing demo catalog.';
      }
    });
  }

  setInputMode(mode: InputMode): void {
    this.inputMode = mode;
  }

  toggleAssetSelection(asset: MLAsset): void {
    if (this.isAssetSelected(asset)) {
      this.selectedAssetIds = this.selectedAssetIds.filter((id) => id !== asset.id);
      return;
    }

    this.selectedAssetIds = [...this.selectedAssetIds, asset.id];
  }

  isAssetSelected(asset: MLAsset): boolean {
    return this.selectedAssetIds.includes(asset.id);
  }

  getAssetMeta(asset: MLAsset): string {
    const tags = [...asset.frameworks, ...asset.libraries, ...asset.algorithms].filter(Boolean);
    if (tags.length === 0) {
      return 'Benchmark-ready';
    }
    return tags.slice(0, 2).join(', ');
  }

  handleFileSelection(event: Event): void {
    const input = event.target as HTMLInputElement;
    const file = input.files?.[0];
    this.selectedFileName = file ? file.name : '';
  }

  validateSchema(): void {
    this.statusMessage = 'Schema validated in demo mode. Ready to run ranking.';
  }

  runRanking(): void {
    if (this.isRunning) {
      return;
    }

    if (this.selectedAssetIds.length < 2) {
      this.statusMessage = 'Select at least two models to generate a ranking.';
      return;
    }

    this.isRunning = true;
    this.statusMessage = 'Running benchmark in demo mode...';

    window.setTimeout(() => {
      const selectedAssets = this.modelPoolAssets.filter((asset) =>
        this.selectedAssetIds.includes(asset.id)
      );
      const ranked = selectedAssets
        .map((asset, index) => this.buildRankingRow(asset, index))
        .sort((a, b) => b.score - a.score)
        .map((row, index) => ({ ...row, rank: index + 1, top: index === 0 }));

      this.rankingRows = ranked;
      this.isRunning = false;
      this.statusMessage = 'Demo ranking generated. Replace with live benchmarking when backend is ready.';
    }, 1200);
  }

  private buildRankingRow(asset: MLAsset, index: number): RankingRow {
    const scoreMap: Record<string, RankingRow> = {
      'asset-user1-sentiment-api': {
        rank: 0,
        model: asset.name,
        score: 0.86,
        accuracy: 0.92,
        latency: '300ms',
        cost: '$0.012'
      },
      'asset-user1-fraud-api': {
        rank: 0,
        model: asset.name,
        score: 0.88,
        accuracy: 0.94,
        latency: '260ms',
        cost: '$0.014'
      },
      'asset-user1-segmentation-model': {
        rank: 0,
        model: asset.name,
        score: 0.82,
        accuracy: 0.9,
        latency: '420ms',
        cost: '$0.016'
      },
      'asset-user1-credit-model': {
        rank: 0,
        model: asset.name,
        score: 0.84,
        accuracy: 0.91,
        latency: '310ms',
        cost: '$0.011'
      }
    };

    const fallbackScores = [0.87, 0.85, 0.82, 0.79, 0.76];
    const score = fallbackScores[index % fallbackScores.length];

    return (
      scoreMap[asset.id] || {
        rank: 0,
        model: asset.name,
        score,
        accuracy: Math.min(0.95, score + 0.06),
        latency: `${280 + index * 40}ms`,
        cost: `$0.0${12 + index}`
      }
    );
  }

  private buildDemoAssets(): MLAsset[] {
    const baseAsset: Omit<MLAsset, 'id' | 'name'> = {
      version: '1.0.0',
      description: 'Demo benchmark asset',
      shortDescription: 'Demo benchmark asset',
      assetType: 'MLModel',
      contentType: 'application/json',
      byteSize: '0',
      format: 'HTTP',
      keywords: ['demo'],
      tasks: ['classification'],
      subtasks: ['tabular'],
      algorithms: ['XGBoost'],
      libraries: ['scikit-learn'],
      frameworks: ['ONNX'],
      modelType: 'tabular',
      storageType: 'HttpData',
      fileName: 'demo',
      owner: 'demo',
      isLocal: true,
      hasContractOffers: false,
      contractOffers: [],
      endpointUrl: 'http://localhost:8080',
      participantId: 'demo',
      assetData: {},
      rawProperties: {},
      originator: 'Local Connector'
    };

    return [
      { ...baseAsset, id: 'demo-iris', name: 'Iris-V2', algorithms: ['Logistic Regression'] },
      { ...baseAsset, id: 'demo-sentinel', name: 'Sentinel-Edge', frameworks: ['TensorFlow'] },
      { ...baseAsset, id: 'demo-atlas', name: 'Atlas-Lite', libraries: ['PyTorch'] },
      { ...baseAsset, id: 'demo-forge', name: 'Forge-XL', algorithms: ['Random Forest'] }
    ];
  }
}
