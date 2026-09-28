import { common } from '@kit.AbilityKit';
import { assignRecipePhoto } from './RecipePhotoService';
import { preferences } from '@kit.ArkData';
import { RECIPES, Recipe, FOODS, FoodExample } from '../model/RecipeCatalog';

interface AiCatalog { foods: FoodExample[]; recipes: Recipe[]; }

function mergeCatalog(catalog: AiCatalog): void {
  catalog.foods.forEach((food: FoodExample) => {
    const index = FOODS.findIndex((item: FoodExample) => item.id === food.id);
    if (index < 0) { FOODS.push(food); } else { FOODS[index] = food; }
  });
  catalog.recipes.forEach((recipe: Recipe) => {
    assignRecipePhoto(recipe);
    const index = RECIPES.findIndex((item: Recipe) => item.id === recipe.id);
    if (index < 0) { RECIPES.push(recipe); } else { RECIPES[index] = recipe; }
  });
}

// 与旧食材篮使用独立存储；只记录想做的菜，不写入做饭记录。
export class TodayMenuStore {
  private store: preferences.Preferences | undefined = undefined;

  async open(context: common.UIAbilityContext): Promise<string[]> {
    this.store = await preferences.getPreferences(context, { name: 'today_menu_v1' });
    const catalog = JSON.parse(await this.store.get('ai_catalog', '{"foods":[],"recipes":[]}') as string) as AiCatalog;
    mergeCatalog(catalog);
    const ids = JSON.parse(await this.store.get('recipe_ids', '[]') as string) as string[];
    return ids.filter((id: string, index: number) =>
      ids.indexOf(id) === index && RECIPES.some((recipe: Recipe) => recipe.id === id));
  }

  async remember(food: FoodExample, recipes: Recipe[]): Promise<void> {
    if (!this.store) { throw new Error('菜单存储尚未就绪，请重新读取菜单'); }
    mergeCatalog({ foods: [food], recipes });
    const catalog: AiCatalog = {
      foods: FOODS.filter((item: FoodExample) => item.id.startsWith('ai-')),
      recipes: RECIPES.filter((item: Recipe) => item.id.startsWith('ai-'))
    };
    await this.store.put('ai_catalog', JSON.stringify(catalog));
    await this.store.flush();
  }

  async save(ids: string[]): Promise<void> {
    if (!this.store) { throw new Error('今日菜单尚未就绪'); }
    await this.store.put('recipe_ids', JSON.stringify(ids));
    await this.store.flush();
  }
}
