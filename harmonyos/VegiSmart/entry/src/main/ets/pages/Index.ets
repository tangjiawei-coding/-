import { common } from '@kit.AbilityKit';
import { RECIPES, Recipe, recipeById, FOODS, FoodExample } from '../model/RecipeCatalog';
import { PhotoLibrarySheet } from '../components/PhotoLibrarySheet';
import { PHOTO_LIBRARY } from '../model/PhotoLibrary';
import { RecipeDetailSheet } from '../components/RecipeDetailSheet';
import { FoodPhotoService } from '../services/FoodPhotoService';
import { KitchenService } from '../services/KitchenService';
import { TodayMenuStore } from '../services/TodayMenuStore';

@Entry
@Component
struct Index {
  @State page: string = 'home';
  @State recipe: Recipe = RECIPES[0];
  @State food: FoodExample = FOODS[0];
  @State menu: string[] = [];
  @State menuPage: number = 0;
  @State ready: boolean = false;
  @State saving: boolean = false;
  @State busy: boolean = false;
  @State showSheet: boolean = false;
  @State sheetKind: string = '';
  @State query: string = '';
  @State feedback: string = '';
  @State photo: string = '';
  @State removedId: string = '';
  @State contentHeight: number = 700;
  private removedIndex: number = 0;
  private undoTimer: number = -1;
  private kitchen: KitchenService = new KitchenService();
  private requestId: number = 0;
  private lastName: string = '';
  private lastPhoto: string = '';
  private recipeOrigin: string = 'result';
  private menuStore: TodayMenuStore = new TodayMenuStore();

  aboutToAppear(): void { this.loadMenu(); }
  aboutToDisappear(): void { clearTimeout(this.undoTimer); this.cancelAnalysis(); }

  private async loadMenu(): Promise<void> {
    try {
      this.menu = await this.menuStore.open(this.getUIContext().getHostContext() as common.UIAbilityContext);
      this.ready = true;
    } catch (_) { this.toast('菜单读取失败，可在“我的”中重试'); }
  }

  private toast(message: string): void {
    this.getUIContext().getPromptAction().showToast({ message });
  }

  private openSheet(kind: string): void {
    this.sheetKind = kind;
    this.feedback = '';
    this.showSheet = true;
  }

  private openRecipe(recipe: Recipe): void {
    this.recipeOrigin = this.page;
    this.recipe = recipe;
    this.food = FOODS.find((food: FoodExample) => food.recipeIds.includes(recipe.id)) || FOODS[0];
    this.page = 'recipe';
  }

  private back(): void {
    if (this.showSheet) { this.cancelAnalysis(); this.showSheet = false; return; }
    this.page = this.page === 'recipe' ? this.recipeOrigin : 'home';
  }

  onBackPress(): boolean {
    if (this.showSheet || this.page !== 'home') { this.back(); return true; }
    return false;
  }

  private async selectPhoto(camera: boolean): Promise<void> {
    if (this.busy) { return; }
    this.busy = true;
    try {
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const photo = camera ? await FoodPhotoService.takePhoto(context) : await FoodPhotoService.choosePhoto();
      if (photo) { this.photo = photo; this.openSheet('photo'); }
    } catch (_) { this.toast('未能取得照片，请重试或从相册选择'); }
    finally { this.busy = false; }
  }

  private search(): void {
    const name = this.query.trim();
    if (!name) { this.feedback = '请输入食材名称'; return; }
    this.analyze(name, '');
  }

  private cancelAnalysis(): void {
    this.requestId++;
    this.kitchen.cancel();
    this.busy = false;
  }

  private async analyze(name: string, photo: string): Promise<void> {
    if (this.busy) { return; }
    this.busy = true;
    this.lastName = name;
    this.lastPhoto = photo;
    const requestId = ++this.requestId;
    this.openSheet('loading');
    try {
      const result = await this.kitchen.explore(name, photo);
      if (requestId !== this.requestId) { return; }
      if (result.status === 'needs_input' || !result.food) {
        this.sheetKind = 'needs_input';
        this.feedback = result.message || '请补拍一种食材，或输入食材名称';
        return;
      }
      await this.menuStore.remember(result.food, result.recipes);
      if (requestId !== this.requestId) { return; }
      this.food = result.food;
      this.page = 'result';
      this.showSheet = false;
    } catch (error) {
      if (requestId !== this.requestId) { return; }
      this.sheetKind = 'error';
      this.feedback = (error as Error).message || '连接失败，请检查后端连接后重试';
    } finally {
      if (requestId === this.requestId) { this.busy = false; }
    }
  }

  private async persist(next: string[]): Promise<boolean> {
    if (!this.ready || this.saving) { return false; }
    this.saving = true;
    try {
      await this.menuStore.save(next);
      this.menu = next;
      this.menuPage = Math.min(this.menuPage, Math.max(0, Math.ceil(next.length / 2) - 1));
      return true;
    } catch (_) { this.toast('保存失败，请重试'); return false; }
    finally { this.saving = false; }
  }

  private async addRecipe(): Promise<void> {
    if (this.menu.includes(this.recipe.id)) { this.page = 'menu'; return; }
    if (await this.persist(this.menu.concat([this.recipe.id]))) { this.toast('已加入今日菜单'); }
  }

  private async removeRecipe(id: string): Promise<void> {
    const index = this.menu.indexOf(id);
    if (await this.persist(this.menu.filter((value: string) => value !== id))) {
      clearTimeout(this.undoTimer);
      this.removedId = id;
      this.removedIndex = index;
      this.undoTimer = setTimeout(() => this.removedId = '', 5000);
    }
  }

  private async undoRemove(): Promise<void> {
    if (!this.removedId || this.menu.includes(this.removedId)) { return; }
    const next = this.menu.slice();
    next.splice(this.removedIndex, 0, this.removedId);
    if (await this.persist(next)) { clearTimeout(this.undoTimer); this.removedId = ''; }
  }

  @Builder
  Icon(name: string, size: number = 22) {
    Image($rawfile(`ic_${name}.svg`)).width(size).height(size).objectFit(ImageFit.Contain)
  }

  @Builder
  Primary(label: string, action: () => void, enabled: boolean = true) {
    Button(label, { type: ButtonType.Normal }).width('100%').height(48).borderRadius(12)
      .fontSize(16).fontWeight(FontWeight.Medium).backgroundColor('#286749').fontColor(Color.White)
      .enabled(enabled).onClick(action)
  }

  @Builder
  Brand() {
    Row({ space: 8 }) {
      this.Icon('leaf', 30)
      Column() {
        Text('菜小智').fontSize(22).fontWeight(FontWeight.Bold).fontColor('#202A23')
        Text('VEGISMART').fontSize(7).letterSpacing(2).fontColor('#286749')
      }.alignItems(HorizontalAlign.Start)
      Blank()
      Text('把日子，做出滋味。').fontSize(10).fontColor('#7B897D')
    }.width('100%').height(58)
  }

  @Builder
  PageHeader(title: string) {
    Row() {
      Button('‹', { type: ButtonType.Circle }).width(44).height(44).fontSize(28)
        .fontColor('#202A23').backgroundColor(Color.Transparent).onClick(() => this.back())
        .accessibilityText('返回上一页')
      Text(title).layoutWeight(1).textAlign(TextAlign.Center).fontSize(15).fontWeight(FontWeight.Medium)
      Text((this.page === 'recipe' ? this.recipe.id : this.food.id).startsWith('ai-') ? 'AI 建议' : '示例').width(44).textAlign(TextAlign.Center).fontSize(10).fontColor('#286749')
    }.width('100%').height(52)
  }

  @Builder
  EmptyMenu() {
    Row({ space: 14 }) {
      this.Icon('bowl', 32)
      Column({ space: 6 }) {
        Text('今天还没选菜').fontSize(15).fontWeight(FontWeight.Medium)
        Text('认识一种食材，发现一道想做的菜。').fontSize(11).fontColor('#637067')
      }.alignItems(HorizontalAlign.Start)
    }.width('100%').height(92).padding(16).backgroundColor('#EDF3E3').borderRadius(14)
  }

  @Builder
  RecipeCard(recipe: Recipe, recommendation: boolean = false) {
    Button({ type: ButtonType.Normal }) {
      Row({ space: 12 }) {
        Image($rawfile(recipe.image)).width(recommendation ? 82 : 66).height(recommendation ? 82 : 66)
          .objectFit(ImageFit.Cover).borderRadius(10)
        Column({ space: 5 }) {
          Text(recipe.name).fontSize(16).fontWeight(FontWeight.Medium).fontColor('#202A23')
          if (recommendation) {
            Text(recipe.subtitle).fontSize(11).lineHeight(16).fontColor('#637067')
          }
          Text(recipe.pairing).fontSize(10).fontColor('#6E8164')
        }.layoutWeight(1).alignItems(HorizontalAlign.Start)
        Text('›').fontSize(20).fontColor('#819177')
      }.width('100%').padding(10)
    }.width('100%').backgroundColor('#FFFEF9').borderRadius(14).padding(0)
      .onClick(() => this.openRecipe(recipe))
  }

  @Builder
  HomePage() {
    this.Brand()
    Column() {
      Image($rawfile('market.jpg')).width('100%').layoutWeight(1).objectFit(ImageFit.Cover)
      Column({ space: 9 }) {
        Text('认识食材 · 发现三种做法').fontSize(10).fontColor('#637067')
        Text('这是什么，\n又能做点什么？').fontSize(this.contentHeight < 650 ? 26 : 30)
          .fontWeight(FontWeight.Bold).fontColor('#202A23')
        Text('从眼前的食材，找到今天想做的菜。').fontSize(12).fontColor('#637067')
        this.Primary(this.busy ? '正在打开…' : '拍照识菜', () => this.selectPhoto(true), !this.busy)
      }.width('100%').padding(16).alignItems(HorizontalAlign.Start)
    }.width('100%').layoutWeight(1).borderRadius(18).clip(true).backgroundColor('#E4EEDC')
    Row({ space: 10 }) {
      Button('从相册选择').layoutWeight(1).height(48).borderRadius(12).fontSize(13)
        .backgroundColor('#FFFEF9').fontColor('#286749').enabled(!this.busy).onClick(() => this.selectPhoto(false))
      Button('手动搜索').layoutWeight(1).height(48).borderRadius(12).fontSize(13)
        .backgroundColor('#FFFEF9').fontColor('#286749').onClick(() => this.openSheet('search'))
    }.width('100%').margin({ top: 10 })
    Button({ type: ButtonType.Normal }) {
      Row() {
        Text('先找一点做菜灵感').fontSize(12).fontColor('#637067')
        Blank()
        Text('4 种食材 · 12 道菜 →').fontSize(12).fontColor('#286749')
      }.width('100%').height(46)
    }.width('100%').padding(0).backgroundColor(Color.Transparent).onClick(() => this.openSheet('examples'))
    Button({ type: ButtonType.Normal }) {
      Row({ space: 10 }) {
        this.Icon('bowl', 26)
        Column({ space: 4 }) {
          Text(this.menu.length ? `今日菜单 · ${this.menu.length} 道` : '今日菜单').fontSize(13).fontColor('#202A23')
          Text(this.menu.length ? this.menu.map((id: string) => recipeById(id).name).join('、') : '把今天想做的菜放在这里')
            .fontSize(10).fontColor('#637067').maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
        }.layoutWeight(1).alignItems(HorizontalAlign.Start)
        Text('›').fontColor('#819177')
      }.width('100%').height(62).padding(12)
    }.width('100%').padding(0).backgroundColor('#FFFEF9').borderRadius(14).margin({ bottom: 10 })
      .onClick(() => this.page = 'menu')
  }

  @Builder
  ResultPage() {
    this.PageHeader('认识食材')
    Column() {
      Row({ space: 10 }) {
        this.Icon('leaf', 32)
        Column({ space: 4 }) {
          Text(this.food.name).fontSize(22).fontWeight(FontWeight.Bold)
          Text(this.food.subtitle).fontSize(11).fontColor('#637067')
        }.layoutWeight(1).alignItems(HorizontalAlign.Start)
        Button('更正').height(44).fontSize(12).fontColor('#286749').backgroundColor(Color.Transparent)
          .onClick(() => this.openSheet('search'))
      }.width('100%')
      Text(this.food.summary).width('100%').fontSize(12).fontColor('#637067')
        .margin({ top: 8, bottom: 8 })
      Divider().color('#E4E9E0')
      Row() {
        Button('换种食材 →').height(40).fontSize(12).backgroundColor(Color.Transparent).fontColor('#286749')
          .onClick(() => this.openSheet('examples'))
        Blank()
        Button('认识更多 ›').height(40).fontSize(12).backgroundColor(Color.Transparent).fontColor('#286749')
          .onClick(() => this.openSheet('knowledge'))
      }.width('100%')
    }.width('100%').padding({ left: 14, right: 14, top: 12 }).backgroundColor('#FFFEF9').borderRadius(16)
    Row() {
      Text('可以做这三道').fontSize(17).fontWeight(FontWeight.Medium)
      Blank()
      Text('一种食材，三种滋味').fontSize(10).fontColor('#637067')
    }.width('100%').margin({ top: 16, bottom: 10 })
    Column({ space: 8 }) {
      ForEach(this.food.recipeIds, (id: string) => { this.RecipeCard(recipeById(id), true); }, (id: string) => id)
    }.width('100%')
    Text('家常做法参考 · 用量可按口味调整').fontSize(10).fontColor('#7F8B79').margin({ top: 10 })
  }

  @Builder
  DetailEntry(icon: string, title: string, subtitle: string, kind: string) {
    Button({ type: ButtonType.Normal }) {
      Row({ space: 12 }) {
        this.Icon(icon)
        Column({ space: 4 }) {
          Text(title).fontSize(14).fontWeight(FontWeight.Medium).fontColor('#202A23')
          Text(subtitle).fontSize(11).fontColor('#637067')
        }.layoutWeight(1).alignItems(HorizontalAlign.Start)
        Text('›').fontSize(20).fontColor('#819177')
      }.width('100%').height(60)
    }.width('100%').padding({ left: 14, right: 14 }).backgroundColor('#FFFEF9')
      .onClick(() => this.openSheet(kind))
  }

  @Builder
  RecipePage() {
    this.PageHeader('菜谱详情')
    Stack({ alignContent: Alignment.BottomEnd }) {
      Image($rawfile(this.recipe.image)).width('100%').height(this.contentHeight < 650 ? 140 : 190)
        .objectFit(ImageFit.Cover).borderRadius(14)
      Text(this.recipe.photoCredit ? '成品参考 · 图片来源 ↗' : '菜谱示意 · 非实拍').fontSize(9).fontColor(Color.White).padding(5)
        .backgroundColor('#9940533A').borderRadius(4).margin(8).onClick(() => this.openSheet('photo-credit'))
    }.width('100%')
    Column({ space: 6 }) {
      Text(`${this.recipe.method} / 家常灵感`).fontSize(10).fontColor('#637067')
      Text(this.recipe.name).fontSize(25).fontWeight(FontWeight.Bold)
      Text(this.recipe.subtitle).fontSize(12).fontColor('#637067')
      Text(`2 人份  ·  ${this.recipe.time}`).fontSize(11).fontColor('#286749').margin({ top: 3 })
    }.width('100%').alignItems(HorizontalAlign.Start).margin({ top: 14, bottom: 14 })
    Column() {
      this.DetailEntry('menu', '准备食材', `${this.recipe.items.length} 项用料 · 查看用量与介绍`, 'materials')
      Divider().color('#E4E9E0')
      this.DetailEntry('bowl', '分步做法', `${this.recipe.steps.length} 个步骤 · 一步一步看`, 'steps')
      Divider().color('#E4E9E0')
      this.DetailEntry('leaf', '菜品故事', '了解这道菜的家常滋味', 'story')
    }.width('100%').borderRadius(16).clip(true)
    Text('点击展开，关闭即回到这里').fontSize(10).fontColor('#7F8B79').margin({ top: 12 })
  }

  @Builder
  MenuPage() {
    this.Brand()
    Row() {
      Text('今日菜单').fontSize(25).fontWeight(FontWeight.Bold)
      Text(`${this.menu.length} 道`).fontSize(12).fontColor('#286749').margin({ left: 12 })
    }.width('100%').margin({ top: 4, bottom: 16 })
    if (this.menu.length === 0) {
      this.EmptyMenu()
    } else {
      Column({ space: 10 }) {
        ForEach(this.menu.slice(this.menuPage * 2, this.menuPage * 2 + 2), (id: string) => {
          Column() {
            this.RecipeCard(recipeById(id))
            Divider().color('#E4E9E0')
            Row() {
              Text('计划做 · 2 人份参考').fontSize(10).fontColor('#7F8B79')
              Blank()
              Button('移除').height(36).fontSize(12).fontColor('#7B6352').backgroundColor(Color.Transparent)
                .enabled(this.ready && !this.saving).onClick(() => this.removeRecipe(id))
            }.width('100%').padding({ left: 12, right: 4 })
          }.width('100%').backgroundColor('#FFFEF9').borderRadius(14)
        }, (id: string) => id)
      }.width('100%')
      if (this.menu.length > 2) {
        Row() {
          Button('上一页').height(44).fontSize(12).backgroundColor('#E5EDDC').fontColor('#286749')
            .enabled(this.menuPage > 0).onClick(() => this.menuPage--)
          Text(`${this.menuPage + 1} / ${Math.ceil(this.menu.length / 2)}`).fontSize(12)
          Button('下一页').height(44).fontSize(12).backgroundColor('#E5EDDC').fontColor('#286749')
            .enabled(this.menuPage + 1 < Math.ceil(this.menu.length / 2)).onClick(() => this.menuPage++)
        }.width('100%').justifyContent(FlexAlign.SpaceBetween).margin({ top: 10 })
      }
    }
    Button(this.menu.length ? '再选一道菜 →' : '去认识一种食材 →').width('100%').height(44)
      .fontColor('#286749').fontSize(14).backgroundColor('#E5EDDC').margin({ top: 14 })
      .onClick(() => { if (this.menu.length) { this.openSheet('examples'); } else { this.page = 'home'; } })
    Text('加入代表想做，不会记作做过 · 仅本机保存').fontSize(10).fontColor('#7F8B79').margin({ top: 10 })
  }

  @Builder
  ProfilePage() {
    this.Brand()
    Text('我的').width('100%').fontSize(25).fontWeight(FontWeight.Bold).margin({ top: 8, bottom: 18 })
    Column({ space: 12 }) {
      Text('慢慢积累你的餐桌灵感').fontSize(18).fontWeight(FontWeight.Medium)
      Text('收藏、识别历史、做饭记录与偏好设置将在后续完善，账号和云同步方式待讨论。')
        .fontSize(14).lineHeight(24).fontColor('#637067')
      Text('开始识别后，照片会发送给模型服务分析。AI 菜谱仅供做菜参考，今日菜单保存在本机。')
        .fontSize(12).lineHeight(21).fontColor('#637067')
      this.Primary(`菜品图库 · ${PHOTO_LIBRARY.length} 道`, () => this.openSheet('library'))
      if (!this.ready) {
        this.Primary('重新读取菜单', () => this.loadMenu())
      }
    }.width('100%').padding(18).backgroundColor('#FFFEF9').borderRadius(16).alignItems(HorizontalAlign.Start)
  }

  @Builder
  NavItem(page: string, icon: string, label: string) {
    Button({ type: ButtonType.Normal }) {
      Column({ space: 4 }) {
        this.Icon(icon)
        Text(label).fontSize(11).fontColor(this.page === page ? '#286749' : '#829078')
      }.width('100%').height(52).justifyContent(FlexAlign.Center)
    }.layoutWeight(1).backgroundColor(this.page === page ? '#EAF0DF' : Color.Transparent)
      .borderRadius(12).padding(0).onClick(() => this.page = page)
  }

  @Builder
  ExampleSheet() {
    Column({ space: 12 }) {
      Row() {
        Text('从哪种食材开始？').fontSize(21).fontWeight(FontWeight.Bold)
        Blank()
        Button('×', { type: ButtonType.Circle }).width(44).height(44).fontSize(25)
          .backgroundColor(Color.Transparent).fontColor('#202A23').onClick(() => this.showSheet = false)
          .accessibilityText('关闭弹窗')
      }.width('100%')
      Text('4 种常见食材，每种发现三道家常菜。').fontSize(12).fontColor('#637067')
      ForEach([0, 1], (row: number) => {
        Row({ space: 12 }) {
          ForEach(FOODS.slice(row * 2, row * 2 + 2), (food: FoodExample) => {
            Button({ type: ButtonType.Normal }) {
              Column({ space: 8 }) {
                Image($rawfile(food.image)).width('100%').height(86).objectFit(ImageFit.Cover)
                Text(food.name).fontSize(16).fontWeight(FontWeight.Medium).fontColor('#202A23')
                Text('三种家常做法 →').fontSize(10).fontColor('#637067').margin({ bottom: 12 })
              }.width('100%')
            }.layoutWeight(1).padding(0).backgroundColor('#FFFEF9').borderRadius(14).clip(true)
              .onClick(() => { this.food = food; this.showSheet = false; this.page = 'result'; })
          }, (food: FoodExample) => food.id)
        }.width('100%')
      }, (row: number) => row.toString())
      Text('固定示例 · 拍照或搜索可认识更多食材').fontSize(10).fontColor('#637067')
    }.width('100%').padding({ left: 20, right: 20, top: 8, bottom: 24 }).alignItems(HorizontalAlign.Start)
  }

  @Builder
  SheetContent() {
    if (this.sheetKind === 'library') {
      PhotoLibrarySheet({ onClose: () => this.showSheet = false })
    } else if (this.sheetKind === 'examples') {
      this.ExampleSheet()
    } else if (this.sheetKind === 'loading' || this.sheetKind === 'error' || this.sheetKind === 'needs_input') {
      Column({ space: 18 }) {
        Text(this.sheetKind === 'loading' ? '正在认识这份食材' : this.sheetKind === 'error' ? '这次没有分析成功' : '还需要一点线索')
          .fontSize(21).fontWeight(FontWeight.Bold)
        if (this.sheetKind === 'loading') {
          LoadingProgress().width(48).height(48).color('#286749')
          Text('正在整理食材介绍和三道家常菜，可能需要几十秒。').fontSize(14).lineHeight(24).fontColor('#637067')
        } else {
          Text(this.feedback).fontSize(14).lineHeight(24).fontColor('#637067')
          if (this.sheetKind === 'error') {
            this.Primary('重新分析', () => this.analyze(this.lastName, this.lastPhoto))
          }
          this.Primary('手动输入食材', () => this.openSheet('search'))
        }
        Button(this.sheetKind === 'loading' ? '取消' : '关闭').width('100%').height(44)
          .backgroundColor('#E5EDDC').fontColor('#286749')
          .onClick(() => { this.cancelAnalysis(); this.showSheet = false; })
      }.width('100%').padding(24)
    } else if (this.sheetKind === 'search' || this.sheetKind === 'photo') {
      Column({ space: 14 }) {
        Row() {
          Text(this.sheetKind === 'search' ? '想认识哪种食材？' : '照片已选好').fontSize(21).fontWeight(FontWeight.Bold)
          Blank()
          Button('×', { type: ButtonType.Circle }).width(44).height(44).fontSize(25)
            .backgroundColor(Color.Transparent).fontColor('#202A23').onClick(() => this.showSheet = false)
            .accessibilityText('关闭弹窗')
        }.width('100%')
        if (this.sheetKind === 'search') {
          TextInput({ text: this.query, placeholder: '输入一种食材，如茄子、南瓜' }).height(48).maxLength(40)
            .backgroundColor('#FFFEF9').onChange((value: string) => this.query = value)
            .onSubmit(() => this.search())
          this.Primary('认识它，找三道菜', () => this.search(), this.ready)
          Text(this.feedback || 'AI 会整理食材介绍、用料和分步做法。').fontSize(12).lineHeight(21).fontColor('#637067')
        } else {
          Image(this.photo).width('100%').height(160).objectFit(ImageFit.Contain).borderRadius(12)
          Text('开始后将发送这张照片用于本次分析，认识食材并找到三道家常菜。')
            .fontSize(13).lineHeight(23).fontColor('#637067')
          this.Primary('开始识别', () => this.analyze('', this.photo), this.ready)
        }
      }.width('100%').padding({ left: 20, right: 20, top: 8, bottom: 24 })
    } else {
      RecipeDetailSheet({ recipe: this.recipe, food: this.food, kind: this.sheetKind, onClose: () => this.showSheet = false })
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Image($rawfile('botanical-pattern.svg')).width('100%').height('100%').objectFit(ImageFit.Cover)
        .hitTestBehavior(HitTestMode.None).accessibilityLevel('no')
      Column() {
        Column() {
          if (this.page === 'home') { this.HomePage(); }
          else if (this.page === 'result') { this.ResultPage(); }
          else if (this.page === 'recipe') { this.RecipePage(); }
          else if (this.page === 'menu') { this.MenuPage(); }
          else { this.ProfilePage(); }
        }.width('100%').layoutWeight(1).padding({ left: 16, right: 16 }).alignItems(HorizontalAlign.Center)
        if (this.page === 'recipe') {
          Row() {
            this.Primary(this.menu.includes(this.recipe.id) ? '已加入 · 查看今日菜单' : this.saving ? '正在保存…' : '加入今日菜单',
              () => this.addRecipe(), this.ready && !this.saving)
          }.width('100%').padding({ left: 16, right: 16, top: 9, bottom: 10 }).backgroundColor('#F6F8EE')
        } else if (this.page !== 'result') {
          Row({ space: 8 }) {
            this.NavItem('home', 'scan', '识菜')
            this.NavItem('menu', 'menu', this.menu.length ? `今日菜单 · ${this.menu.length}` : '今日菜单')
            this.NavItem('me', 'user', '我的')
          }.width('100%').padding({ left: 16, right: 16, top: 5, bottom: 5 }).backgroundColor('#F6F8EE')
        }
      }.width('100%').height('100%')
      if (this.removedId) {
        Row({ space: 14 }) {
          Text('已移出今日菜单').fontSize(13).fontColor(Color.White)
          Button('撤销').height(44).fontSize(13).backgroundColor(Color.Transparent).fontColor('#E1EFC8')
            .enabled(!this.saving).onClick(() => this.undoRemove())
        }.padding({ left: 16, right: 4 }).backgroundColor('#233D2E').borderRadius(12).margin({ bottom: 80 })
      }
    }.width('100%').height('100%').backgroundColor('#F3F5E9')
      .onAreaChange((_oldArea: Area, area: Area) => this.contentHeight = Number(area.height))
      .bindSheet($$this.showSheet, this.SheetContent(), {
        height: SheetSize.FIT_CONTENT, preferType: SheetType.BOTTOM, showClose: false,
        backgroundColor: '#F3F5E9', enableOutsideInteractive: false,
        onDisappear: () => { this.cancelAnalysis(); this.photo = ''; this.lastPhoto = ''; }
      })
  }
}
