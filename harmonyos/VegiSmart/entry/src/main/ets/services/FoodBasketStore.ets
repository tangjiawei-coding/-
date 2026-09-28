import { common } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';

export interface BasketItem {
  id: string;
  name: string;
  grams: number;
  people: number;
  priceCents: number | null;
  priceBaseGrams: number;
  totalCents: number | null;
}

export class FoodBasketStore {
  private store: preferences.Preferences | undefined = undefined;

  async open(context: common.UIAbilityContext): Promise<void> {
    // 第一版只有少量食材篮数据；库存批次功能确定后再迁移 RDB。
    this.store = await preferences.getPreferences(context, { name: 'food_purchase' });
  }

  async loadBasket(): Promise<BasketItem[]> {
    if (!this.store) { throw new Error('食材篮尚未就绪'); }
    const raw = await this.store.get('basket', '[]') as string;
    return JSON.parse(raw) as BasketItem[];
  }

  async saveBasket(items: BasketItem[]): Promise<void> {
    if (!this.store) { throw new Error('食材篮尚未就绪'); }
    await this.store.put('basket', JSON.stringify(items));
    await this.store.flush();
  }

  async loadServer(): Promise<string> {
    if (!this.store) { throw new Error('存储尚未就绪'); }
    return await this.store.get('server', 'http://127.0.0.1:8000') as string;
  }

  async saveServer(server: string): Promise<void> {
    if (!this.store) { throw new Error('存储尚未就绪'); }
    await this.store.put('server', server);
    await this.store.flush();
  }
}
