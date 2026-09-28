// 网页示例为数据源，同步到 ArkTS，避免两份菜谱分别修改。
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const root = path.resolve(__dirname, '..');
const preview = path.join(root, 'web-demo/ui-preview');
const native = path.join(root, 'harmonyos/VegiSmart/entry/src/main');
const context = vm.createContext({});
vm.runInContext(fs.readFileSync(path.join(preview, 'data.js'), 'utf8') + ';globalThis.catalog={ingredients,recipes,foods}', context);
const { ingredients, recipes, foods } = context.catalog;
vm.runInContext(fs.readFileSync(path.join(preview, 'photo-library.js'), 'utf8') + '\n' + fs.readFileSync(path.join(preview, 'photo-match.js'), 'utf8') + ';recipes.forEach(assignRecipePhoto)', context);
for (const food of foods) food.image = recipes.find(recipe => recipe.id === food.recipeIds[0]).image;
const schema = `// 由 scripts/sync-recipe-catalog.cjs 同步固定示例；AI 结果通过 KitchenService 动态追加。
export interface IngredientInfo { name: string; category: string; description: string; preparation: string; }
export interface RecipeItem { name: string; amount: string; group: string; }
export interface RecipeStep { title: string; description: string; }
export interface PhotoCredit { name: string; author: string; license: string; licenseUrl: string; sourcePage: string; }
export interface Recipe {
  id: string; name: string; subtitle: string; pairing: string; image: string; time: string; method: string;
  ingredientInfos?: IngredientInfo[]; photoCredit?: PhotoCredit;
  items: RecipeItem[]; steps: RecipeStep[]; story: string; source: string; sourceName: string;
}
export interface FoodExample {
  id: string; name: string; aliases: string[]; subtitle: string; summary: string; image: string;
  recipeIds: string[]; storage: string; pairing: string; description: string; preparation: string;
}
`;
const infos = Object.entries(ingredients).map(([name, info]) => ({ name, category:info[0], description:info[1], preparation:info[2] }));
const data = recipes.map(recipe => ({ ...recipe,
  items:recipe.items.map(item => ({ name:item[0], amount:item[1], group:item[2] })),
  steps:recipe.steps.map(step => ({ title:step[0], description:step[1] }))
}));
const examples = foods.map(food => ({ ...food, description:ingredients[food.name][1], preparation:ingredients[food.name][2] }));
const declaration = (name, type, value) => `\nexport const ${name}: ${type}[] = ${JSON.stringify(value,null,2)};\n`;
fs.writeFileSync(path.join(native,'ets/model/RecipeCatalog.ets'), schema + declaration('INGREDIENTS','IngredientInfo',infos) +
  declaration('RECIPES','Recipe',data) + declaration('FOODS','FoodExample',examples) +
  '\nexport function recipeById(id: string): Recipe {\n  return RECIPES.find((recipe: Recipe) => recipe.id === id) || RECIPES[0];\n}\n');
for (const image of new Set([...recipes.map(recipe => recipe.image),...foods.map(food => food.image)])) {
  fs.mkdirSync(path.dirname(path.join(native,'resources/rawfile',image)), { recursive:true });
  fs.copyFileSync(path.join(preview,'assets',image), path.join(native,'resources/rawfile',image));
}
console.log(`已同步 ${foods.length} 种食材、${recipes.length} 道菜。`);
