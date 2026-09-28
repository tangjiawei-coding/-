import { PHOTO_LIBRARY } from '../model/PhotoLibrary';
import { Recipe, RecipeItem, PhotoCredit } from '../model/RecipeCatalog';

function normalize(value: string): string { return value.replace(/[\s·（）()\-]/g, '').toLowerCase(); }

export function assignRecipePhoto(recipe: Recipe): Recipe {
  const names = recipe.items.map((item: RecipeItem) => normalize(item.name));
  const photo = PHOTO_LIBRARY.find(photo =>
    [photo.name].concat(photo.aliases).some((name: string) => normalize(name) === normalize(recipe.name)) &&
    photo.methods.includes(recipe.method) &&
    photo.ingredientGroups.every((group: string[]) => group.some((alias: string) => names.includes(normalize(alias)))));
  if (photo) {
    recipe.image = photo.file;
    const credit: PhotoCredit = { name: photo.name, author: photo.author, license: photo.license,
      licenseUrl: photo.licenseUrl, sourcePage: photo.sourcePage };
    recipe.photoCredit = credit;
  }
  return recipe;
}
