import { common } from '@kit.AbilityKit';
import { INGREDIENTS, RECIPES, IngredientInfo, Recipe, RecipeItem, RecipeStep, FOODS, FoodExample } from '../model/RecipeCatalog';

@Component
export struct RecipeDetailSheet {
  @Prop @Watch('resetContent') recipe: Recipe = RECIPES[0];
  @Prop @Watch('resetContent') food: FoodExample = FOODS[0];
  @Prop @Watch('resetContent') kind: string = 'materials';
  @State page: number = 0;
  @State ingredientName: string = '';
  onClose: () => void = () => {};

  private resetContent(): void { this.page = 0; this.ingredientName = ''; }

  private info(): IngredientInfo {
    return this.recipe.ingredientInfos?.find((item: IngredientInfo) => item.name === this.ingredientName) || INGREDIENTS.find((item: IngredientInfo) => item.name === this.ingredientName) || INGREDIENTS[0];
  }

  private title(): string {
    if (this.ingredientName) { return this.ingredientName; }
    if (this.kind === 'steps') { return '分步做法'; }
    if (this.kind === 'photo-credit') { return '图片说明'; }
    if (this.kind === 'story') { return '菜品故事'; }
    if (this.kind === 'knowledge') { return '食材小知识'; }
    return '准备食材';
  }

  private async openSource(url: string = this.recipe.source): Promise<void> {
    try {
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      await context.startAbility({ action: 'ohos.want.action.viewData', uri: url,
        entities: ['entity.system.browsable'] });
    } catch (_) {
      this.getUIContext().getPromptAction().showToast({ message: '无法打开浏览器，请稍后重试' });
    }
  }

  @Builder
  Paragraph(title: string, text: string) {
    Column({ space: 8 }) {
      Text(title).fontSize(16).fontWeight(FontWeight.Medium).fontColor('#202A23')
      Text(text).fontSize(14).lineHeight(24).fontColor('#637067')
    }.width('100%').alignItems(HorizontalAlign.Start).margin({ bottom: 16 })
  }

  @Builder
  Pager(count: number, steps: boolean = false) {
    Row() {
      Button(steps ? '上一步' : '上一页').height(44).width(88).fontSize(13)
        .backgroundColor('#E5EDDC').fontColor('#286749').enabled(this.page > 0)
        .onClick(() => this.page--)
      Text(`${this.page + 1} / ${count}`).fontSize(12).fontColor('#637067')
      Button(steps && this.page === count - 1 ? '看完了' : steps ? '下一步' : '下一页')
        .height(44).width(88).fontSize(13).backgroundColor('#286749').fontColor(Color.White)
        .enabled(steps || this.page < count - 1)
        .onClick(() => {
          if (this.page < count - 1) { this.page++; } else { this.onClose(); }
        })
    }.width('100%').justifyContent(FlexAlign.SpaceBetween).margin({ top: 16 })
  }

  @Builder
  Materials() {
    Text(`${this.recipe.name} · 2 人份参考用量`).fontSize(12).fontColor('#637067').margin({ bottom: 12 })
    Column() {
      ForEach(this.recipe.items.slice(this.page * 4, this.page * 4 + 4), (item: RecipeItem) => {
        Button({ type: ButtonType.Normal }) {
          Row({ space: 8 }) {
            Text(item.name).fontSize(14).fontColor('#202A23')
            Text(item.group).fontSize(10).fontColor('#829078')
            Blank()
            Text(item.amount).fontSize(12).fontColor('#637067').textAlign(TextAlign.End).constraintSize({ maxWidth: '50%' })
            Text('›').fontColor('#819177')
          }.width('100%').constraintSize({ minHeight: 49 })
        }.width('100%').padding(0).backgroundColor(Color.Transparent)
          .onClick(() => this.ingredientName = item.name)
        Divider().color('#E4E9E0')
      }, (item: RecipeItem) => item.name)
    }.width('100%').constraintSize({ minHeight: 200 })
    Text('点击食材，查看介绍与处理方法。').fontSize(11).fontColor('#637067').margin({ top: 10 })
    if (this.recipe.items.length > 4) {
      this.Pager(Math.ceil(this.recipe.items.length / 4))
    }
  }

  @Builder
  Steps() {
    Text(this.recipe.name).fontSize(12).fontColor('#637067')
    Row({ space: 6 }) {
      ForEach(this.recipe.steps, (step: RecipeStep, index: number) => {
        Rect().height(4).layoutWeight(1).radius(2).fill(index <= this.page ? '#286749' : '#DFE7D6')
      }, (step: RecipeStep) => step.title)
    }.width('100%').margin({ top: 14, bottom: 18 })
    Column({ space: 10 }) {
      Text(`STEP ${this.page + 1} / ${this.recipe.steps.length}`).fontSize(11).fontColor('#637067')
      Text(this.recipe.steps[this.page].title).fontSize(23).fontWeight(FontWeight.Bold).fontColor('#202A23')
      Text(this.recipe.steps[this.page].description).fontSize(15).lineHeight(26).fontColor('#40553B')
    }.width('100%').constraintSize({ minHeight: 170 }).padding(18).backgroundColor('#EAF0DF')
      .borderRadius(14).alignItems(HorizontalAlign.Start)
    this.Pager(this.recipe.steps.length, true)
  }

  build() {
    Column() {
      Row() {
        Text(this.title()).fontSize(21).fontWeight(FontWeight.Bold).fontColor('#202A23')
        Blank()
        Button('×', { type: ButtonType.Circle }).width(44).height(44).fontSize(25)
          .backgroundColor(Color.Transparent).fontColor('#202A23').accessibilityText('关闭弹窗')
          .onClick(this.onClose)
      }.width('100%').margin({ bottom: 12 })
      if (this.ingredientName) {
        Text(this.info().category).fontSize(12).fontColor('#286749').margin({ bottom: 16 })
        this.Paragraph('认识它', this.info().description)
        this.Paragraph('下锅之前', this.info().preparation)
        Button('返回用料表').width('100%').height(44).backgroundColor('#E5EDDC').fontColor('#286749')
          .onClick(() => this.ingredientName = '')
      } else if (this.kind === 'photo-credit') {
        if (this.recipe.photoCredit) {
          this.Paragraph('成品参考照片', '实际配料和摆盘以菜谱为准。')
          this.Paragraph('摄影', this.recipe.photoCredit.author)
          Button(this.recipe.photoCredit.license).height(44).width('100%').fontSize(13)
            .backgroundColor('#E5EDDC').fontColor('#286749')
            .onClick(() => this.openSource(this.recipe.photoCredit?.licenseUrl || ''))
          Button('原图与来源 ↗').height(44).width('100%').fontSize(13).margin({ top: 8 })
            .backgroundColor('#E5EDDC').fontColor('#286749')
            .onClick(() => this.openSource(this.recipe.photoCredit?.sourcePage || ''))
        } else {
          this.Paragraph('原创示意插画', '本项目绘制，非菜品实拍照片。')
        }
      } else if (this.kind === 'materials') {
        this.Materials()
      } else if (this.kind === 'steps') {
        this.Steps()
      } else if (this.kind === 'story') {
        this.Paragraph(this.recipe.name, this.recipe.story)
        if (this.recipe.source) {
          Button(`参考：${this.recipe.sourceName} ↗`).fontSize(12).height(44).width('100%')
            .backgroundColor('#E5EDDC').fontColor('#286749').onClick(() => this.openSource())
        } else {
          Text('家常做法示例 · 可按口味调整').fontSize(11).fontColor('#637067')
        }
      } else if (this.page === 0) {
        this.Paragraph(`认识${this.food.name}`, this.food.description)
        this.Paragraph('下锅之前', this.food.preparation)
        this.Pager(2)
      } else {
        this.Paragraph('怎么保存', this.food.storage)
        this.Paragraph('怎么搭配', this.food.pairing)
        this.Pager(2)
      }
    }.width('100%').padding({ left: 20, right: 20, bottom: 24, top: 8 }).alignItems(HorizontalAlign.Start)
  }
}
