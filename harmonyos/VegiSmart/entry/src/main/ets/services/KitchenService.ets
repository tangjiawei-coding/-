import { http } from '@kit.NetworkKit';
import { FoodExample, Recipe } from '../model/RecipeCatalog';

export interface KitchenResult {
  status: string;
  message: string;
  food: FoodExample | null;
  recipes: Recipe[];
}
interface KitchenRequest { name: string; imageDataUrl: string; }
interface ApiError { detail: string; }

export class KitchenService {
  private connection: http.HttpRequest | undefined = undefined;

  cancel(): void {
    this.connection?.destroy();
    this.connection = undefined;
  }

  async explore(name: string, imageDataUrl: string): Promise<KitchenResult> {
    const connection = http.createHttp();
    this.connection = connection;
    const request: KitchenRequest = { name, imageDataUrl };
    try {
      // USB 调试通过 hdc rport tcp:8000 tcp:8000 连接电脑后端。
      const response = await connection.request('http://127.0.0.1:8000/api/explorations', {
        method: http.RequestMethod.POST, header: { 'Content-Type': 'application/json' },
        extraData: JSON.stringify(request), expectDataType: http.HttpDataType.STRING,
        connectTimeout: 10000, readTimeout: 165000
      });
      const text = response.result as string;
      if (response.responseCode !== 200) {
        let message = '服务暂时不可用，请稍后重试';
        try {
          const error = JSON.parse(text) as ApiError;
          if (typeof error.detail === 'string') { message = error.detail; }
        } catch (_) { /* 非 JSON 错误保留简短提示。 */ }
        throw new Error(message);
      }
      return JSON.parse(text) as KitchenResult;
    } finally {
      if (this.connection === connection) { connection.destroy(); this.connection = undefined; }
    }
  }
}
