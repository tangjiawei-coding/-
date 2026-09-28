import { http } from '@kit.NetworkKit';

export interface FoodResult {
  name: string | null;
  observations: string[];
  appearance: string;
  onSiteChecks: string[];
  buyingAdvice: string;
  needsRetake: boolean;
  retakeReason: string | null;
  gramsPerPerson: number | null;
  quantityNote: string;
}

interface RecognitionRequest {
  imageDataUrl: string;
  correctedName: string;
}

interface ApiError {
  detail: string;
}

export class FoodRecognitionService {
  // 地址指向自己的后端；模型地址和密钥只由后端使用。
  static async recognize(baseUrl: string, imageDataUrl: string, correctedName: string): Promise<FoodResult> {
    const connection = http.createHttp();
    const request: RecognitionRequest = { imageDataUrl, correctedName };
    try {
      const response = await connection.request(`${baseUrl.replace(/\/+$/, '')}/recognitions`, {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/json' },
        extraData: JSON.stringify(request),
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: 10000,
        readTimeout: 100000
      });
      const text = response.result as string;
      if (response.responseCode !== 200) {
        let message = `识别失败（${response.responseCode}），请检查服务连接`;
        try {
          const error = JSON.parse(text) as ApiError;
          if (typeof error.detail === 'string') { message = error.detail; }
        } catch (_) {
          // 代理可能返回 HTML，此时保留 HTTP 状态提示。
        }
        throw new Error(message);
      }
      return JSON.parse(text) as FoodResult;
    } finally {
      connection.destroy();
    }
  }
}
