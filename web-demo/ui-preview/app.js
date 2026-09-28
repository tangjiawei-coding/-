const paths = {
  leaf: '<path d="M19 4C10 3 4 7 5 14c1 6 10 7 13 1 2-4 1-8 1-11Z"/><path d="M4 21 15 9M8 17l-1-6m5 2 5 1"/>',
  camera: '<path d="m8 5 1-2h6l1 2h3a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V7a2 2 0 0 1 2-2Z"/><circle cx="12" cy="13" r="4"/>',
  arrow: '<path d="M4 12h15m-5-5 5 5-5 5"/>',
  chevron: '<path d="m9 5 7 7-7 7"/>',
  image: '<rect x="3" y="3" width="18" height="18" rx="4"/><circle cx="8" cy="8" r="1.5"/><path d="m3 17 5-5 4 4 4-6 5 7"/>',
  search: '<circle cx="10.5" cy="10.5" r="7"/><path d="m16 16 5 5"/>',
  scan: '<path d="M8 3H5a2 2 0 0 0-2 2v3m13-5h3a2 2 0 0 1 2 2v3M3 16v3a2 2 0 0 0 2 2h3m8 0h3a2 2 0 0 0 2-2v-3"/><path d="M16 7c-7-1-10 5-6 8 4 3 7-2 6-8Z"/><path d="m8 17 5-6"/>',
  menu: '<path d="M5 5h14v15H5zM9 3v4m6-4v4M8 11h8M8 15h5"/>',
  user: '<circle cx="12" cy="8" r="4"/><path d="M4 21v-2a8 8 0 0 1 16 0v2"/>',
  close: '<path d="m6 6 12 12M6 18 18 6"/>',
  bowl: '<path d="M3 12h18c-1 6-4 8-9 8s-8-2-9-8ZM8 22h8M8 8c-3-3 2-3 0-6m5 6c-3-3 2-3 0-6m5 6c-3-3 2-3 0-6"/>',
  spark: '<path d="m12 2 2.5 7.5L22 12l-7.5 2.5L12 22l-2.5-7.5L2 12l7.5-2.5Z"/>'
};
const icon = name => `<svg viewBox="0 0 24 24" aria-hidden="true">${paths[name] || ''}</svg>`;
function fillIcons(root = document) {
  root.querySelectorAll('[data-icon]').forEach(el => el.innerHTML = icon(el.dataset.icon));
}
fillIcons();
const $ = selector => document.querySelector(selector);
const escapeHtml = value => String(value).replace(/[&<>"']/g, char => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[char]));
recipes.forEach(assignRecipePhoto);
for (const food of foods) food.image = recipes.find(recipe => recipe.id === food.recipeIds[0]).image;
const sampleFoods = foods.slice();
let libraryPageIndex = 0;
const aiCatalogKey = 'vegismart-ai-catalog-v1';
function mergeCatalog(catalog) {
  for (const food of catalog.foods) {
    const index = foods.findIndex(item => item.id === food.id);
    if (index < 0) foods.push(food); else foods[index] = food;
    ingredients[food.name] = [food.subtitle,food.description,food.preparation];
  }
  for (const recipe of catalog.recipes) {
    assignRecipePhoto(recipe);
    const index = recipes.findIndex(item => item.id === recipe.id);
    if (index < 0) recipes.push(recipe); else recipes[index] = recipe;
  }
}
try {
  const saved = JSON.parse(localStorage.getItem(aiCatalogKey));
  if (saved?.foods && saved?.recipes) mergeCatalog(saved);
} catch { /* 首次使用没有 AI 菜谱缓存。 */ }
function rememberResult(result) {
  const generated = result.recipes.map(recipe => ({...recipe,
    items:recipe.items.map(item=>[item.name,item.amount,item.group]),
    steps:recipe.steps.map(step=>[step.title,step.description])
  }));
  mergeCatalog({foods:[result.food],recipes:generated});
  try {
    localStorage.setItem(aiCatalogKey,JSON.stringify({foods:foods.filter(food=>food.id.startsWith('ai-')),
      recipes:recipes.filter(recipe=>recipe.id.startsWith('ai-'))}));
  } catch { notify('本次结果可查看，但本机空间不足，暂时无法保存。'); }
}

const storageKey = 'vegismart-preview-menu-v2';
function readMenu() {
  try { return [...new Set(JSON.parse(localStorage.getItem(storageKey)) || [])].filter(id => recipes.some(r => r.id === id)); }
  catch { return []; }
}
let menu = readMenu();
let objectUrl = null;
let lastFocus = null;
let removed = null;
let undoTimer;
let pendingPhoto = '';
let analysisController = null;
let lastRequest = null;
let menuPageIndex = 0;
let materialPageIndex = 0;
let sheetRecipeId = null;
const stepPositions = new Map();
const dialog = $('#sheet');
const scrollPositions = new Map();
let currentRoute = '';
let selectedFood = foods[0];
const initialState = new URLSearchParams(location.search).get('state');
if (initialState) {
  menu = initialState === 'filled' ? ['garlic'] : [];
  const url = new URL(location.href);
  url.searchParams.delete('state');
  history.replaceState(null, '', url);
}
$('.review-tools > span').innerHTML = '交互样板 <i>02</i>';
const demoButton = document.createElement('button');
demoButton.id = 'demo-entry';
demoButton.innerHTML = `<span>先找一点做菜灵感</span><strong>4 种食材 · 12 道菜 ${icon('arrow')}</strong>`;
demoButton.className = 'demo-entry';
$('.secondary-actions').after(demoButton);
const lookup = id => recipes.find(r => r.id === id);
const photo = r => `<img src="assets/${r.image}" alt="${escapeHtml(r.name)}${r.image.endsWith('.svg') ? '插画' : '搭配示意照片'}">`;
const empty = () => `<div class="empty-menu"><span class="empty-illustration">${icon('bowl')}</span><div><h3>今天还没选菜</h3><p>认识一种食材，<br>发现一道想做的菜。</p></div></div>`;
const compactCard = r => `<button class="recipe-preview" data-recipe="${r.id}">${photo(r)}<span class="recipe-copy"><small>今天想做</small><h3>${escapeHtml(r.name)}</h3><p>${escapeHtml(r.pairing)}</p></span>${icon('chevron')}</button>`;
function saveMenu() {
  try { localStorage.setItem(storageKey, JSON.stringify(menu)); }
  catch { notify('本机保存失败，关闭页面后菜单可能丢失。'); }
  $('#menu-preview').textContent = menu.length ? menu.map(id => lookup(id).name).join('、') : '把今天想做的菜放在这里';
  $('#menu-count').textContent = menu.length ? `· 已选 ${menu.length} 道` : '';
  $('#nav-badge').hidden = !menu.length;
  $('#nav-badge').textContent = menu.length;
  document.querySelectorAll('[data-state]').forEach(b => b.setAttribute('aria-pressed', String((b.dataset.state === 'filled') === !!menu.length)));
}
function notify(text, undo = false) {
  $('#toast').textContent = text;
  if (undo) {
    const button = document.createElement('button');
    button.textContent = '撤销'; button.dataset.undo = '';
    $('#toast').append(button);
  }
  $('#toast').classList.add('visible');
  clearTimeout(notify.timer);
  notify.timer = setTimeout(() => $('#toast').classList.remove('visible'), undo ? 5000 : 2600);
}
function openSheet(title, html) {
  if (!dialog.open) lastFocus = document.activeElement;
  $('#sheet-title').textContent = title;
  $('#sheet-body').innerHTML = html;
  fillIcons(dialog);
  if (!dialog.open) dialog.showModal();
  dialog.scrollTop = 0;
}
function closeSheet() { dialog.close(); }
$('#close-sheet').onclick = closeSheet;
dialog.addEventListener('click', e => {
  const box = dialog.getBoundingClientRect();
  if (e.target === dialog && (e.clientX < box.left || e.clientX > box.right || e.clientY < box.top || e.clientY > box.bottom)) closeSheet();
});
dialog.addEventListener('close', () => {
  if (analysisController) { analysisController.abort(); analysisController = null; }
  pendingPhoto = '';
  lastRequest = null;
  sheetRecipeId = null;
  if (objectUrl) { URL.revokeObjectURL(objectUrl); objectUrl = null; }
  if (lastFocus?.isConnected) lastFocus.focus({ preventScroll:true });
});
function go(route) {
  if (dialog.open) closeSheet();
  if (location.hash === `#${route}`) renderRoute();
  else location.hash = route;
}
function pageHeader(title, generated = false) {
  return `<header class="page-header"><button data-back aria-label="返回上一页">${icon('arrow')}</button><span>${title}</span><span class="demo-label">${generated ? 'AI 建议' : '示例'}</span></header>`;
}
function creditContent(photo) {
  return `<p class="small-note">成品参考照片，实际配料和摆盘以菜谱为准。</p><p>摄影：${escapeHtml(photo.author)}</p><p><a href="${escapeHtml(photo.licenseUrl)}" target="_blank" rel="noopener">${escapeHtml(photo.license)}</a> · <a href="${escapeHtml(photo.sourcePage)}" target="_blank" rel="noopener">查看原图与来源 ↗</a></p>`;
}
function showLibrary(index = 0) {
  libraryPageIndex = index;
  openSheet('菜品图库', `<p class="sheet-context">${PHOTO_LIBRARY.length} 道家常菜 · 已收录的成品参考照片</p><div class="example-grid">${PHOTO_LIBRARY.slice(index*4,index*4+4).map(photo=>`<button data-library-photo="${photo.id}"><img src="assets/${photo.file}" alt="${escapeHtml(photo.name)}"><span><strong>${escapeHtml(photo.name)}</strong><small>查看图片与来源 ↗</small></span></button>`).join('')}</div>${pager(index,Math.ceil(PHOTO_LIBRARY.length/4),'data-library')}`);
}
function showLibraryPhoto(id) {
  const photo = PHOTO_LIBRARY.find(item=>item.id===id);
  openSheet(photo.name, `<img class="chosen-photo" src="assets/${photo.file}" alt="${escapeHtml(photo.name)}">${creditContent(photo)}<button class="outline-button" data-library="${libraryPageIndex}">返回图库</button>`);
}
function showExamples() {
  openSheet('从哪种食材开始？', `<p class="sheet-context">4 种常见食材，每种发现三道家常菜。</p><div class="example-grid">${sampleFoods.map(food => `<button data-food="${food.id}"><img src="assets/${food.image}" alt=""><span><strong>${escapeHtml(food.name)}</strong><small>三种家常做法 ${icon('arrow')}</small></span></button>`).join('')}</div><p class="small-note">固定示例 · 拍照或搜索可认识更多食材</p>`);
}
function resultPage() {
  const food = selectedFood;
  return `${pageHeader('认识食材', food.id.startsWith('ai-'))}
  <section class="ingredient-card"><div class="ingredient-title"><span class="ingredient-emblem">${icon('leaf')}</span><div><h2>${escapeHtml(food.name)}</h2><p>${escapeHtml(food.subtitle)}</p></div><button class="text-button" data-correct>更正</button></div><p class="ingredient-summary">${escapeHtml(food.summary)}</p><div class="ingredient-bottom"><button class="text-button" data-examples>换种食材 ${icon('arrow')}</button><button class="text-button" data-knowledge="0">认识更多 ${icon('chevron')}</button></div></section>
  <div class="section-heading recommendations-heading"><h2>可以做这三道</h2><span class="small-note">一种食材，三种滋味</span></div><div class="recommendations">${food.recipeIds.map(id => lookup(id)).map((r,i) => `<button class="dish-card" data-recipe="${r.id}"><div class="dish-photo">${photo(r)}<span>0${i+1} / ${escapeHtml(r.method)}</span></div><div class="dish-copy"><h3>${escapeHtml(r.name)}${icon('arrow')}</h3><p>${escapeHtml(r.subtitle)}</p><span class="pairing">${escapeHtml(r.pairing)}</span></div></button>`).join('')}</div><p class="page-note">家常做法参考 · 用量可按口味调整</p>`;
}
function recipePage(r) {
  return `${pageHeader('菜谱详情', r.id.startsWith('ai-'))}<div class="recipe-cover">${photo(r)}<button class="photo-credit" data-photo-credit="${r.id}">${r.photoCredit ? '成品参考 · 图片来源 ↗' : '菜谱示意 · 非实拍'}</button></div><div class="recipe-title"><span class="eyebrow">${escapeHtml(r.method)} / 家常灵感</span><h1>${escapeHtml(r.name)}</h1><p>${escapeHtml(r.subtitle)}</p><div class="recipe-meta"><span>2 人份</span><span>${escapeHtml(r.time)}</span></div></div>
  <div class="recipe-entry-list"><button data-section="materials"><span class="entry-symbol">${icon('menu')}</span><span><strong>准备食材</strong><small>${r.items.length} 项用料 · 查看用量与介绍</small></span>${icon('chevron')}</button><button data-section="steps"><span class="entry-symbol">${icon('bowl')}</span><span><strong>分步做法</strong><small>${r.steps.length} 个步骤 · 一步一步看</small></span>${icon('chevron')}</button><button data-section="story"><span class="entry-symbol">${icon('leaf')}</span><span><strong>菜品故事</strong><small>了解这道菜的家常滋味</small></span>${icon('chevron')}</button></div><p class="page-note">点击展开，关闭即回到这里</p><div class="recipe-cta"><button class="primary" data-add="${r.id}">${menu.includes(r.id) ? '已加入 · 查看今日菜单' : '加入今日菜单'}${icon(menu.includes(r.id) ? 'arrow' : 'menu')}</button></div>`;
}
function pager(index, count, attribute) {
  return `<div class="sheet-pager"><button ${index === 0 ? 'disabled' : ''} ${attribute}="${index-1}">上一页</button><span>${index+1} / ${count}</span><button ${index === count-1 ? 'disabled' : ''} ${attribute}="${index+1}">下一页</button></div>`;
}
function showMaterials(id, index = 0) {
  sheetRecipeId = id;
  materialPageIndex = index;
  const r = lookup(id), count = Math.ceil(r.items.length / 4);
  openSheet('准备食材', `<p class="sheet-context">${escapeHtml(r.name)} · 2 人份参考用量</p><div class="material-page">${r.items.slice(index*4,index*4+4).map(item => `<button class="ingredient-row" data-ingredient="${escapeHtml(item[0])}"><span>${escapeHtml(item[0])}<small>${escapeHtml(item[2])}</small></span><span>${escapeHtml(item[1])}${icon('chevron')}</span></button>`).join('')}</div><p class="small-note">点击任一食材，查看介绍与处理方法。</p>${count > 1 ? pager(index,count,'data-material-page') : ''}`);
}
function showStep(id, index = stepPositions.get(id) || 0) {
  sheetRecipeId = id;
  stepPositions.set(id,index);
  const r = lookup(id), step = r.steps[index];
  openSheet('分步做法', `<p class="sheet-context">${escapeHtml(r.name)}</p><div class="step-progress" aria-label="第 ${index+1} 步，共 ${r.steps.length} 步">${r.steps.map((_,i) => `<span class="${i<=index?'complete':''}"></span>`).join('')}</div><div class="single-step"><span class="eyebrow">STEP ${String(index+1).padStart(2,'0')} / ${String(r.steps.length).padStart(2,'0')}</span><h3>${escapeHtml(step[0])}</h3><p>${escapeHtml(step[1])}</p></div><div class="sheet-pager"><button data-step="${index-1}" ${index===0?'disabled':''}>上一步</button><span>${index+1} / ${r.steps.length}</span>${index < r.steps.length-1 ? `<button data-step="${index+1}">下一步</button>` : '<button data-close-sheet>看完了</button>'}</div>`);
}
function showKnowledge(index = 0) {
  const food = selectedFood, info = ingredients[food.name];
  const pages = [
    `<h3>认识${escapeHtml(food.name)}</h3><p>${escapeHtml(info[1])}</p><h3>下锅之前</h3><p>${escapeHtml(info[2])}</p>`,
    `<h3>怎么保存</h3><p>${escapeHtml(food.storage)}</p><h3>怎么搭配</h3><p>${escapeHtml(food.pairing)}</p>`
  ];
  openSheet('食材小知识', `<div class="knowledge-page">${pages[index]}</div>${pager(index,2,'data-knowledge')}`);
}
function menuPage() {
  const count = Math.ceil(menu.length / 2);
  menuPageIndex = Math.min(menuPageIndex,Math.max(0,count-1));
  return `<div class="page-intro"><span class="eyebrow">把想吃的，变成今天的期待</span><h1>今日菜单<span class="count-pill">${menu.length} 道</span></h1><p>今天想做的菜，都放在这里。</p></div>${menu.length ? `<div class="menu-list">${menu.slice(menuPageIndex*2,menuPageIndex*2+2).map(id => `<article class="menu-item">${compactCard(lookup(id))}<div class="menu-item-foot"><span>计划做 · 2 人份参考</span><button data-remove="${id}" aria-label="移除${escapeHtml(lookup(id).name)}">移除</button></div></article>`).join('')}</div>${count>1?pager(menuPageIndex,count,'data-menu-page'):''}<button class="outline-button" data-examples>再选一道菜 ${icon('arrow')}</button><p class="page-note">加入代表“想做”，不会记作“做过” · 仅本机保存</p>` : `${empty()}<button class="primary empty-cta" data-route="home">去认识一种食材 ${icon('arrow')}</button>`}`;
}
function renderRoute() {
  if (dialog.open) closeSheet();
  const route = location.hash.slice(1) || 'home';
  const [page, id] = route.split('/');
  if (!['home','result','recipe','menu','me'].includes(page) || (page === 'recipe' && !lookup(id))) { go('home'); return; }
  if (currentRoute && currentRoute !== route) scrollPositions.set(currentRoute, window.scrollY);
  currentRoute = route;
  if (page === 'result') selectedFood = foods.find(food => food.id === id) || selectedFood;
  if (page === 'recipe') selectedFood = foods.find(food => food.recipeIds.includes(id)) || selectedFood;
  $('#home-page').hidden = page !== 'home';
  $('#route-page').hidden = page === 'home';
  $('.brand').hidden = page === 'result' || page === 'recipe';
  $('.bottom-nav').hidden = page === 'result' || page === 'recipe';
  $('.app').classList.toggle('detail-mode', page === 'recipe');
  $('.app').classList.toggle('home-mode', page === 'home');
  document.querySelectorAll('.bottom-nav button').forEach(b => {
    const active = b.id === ({home:'nav-home',menu:'nav-menu',me:'nav-me'}[page]);
    b.classList.toggle('active',active);
    if (active) b.setAttribute('aria-current','page'); else b.removeAttribute('aria-current');
  });
  if (page === 'result') $('#route-page').innerHTML = resultPage();
  if (page === 'recipe') $('#route-page').innerHTML = recipePage(lookup(id));
  if (page === 'menu') $('#route-page').innerHTML = menuPage();
  if (page === 'me') $('#route-page').innerHTML = `<div class="page-intro"><span class="eyebrow">慢慢积累你的餐桌灵感</span><h1>我的</h1><p>这一阶段先把认识食材到选菜的体验做好。</p></div><div class="content-card"><h2>之后在这里相见</h2><p>收藏菜谱、识别历史、做饭记录与偏好设置，将在后续原生版本中逐步完善。</p><p class="small-note">账号与云同步方式待讨论。</p><button class="outline-button" data-library="0">菜品图库 · ${PHOTO_LIBRARY.length} 道</button><button class="outline-button" data-route="home">回到识菜</button></div>`;
  document.title = `菜小智 · ${{home:'识菜',result:`认识${selectedFood.name}`,recipe:lookup(id)?.name,menu:'今日菜单',me:'我的'}[page]}`;
  saveMenu();
  requestAnimationFrame(() => window.scrollTo(0, scrollPositions.get(route) || 0));
}
window.addEventListener('hashchange', renderRoute);
document.querySelectorAll('[data-state]').forEach(b => b.onclick = () => {
  menu = b.dataset.state === 'filled' ? ['garlic'] : [];
  renderRoute(); notify('已切换样板菜单状态');
});
$('#take-photo').onclick = () => $('#camera-file').click();
$('#choose-photo').onclick = () => $('#album-file').click();
for (const id of ['camera-file','album-file']) {
  $('#' + id).addEventListener('change', async e => {
    const file = e.target.files[0];
    if (!file) return;
    if (!file.type.startsWith('image/')) { notify('请选择一张图片'); e.target.value = ''; return; }
    try {
      pendingPhoto = await kitchenApi.photoData(file);
      objectUrl = URL.createObjectURL(file);
      openSheet('看看这份食材', `<img class="chosen-photo" src="${objectUrl}" alt="你选择的食材照片"><p>让 AI 认识它，再找三种家常做法。</p><p class="small-note">开始后将发送这张照片用于本次分析。</p><button class="primary" data-analyze-photo>开始识别 ${icon('arrow')}</button>`);
    } catch(error) { notify(error.message); }
    e.target.value = '';
  });
}
function showSearch(correct = false) {
  openSheet(correct ? '更正食材名称' : '想认识哪种食材？', `<form id="search-form"><label class="search-field">${icon('search')}<input id="search-input" maxlength="40" placeholder="输入一种食材，如茄子、南瓜" aria-label="食材名称" autocomplete="off"></label><div class="suggestions">${sampleFoods.map(food => `<button type="button" data-query="${escapeHtml(food.name)}">${escapeHtml(food.name)}</button>`).join('')}</div><button class="primary" type="submit">认识它，找三道菜</button><p id="search-feedback" role="status"></p></form><p class="small-note">AI 会整理食材介绍、用料和分步做法。</p>`);
  $('#search-input').focus();
  $('#search-form').onsubmit = e => {
    e.preventDefault();
    const query = $('#search-input').value.trim();
    if (query) analyze({name:query});
    else $('#search-feedback').textContent = '先输入想认识的食材名称。';
  };
}
async function analyze(request) {
  if (analysisController) return;
  lastRequest = request;
  const controller = new AbortController();
  analysisController = controller;
  openSheet('正在认识这份食材', `<div class="analysis-state" role="status"><span class="analysis-symbol">${icon('leaf')}</span><h3>给今天的餐桌找点灵感</h3><p>正在整理食材介绍和三道家常菜，<br>可能需要几十秒，请稍候。</p></div><button class="outline-button" data-close-sheet>取消</button>`);
  let timedOut = false;
  const timer = setTimeout(()=>{timedOut=true;controller.abort();},165000);
  try {
    const result = await kitchenApi.explore(request,controller.signal);
    if (controller.signal.aborted) return;
    analysisController = null;
    lastRequest = null;
    if (result.status === 'needs_input') {
      openSheet('还需要一点线索', `<div class="knowledge-page"><p>${escapeHtml(result.message)}</p></div><button class="primary" data-new-search>手动输入食材</button><button class="outline-button" data-close-sheet>重新选照片</button>`);
      return;
    }
    rememberResult(result);
    go(`result/${result.food.id}`);
  } catch(error) {
    if (error.name === 'AbortError' && !timedOut) return;
    analysisController = null;
    openSheet('这次没有分析成功', `<div class="knowledge-page"><p>${escapeHtml(timedOut ? '等待时间较长，请稍后重试。' : error.message)}</p></div><button class="primary" data-retry-analysis>重新分析</button><button class="outline-button" data-new-search>换个食材名称</button>`);
  } finally { clearTimeout(timer); if (analysisController === controller) analysisController = null; }
}
$('#open-search').onclick = () => showSearch();
$('#demo-entry').onclick = showExamples;
$('#view-menu').onclick = $('#nav-menu').onclick = () => go('menu');
$('#nav-home').onclick = () => go('home');
$('.brand-name').onclick = e => { e.preventDefault(); go('home'); };
$('#nav-me').onclick = () => go('me');
$('#about-preview').onclick = () => openSheet('关于这份交互样板', `<span class="tag">4 种食材 · 12 道家常菜</span><p>认识食材 → 三道推荐菜 → 完整菜谱 → 今日菜单。点击开始识别后，照片会发送给模型服务分析；菜单只保存在本浏览器。</p><p>菜品照片保存在本地图库，并保留作者和授权说明；暂无匹配照片的菜谱使用原创示意插画。</p><p><button class="text-button" data-library="0">查看菜品图库与图片来源</button></p>`);
document.addEventListener('click', e => {
  const target = e.target.closest('button');
  if (!target) return;
  if (target.hasAttribute('data-library')) showLibrary(Number(target.dataset.library));
  if (target.hasAttribute('data-library-photo')) showLibraryPhoto(target.dataset.libraryPhoto);
  if (target.hasAttribute('data-photo-credit')) {
    const recipe = lookup(target.dataset.photoCredit);
    openSheet('图片说明', recipe.photoCredit ? creditContent(recipe.photoCredit) : '<p>本项目原创示意插画，非菜品实拍照片。</p>');
  }
  if (target.hasAttribute('data-analyze-photo')) analyze({imageDataUrl:pendingPhoto});
  if (target.hasAttribute('data-retry-analysis') && lastRequest) analyze(lastRequest);
  if (target.hasAttribute('data-new-search')) showSearch();
  if (target.hasAttribute('data-examples')) showExamples();
  if (target.hasAttribute('data-food')) go(`result/${target.dataset.food}`);
  if (target.hasAttribute('data-route')) go(target.dataset.route);
  if (target.hasAttribute('data-recipe')) go(`recipe/${target.dataset.recipe}`);
  if (target.hasAttribute('data-back')) {
    // 页面内打开的详情可用浏览器返回；直接访问时提供确定的上级入口。
    if (scrollPositions.size) history.back(); else go(currentRoute.startsWith('recipe/') ? 'result' : 'home');
  }
  if (target.hasAttribute('data-close-sheet')) closeSheet();
  if (target.hasAttribute('data-knowledge')) showKnowledge(Number(target.dataset.knowledge));
  if (target.hasAttribute('data-material-page')) showMaterials(sheetRecipeId,Number(target.dataset.materialPage));
  if (target.hasAttribute('data-step')) showStep(sheetRecipeId,Number(target.dataset.step));
  if (target.hasAttribute('data-material-back')) showMaterials(sheetRecipeId,materialPageIndex);
  if (target.hasAttribute('data-menu-page')) { menuPageIndex=Number(target.dataset.menuPage); renderRoute(); }
  if (target.hasAttribute('data-section')) {
    const r = lookup(currentRoute.split('/')[1]);
    if (target.dataset.section === 'materials') showMaterials(r.id);
    if (target.dataset.section === 'steps') showStep(r.id);
    if (target.dataset.section === 'story') openSheet('菜品故事', `<span class="tag">${escapeHtml(r.name)}</span><div class="knowledge-page"><p>${escapeHtml(r.story)}</p></div>${r.source ? `<a class="source-link" href="${r.source}" target="_blank" rel="noopener">参考：${escapeHtml(r.sourceName)} ↗</a>` : '<p class="small-note">家常做法参考 · 可按口味调整</p>'}`);
  }
  if (target.hasAttribute('data-correct')) showSearch(true);
  if (target.hasAttribute('data-query')) { $('#search-input').value = target.dataset.query; $('#search-input').focus(); }
  if (target.hasAttribute('data-ingredient')) {
    const name = target.dataset.ingredient;
    const ownInfo = lookup(sheetRecipeId)?.ingredientInfos?.find(item=>item.name===name);
    const info = ownInfo ? [ownInfo.category,ownInfo.description,ownInfo.preparation] : ingredients[name];
    openSheet(name, `<span class="tag">${escapeHtml(info[0])}</span><p>${escapeHtml(info[1])}</p><h3>下锅之前</h3><p>${escapeHtml(info[2])}</p><button class="outline-button" data-material-back>返回用料表</button>`);
  }
  if (target.hasAttribute('data-add')) {
    const id = target.dataset.add;
    if (menu.includes(id)) { go('menu'); return; }
    menu.push(id); saveMenu();
    target.innerHTML = `已加入 · 查看今日菜单${icon('arrow')}`;
    notify('已加入今日菜单');
  }
  if (target.hasAttribute('data-remove')) {
    const id = target.dataset.remove;
    removed = {id,index:menu.indexOf(id)};
    menu = menu.filter(value => value !== id);
    renderRoute(); notify('已移出今日菜单',true);
    clearTimeout(undoTimer); undoTimer = setTimeout(() => { removed = null; },5000);
  }
  if (target.hasAttribute('data-undo') && removed) {
    if (!menu.includes(removed.id)) menu.splice(removed.index,0,removed.id);
    removed = null; clearTimeout(undoTimer); renderRoute(); notify('已恢复到今日菜单');
  }
});
renderRoute();
