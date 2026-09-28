const app = document.querySelector('#app');
const toast = document.querySelector('#toast');
const modalRoot = document.querySelector('#modal-root');

const state = {
  route: 'home',
  scanning: false,
  recognized: false,
  people: 2,
  budget: '30元内',
  meal: '',
  shopping: [
    { name: '番茄', amount: '300g', price: 3.2, checked: false },
    { name: '鸡蛋', amount: '3枚', price: 4.5, checked: false },
    { name: '嫩豆腐', amount: '200g', price: 3.8, checked: false },
    { name: '小油菜', amount: '250g', price: 4.2, checked: false },
    { name: '香菇', amount: '120g', price: 5.6, checked: false },
    { name: '葱姜', amount: '1份', price: 2.3, checked: false },
  ],
};

const money = value => `¥${value.toFixed(1)}`;

function showToast(message) {
  toast.textContent = message;
  toast.classList.add('show');
  window.clearTimeout(showToast.timer);
  showToast.timer = window.setTimeout(() => toast.classList.remove('show'), 1800);
}

function header(title = '菜小智', note = '让每一次买菜更有把握') {
  return `
    <div class="topline">
      <div><div class="brand">${title}</div><div class="eyebrow">${note}</div></div>
      <button class="icon-button" data-action="open-chat" aria-label="AI助手">✦</button>
    </div>`;
}

function homePage() {
  return `
    ${header()}
    <section class="hero-card veg-hero">
      <div class="hero-copy">
        <div class="eyebrow">AI 线下生鲜决策助手</div>
        <div class="hero-title">从看见食材，到会买、会搭、会做</div>
        <p class="hero-note">识别新鲜度、参考价格，结合库存与饮食目标生成一餐方案。</p>
        <button class="primary-button green" data-action="start-recognize">拍照识菜</button>
      </div>
    </section>

    <div class="section-title-row"><h3>今天买什么</h3><button class="text-button" data-route="pairing">去搭配 →</button></div>
    <div class="fresh-strip">
      <button class="fresh-item" data-action="start-recognize"><span>📷</span><strong>现场识别</strong><small>新鲜度与价格</small></button>
      <button class="fresh-item" data-route="pairing"><span>🥗</span><strong>智能搭配</strong><small>补全一餐</small></button>
      <button class="fresh-item" data-route="list"><span>🧺</span><strong>购物清单</strong><small>预算不超支</small></button>
    </div>

    <div class="section-title-row"><h3>为你推荐</h3><span class="eyebrow">2人 · 30元内</span></div>
    <section class="meal-card">
      <div class="meal-head">
        <div><div class="meal-title">番茄豆腐轻食餐</div><div class="meal-tags"><span class="pill">营养均衡</span><span class="pill">新手友好</span></div></div>
        <strong>88分</strong>
      </div>
      <div class="meal-ingredients">
        <div class="meal-ingredient"><span>🍅</span>番茄</div>
        <div class="meal-ingredient"><span>🥚</span>鸡蛋</div>
        <div class="meal-ingredient"><span>🥬</span>小油菜</div>
      </div>
      <button class="primary-button full green" data-route="pairing">生成我的一餐</button>
    </section>

    <div class="advice-card">
      <div class="advice-icon">⏳</div>
      <div><strong>库存提醒</strong><span>嫩豆腐预计明天到期，建议优先加入今晚菜单。</span></div>
    </div>`;
}

function recognizePage() {
  if (state.scanning) {
    return `
      ${header('食材识别', 'AI 正在分析')}
      <section class="loading-panel">
        <div class="loading-orb"></div>
        <h2>正在理解这份食材</h2>
        <p class="subtle">综合色泽、表皮、形态与规则库给出可解释建议</p>
        <div class="loading-lines">
          <div class="loading-row done"><span>食材类别识别</span><b>完成</b></div>
          <div class="loading-row done"><span>可见新鲜度特征</span><b>完成</b></div>
          <div class="loading-row"><span>价格与搭配建议</span><b>计算中</b></div>
        </div>
      </section>`;
  }
  if (state.recognized) {
    return `
      ${header('识别结果', '结果仅供购买决策参考')}
      <section class="recognition-result">
        <div class="mini-produce">🍅</div>
        <div>
          <div class="confidence">识别置信度 98%</div>
          <h2>番茄</h2>
          <p class="subtle">表皮完整、色泽均匀，果蒂区域未见明显霉斑。</p>
        </div>
      </section>
      <div class="fresh-score"><strong>96</strong><div><b>新鲜度评分</b><div class="fresh-bar"><i></i></div></div><span class="pill">建议购买</span></div>
      <div class="section-title-row"><h3>购买参考</h3><span class="eyebrow">华中地区参考</span></div>
      <div class="fact-grid">
        <div class="fact-card"><small>参考价格</small><strong>¥4.2–5.6 / 500g</strong></div>
        <div class="fact-card"><small>推荐购买量</small><strong>2人约 300g</strong></div>
        <div class="fact-card"><small>家庭冷藏</small><strong>约 3–5 天</strong></div>
        <div class="fact-card"><small>优选搭配</small><strong>鸡蛋 · 豆腐</strong></div>
      </div>
      <div class="safety-note">AI依据图像可见特征提供辅助建议；如出现异味、渗液或霉变，请停止食用。价格受地区与时段影响，以现场标价为准。</div>
      <button class="primary-button full green" data-action="add-and-pair">加入食材并智能搭配</button>
      <button class="soft-button full" data-action="reset-recognize">重新识别</button>`;
  }
  return `
    ${header('拍照识菜', '将食材置于取景框中央')}
    <section class="scan-stage">
      <div class="recognize-stage">
        <div class="tomato"></div><div class="scan-frame"></div><div class="scan-line"></div>
        <div class="scan-badge">保持光线充足 · 避免遮挡</div>
      </div>
      <div class="tip-list">
        <div class="tip-item"><span class="tip-check">1</span>拍摄食材整体和果蒂等关键部位</div>
        <div class="tip-item"><span class="tip-check">2</span>系统同步分析新鲜度、价格和保存方式</div>
      </div>
      <button class="primary-button full green" data-action="capture-food">模拟拍摄并识别</button>
    </section>`;
}

function pairingPage() {
  return `
    ${header('智能搭配', '用现有食材补齐营养缺口')}
    <div class="section-title-row"><h3>已选食材</h3><button class="text-button" data-route="recognize">+ 继续识别</button></div>
    <div class="ingredient-tray">
      <div class="ingredient-chip"><span>🍅</span><strong>番茄 300g</strong></div>
      <div class="ingredient-chip"><span>🧊</span><strong>豆腐 200g</strong></div>
      <div class="ingredient-chip add" data-action="add-ingredient"><span>＋</span><strong>添加食材</strong></div>
    </div>
    <div class="section-title-row"><h3>用餐条件</h3><span class="eyebrow">AI 动态重算</span></div>
    <section class="surface-card">
      <div class="card-head"><strong>用餐人数</strong><div><button class="choice-chip" data-action="people-minus">−</button> <b>${state.people}人</b> <button class="choice-chip" data-action="people-plus">＋</button></div></div>
      <div class="choice-wrap">
        <button class="choice-chip selected">${state.budget}</button>
        <button class="choice-chip">清淡少油</button>
        <button class="choice-chip">新手烹饪</button>
        <button class="choice-chip">30分钟内</button>
      </div>
    </section>
    <div class="section-title-row"><h3>AI 一餐方案</h3><span class="eyebrow">营养 × 预算 × 库存</span></div>
    <section class="meal-card">
      <div class="meal-head"><div><div class="meal-title">方案 A · 番茄豆腐轻食餐</div><div class="meal-tags"><span class="pill">88分</span><span class="pill">预计 ¥28.6</span></div></div><span>25分钟</span></div>
      <div class="meal-ingredients">
        <div class="meal-ingredient"><span>🍅</span>番茄炒蛋</div><div class="meal-ingredient"><span>🧊</span>香煎豆腐</div><div class="meal-ingredient"><span>🥬</span>清炒油菜</div>
      </div>
      <button class="primary-button full green" data-meal="tomato">选择并生成清单</button>
    </section>
    <section class="meal-card">
      <div class="meal-head"><div><div class="meal-title">方案 B · 菌菇蔬菜汤面</div><div class="meal-tags"><span class="pill">84分</span><span class="pill">预计 ¥24.9</span></div></div><span>20分钟</span></div>
      <div class="meal-ingredients">
        <div class="meal-ingredient"><span>🍜</span>挂面</div><div class="meal-ingredient"><span>🍄</span>香菇</div><div class="meal-ingredient"><span>🥬</span>时蔬</div>
      </div>
      <button class="soft-button full" data-meal="noodle">选择方案</button>
    </section>`;
}

function listPage() {
  const checked = state.shopping.filter(item => item.checked).length;
  const total = state.shopping.reduce((sum, item) => sum + item.price, 0);
  return `
    ${header('购物清单', '缺什么、买多少、预计花多少')}
    <section class="shopping-summary">
      <div><div>方案预算</div><strong>${money(total)}</strong><p>${checked}/${state.shopping.length} 项已购 · 低于30元预算</p></div>
      <span>🧺</span>
    </section>
    <div class="section-title-row"><h3>待购食材</h3><button class="text-button" data-action="share-list">分享清单</button></div>
    <div class="shopping-list">
      ${state.shopping.map((item, index) => `
        <div class="shopping-row ${item.checked ? 'done' : ''}" data-shopping="${index}">
          <div class="shopping-check">${item.checked ? '✓' : ''}</div>
          <div><div class="shopping-name">${item.name} · ${item.amount}</div><div class="shopping-note">参考价已核验 · 点击标记已购</div></div>
          <div class="shopping-price">${money(item.price)}</div>
        </div>`).join('')}
    </div>
    <div class="advice-card" style="margin-top:14px"><div class="advice-icon">¥</div><div><strong>理性消费提示</strong><span>若番茄现场价格高于 ¥6.5/500g，可替换为当季彩椒或减少购买量。</span></div></div>
    <button class="primary-button full green" data-action="open-cook">食材买齐，进入做菜模式</button>`;
}

function profilePage() {
  return `
    ${header('我的饮食档案', '让建议越用越贴合')}
    <section class="surface-card">
      <div class="card-head"><div><h3>本周饮食概览</h3><p class="subtle">已完成 5 次家庭烹饪</p></div><div class="score-mini"><span>86</span></div></div>
      <div class="diet-stats">
        <div class="diet-stat"><strong>12</strong><small>食材种类</small></div>
        <div class="diet-stat"><strong>3.2</strong><small>蔬菜份/日</small></div>
        <div class="diet-stat"><strong>¥29</strong><small>餐均成本</small></div>
      </div>
    </section>
    <div class="section-title-row"><h3>家庭库存</h3><button class="text-button" data-action="add-stock">+ 记录</button></div>
    <section class="surface-card">
      <div class="stock-row"><div class="stock-left"><div class="stock-icon">🧊</div><div><strong>嫩豆腐</strong><p class="subtle">200g · 冷藏</p></div></div><span class="expiry">明天到期</span></div>
      <div class="stock-row"><div class="stock-left"><div class="stock-icon">🥚</div><div><strong>鸡蛋</strong><p class="subtle">4枚 · 冷藏</p></div></div><span class="pill">余量充足</span></div>
      <div class="stock-row"><div class="stock-left"><div class="stock-icon">🍜</div><div><strong>挂面</strong><p class="subtle">约300g · 常温</p></div></div><span class="pill">可用3餐</span></div>
    </section>
    <div class="section-title-row"><h3>我的偏好</h3></div>
    <section class="surface-card"><div class="choice-wrap"><span class="choice-chip selected">清淡少油</span><span class="choice-chip selected">不吃香菜</span><span class="choice-chip">控制预算</span><span class="choice-chip">新手菜谱</span></div></section>`;
}

function render() {
  const pages = { home: homePage, recognize: recognizePage, pairing: pairingPage, list: listPage, profile: profilePage };
  app.innerHTML = `<div class="page-enter">${(pages[state.route] || homePage)()}</div>`;
  document.querySelectorAll('.nav-item').forEach(item => item.classList.toggle('active', item.dataset.route === state.route));
  app.scrollTop = 0;
}

function navigate(route) {
  state.route = route;
  render();
}

function openCooking() {
  modalRoot.innerHTML = `
    <div class="sheet-backdrop" data-action="close-modal">
      <section class="bottom-sheet">
        <div class="sheet-handle"></div>
        <div class="cook-hero"><span class="pill">2人份 · 约15分钟</span><h2 style="margin-top:12px">番茄炒蛋</h2><p class="subtle">番茄300g · 鸡蛋3枚 · 食用油12ml</p></div>
        <div class="step-card"><div class="step-number">1</div><div class="step-copy"><strong>备菜</strong><p>番茄切块；鸡蛋3枚加入1g盐打散。</p></div></div>
        <div class="step-card"><div class="step-number">2</div><div class="step-copy"><strong>炒蛋</strong><p>热锅加入6ml油，中火炒至八成熟后盛出。</p><button class="timer-button" data-action="timer">计时 60 秒</button></div></div>
        <div class="step-card"><div class="step-number">3</div><div class="step-copy"><strong>炒番茄</strong><p>加入6ml油，番茄翻炒约2分钟，出汁后加入鸡蛋。</p><button class="timer-button" data-action="timer">计时 2 分钟</button></div></div>
        <div class="step-card"><div class="step-number">4</div><div class="step-copy"><strong>调味出锅</strong><p>加入1g盐与少量清水，翻匀30秒即可。</p></div></div>
        <button class="primary-button full green" data-action="finish-cook">完成并记录</button>
      </section>
    </div>`;
}

function openChat() {
  modalRoot.innerHTML = `
    <div class="sheet-backdrop" data-action="close-modal">
      <section class="bottom-sheet chat-sheet">
        <div class="sheet-handle"></div>
        <h2>菜小智 AI 助手</h2>
        <p class="subtle">问价格、搭配、保存和做菜步骤</p>
        <div class="chat-log">
          <div class="chat-bubble bot">你好！把现场食材和用餐需求告诉我，我来帮你判断。</div>
          <div class="quick-questions"><button data-question="番茄怎么挑？">番茄怎么挑？</button><button data-question="豆腐快到期怎么做？">豆腐快到期怎么做？</button></div>
        </div>
        <div class="chat-input-row"><input id="chat-input" placeholder="输入你的问题…" /><button data-action="send-chat">发送</button></div>
      </section>
    </div>`;
}

function sendChat(question) {
  const input = document.querySelector('#chat-input');
  const text = (question || input?.value || '').trim();
  if (!text) return;
  const log = document.querySelector('.chat-log');
  log.insertAdjacentHTML('beforeend', `<div class="chat-bubble user">${text.replace(/[<>]/g, '')}</div>`);
  const answer = text.includes('豆腐')
    ? '豆腐临期建议今天做“香煎豆腐”或加入蔬菜汤；若有酸味、黏液或包装胀气，请勿食用。'
    : '优先选表皮完整、色泽均匀、果蒂新鲜的番茄。轻按应有弹性，避免明显软烂、裂口和霉斑。';
  log.insertAdjacentHTML('beforeend', `<div class="chat-bubble bot">${answer}</div>`);
  if (input) input.value = '';
  log.scrollTop = log.scrollHeight;
}

document.addEventListener('click', event => {
  const target = event.target.closest('[data-route],[data-action],[data-meal],[data-shopping],[data-question]');
  if (!target) return;
  if (target.dataset.route) return navigate(target.dataset.route);
  if (target.dataset.shopping !== undefined) {
    const item = state.shopping[Number(target.dataset.shopping)];
    item.checked = !item.checked;
    return render();
  }
  if (target.dataset.meal) {
    state.meal = target.dataset.meal;
    showToast('已生成定量购物清单');
    return navigate('list');
  }
  if (target.dataset.question) return sendChat(target.dataset.question);
  const action = target.dataset.action;
  if (action === 'start-recognize') return navigate('recognize');
  if (action === 'capture-food') {
    state.scanning = true;
    render();
    return window.setTimeout(() => { state.scanning = false; state.recognized = true; render(); }, 900);
  }
  if (action === 'reset-recognize') { state.recognized = false; return render(); }
  if (action === 'add-and-pair') { showToast('番茄已加入食材篮'); return navigate('pairing'); }
  if (action === 'people-minus') { state.people = Math.max(1, state.people - 1); return render(); }
  if (action === 'people-plus') { state.people = Math.min(6, state.people + 1); return render(); }
  if (action === 'open-cook') return openCooking();
  if (action === 'open-chat') return openChat();
  if (action === 'close-modal') { modalRoot.innerHTML = ''; return; }
  if (action === 'send-chat') return sendChat();
  if (action === 'timer') return showToast('计时已开始（演示）');
  if (action === 'finish-cook') { modalRoot.innerHTML = ''; return showToast('已记录本次烹饪与库存变化'); }
  if (action === 'share-list') return showToast('清单已复制（演示）');
  if (action === 'add-stock' || action === 'add-ingredient') return showToast('已打开添加入口（演示）');
});

document.addEventListener('keydown', event => {
  if (event.key === 'Enter' && event.target.id === 'chat-input') sendChat();
  if (event.key === 'Escape') modalRoot.innerHTML = '';
});

render();
