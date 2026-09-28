// 不用模糊菜名硬配照片，防止把不同主料或不同烹调方式混在一起。
const photoName = value => value.replace(/[\s·（）()\-]/g,'').toLowerCase();
function libraryPhoto(recipe) {
  const names = recipe.items.map(item => photoName(Array.isArray(item) ? item[0] : item.name));
  return PHOTO_LIBRARY.find(photo => [photo.name,...photo.aliases].some(name => photoName(name) === photoName(recipe.name)) &&
    photo.methods.includes(recipe.method) && photo.ingredientGroups.every(group => group.some(alias => names.includes(photoName(alias)))));
}
function assignRecipePhoto(recipe) {
  const photo = libraryPhoto(recipe);
  if (photo) {
    recipe.image = photo.file;
    recipe.photoCredit = {name:photo.name,author:photo.author,license:photo.license,licenseUrl:photo.licenseUrl,sourcePage:photo.sourcePage};
  }
  return recipe;
}
