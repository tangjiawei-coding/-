import { common } from '@kit.AbilityKit';
import { FoodRecognitionService, FoodResult } from '../services/FoodRecognitionService';
import { FoodPhotoService } from '../services/FoodPhotoService';
import { BasketItem, FoodBasketStore } from '../services/FoodBasketStore';

@Component
export struct FoodPurchasePanel {
  @State photo: string = '';
  @State busy: boolean = false;
  @State ready: boolean = false;
  @State saving: boolean = false;
  @State manual: boolean = false;
  @State hasResult: boolean = false;
  @State added: boolean = false;
  @State message: string = '';
  @State foodName: string = '';
  @State people: number = 2;
  @State gramsPerPerson: string = '';
  @State price: string = '';
  @State priceUnit: number = 0;
  @State server: string = 'http://127.0.0.1:8000';
  @State showConnection: boolean = false;
  @State basket: BasketItem[] = [];
  @State result: FoodResult = {
    name: null, observations: [], appearance: 'uncertain', onSiteChecks: [],
    buyingAdvice: '', needsRetake: false, retakeReason: null,
    gramsPerPerson: null, quantityNote: ''
  };
  private store: FoodBasketStore = new FoodBasketStore();

  aboutToAppear(): void { this.load(); }

  private async load(): Promise<void> {
    try {
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      await this.store.open(context);
      this.basket = await this.store.loadBasket();
      this.server = await this.store.loadServer();
      this.ready = true;
    } catch (_) {
      this.message = '读取食材篮失败，请重新进入此页；暂时不能添加，以免覆盖已有记录。';
    }
  }

  private async selectPhoto(take: boolean): Promise<void> {
    if (this.busy) { return; }
    this.busy = true;
    this.message = '';
    try {
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      const selected = take ? await FoodPhotoService.takePhoto(context) : await FoodPhotoService.choosePhoto();
      if (!selected) { return; }
      this.photo = selected;
      this.hasResult = false;
      this.manual = false;
      this.added = false;
      this.foodName = '';
      this.gramsPerPerson = '';
      this.price = '';
    } catch (_) {
      this.message = '未能取得照片，可重试或改从相册选择。';
    } finally {
      this.busy = false;
    }
  }

  private async recognize(): Promise<void> {
    if (this.busy || !this.photo) { return; }
    if (!/^https?:\/\/[^\s]+$/.test(this.server.trim())) {
      this.message = '请在服务连接中填写有效的后端地址';
      this.showConnection = true;
      return;
    }
    this.busy = true;
    this.hasResult = false;
    this.message = '';
    this.added = false;
    try {
      this.result = await FoodRecognitionService.recognize(this.server.trim(), this.photo, this.foodName.trim());
      this.foodName = this.result.name || '';
      this.gramsPerPerson = this.result.gramsPerPerson === null ? '' : this.result.gramsPerPerson.toString();
      this.hasResult = true;
      this.manual = false;
    } catch (error) {
      const detail = (error as Error).message;
      this.message = detail || '识别失败，请检查网络和服务连接后重试';
    } finally {
      this.busy = false;
    }
  }

  private useManual(): void {
    this.manual = true;
    this.hasResult = false;
    this.gramsPerPerson = '';
    this.added = false;
    this.message = '';
  }

  private quantity(): number {
    if (!/^\d+(\.\d{1,2})?$/.test(this.gramsPerPerson.trim())) { return 0; }
    return Math.round(Number(this.gramsPerPerson) * this.people);
  }

  private priceValid(): boolean {
    return this.price.trim() === '' || /^\d+(\.\d{1,2})?$/.test(this.price.trim());
  }

  private estimate(): number | null {
    if (!this.price.trim() || !this.priceValid() || this.quantity() <= 0) { return null; }
    return Math.round(Math.round(Number(this.price) * 100) * this.quantity() / (this.priceUnit === 0 ? 500 : 1000));
  }

  private canAdd(): boolean {
    const confirmed = this.manual || (this.hasResult && !this.result.needsRetake && this.foodName.trim() === this.result.name);
    return this.ready && !this.busy && !this.saving && !this.added && confirmed &&
      this.foodName.trim().length > 0 && this.quantity() > 0 && this.priceValid();
  }

  private async add(): Promise<void> {
    if (!this.canAdd()) { return; }
    this.saving = true;
    const item: BasketItem = {
      id: Date.now().toString(), name: this.foodName.trim(), grams: this.quantity(), people: this.people,
      priceCents: this.price.trim() ? Math.round(Number(this.price) * 100) : null,
      priceBaseGrams: this.priceUnit === 0 ? 500 : 1000, totalCents: this.estimate()
    };
    const next = this.basket.concat([item]);
    try {
      await this.store.saveBasket(next);
      this.basket = next;
      this.added = true;
      this.message = '已加入食材篮并保存，可以继续拍下一份。';
    } catch (_) {
      this.message = '保存失败，请重试';
    } finally {
      this.saving = false;
    }
  }

  private async remove(id: string): Promise<void> {
    if (this.saving) { return; }
    this.saving = true;
    try {
      const next = this.basket.filter((item: BasketItem) => item.id !== id);
      await this.store.saveBasket(next);
      this.basket = next;
      this.added = false;
    } catch (_) {
      this.message = '移除失败，请重试';
    } finally {
      this.saving = false;
    }
  }

  private async saveConnection(): Promise<void> {
    if (!/^https?:\/\/[^\s]+$/.test(this.server.trim())) {
      this.message = '请输入有效的后端地址';
      return;
    }
    try {
      await this.store.saveServer(this.server.trim());
      this.showConnection = false;
      this.message = '服务地址已保存';
    } catch (_) {
      this.message = '服务地址保存失败';
    }
  }

  @Builder
  Notes(title: string, values: string[]) {
    Column({ space: 8 }) {
      Text(title).fontSize(16).fontWeight(FontWeight.Bold)
      ForEach(values, (value: string, index: number) => {
        Text(`${index + 1}. ${value}`).width('100%').fontSize(14).lineHeight(22).fontColor('#526653')
      }, (value: string, index: number) => `${index}-${value}`)
    }.width('100%').alignItems(HorizontalAlign.Start).padding(16)
      .backgroundColor('#FFFEF9').borderRadius(18)
  }

  @Builder
  ResultView() {
    if (this.hasResult && this.foodName.trim() === (this.result.name || '')) {
      if (this.result.needsRetake) {
        Text(this.result.retakeReason || '暂时看不清，请重新拍摄')
          .fontColor('#8A542F').padding(16).width('100%').backgroundColor('#FFF2D7').borderRadius(16)
      } else {
        Text(this.result.appearance === 'visible_concern' ? '外观有需注意之处' :
          this.result.appearance === 'no_obvious_issue' ? '照片中未见明显外观异常' : '外观暂时无法判断')
          .fontSize(18).fontWeight(FontWeight.Bold).width('100%').fontColor('#315B3B')
        this.Notes('照片里看到了什么', this.result.observations)
        this.Notes('现场还要检查', this.result.onSiteChecks)
        Text(this.result.buyingAdvice).width('100%').fontSize(14).lineHeight(23)
        Text('外观观察不能证明内部状态或食用安全。').fontSize(12).fontColor('#8A542F')
      }
    }
  }

  @Builder
  PurchaseForm() {
    Column({ space: 12 }) {
      Text('确认食材与计划用量').width('100%').fontSize(17).fontWeight(FontWeight.Bold)
      TextInput({ text: this.foodName, placeholder: '食材名称，可手动更正' }).maxLength(40)
        .onChange((value: string) => { this.foodName = value; this.added = false; })
      if (!this.manual && this.hasResult && this.foodName.trim() !== this.result.name) {
        Text('名称已修改，请重新分析后查看对应建议。').fontSize(12).fontColor('#8A542F')
        Button('按更正名称重新分析').onClick(() => this.recognize())
      }
      Row({ space: 12 }) {
        Text('用餐人数').layoutWeight(1)
        Button('−').enabled(this.people > 1).onClick(() => { this.people--; this.added = false; })
        Text(`${this.people} 人`)
        Button('＋').enabled(this.people < 12).onClick(() => { this.people++; this.added = false; })
      }.width('100%')
      Text('每人计划用量（克）').width('100%').fontSize(13)
      TextInput({ text: this.gramsPerPerson, placeholder: '填写或修改每人计划克数' }).type(InputType.NumberDecimal).maxLength(7)
        .onChange((value: string) => { this.gramsPerPerson = value; this.added = false; })
      if (!this.manual && this.hasResult && this.foodName.trim() === this.result.name) {
        Text(this.result.quantityNote).width('100%').fontSize(12).fontColor('#6F7C70')
      }
      Text('现场单价（选填）').width('100%').fontSize(13)
      Row({ space: 8 }) {
        TextInput({ text: this.price, placeholder: '输入标价' }).type(InputType.NumberDecimal).maxLength(8).layoutWeight(1)
          .onChange((value: string) => { this.price = value; this.added = false; })
        Select([{ value: '元 / 500克' }, { value: '元 / 千克' }]).selected(this.priceUnit)
          .value(this.priceUnit === 0 ? '元 / 500克' : '元 / 千克')
          .onSelect((index: number) => { this.priceUnit = index; this.added = false; })
      }.width('100%')
      if (!this.priceValid()) {
        Text('单价请填写非负金额，最多两位小数').fontSize(12).fontColor('#A1392B')
      }
      Text(this.quantity() > 0 ? `计划购买 ${this.quantity()} 克` : '请填写有效的计划用量')
        .width('100%').fontWeight(FontWeight.Bold)
      Text(this.estimate() === null ? '未填写单价，暂不估算费用' : `预计花费 ¥${((this.estimate() || 0) / 100).toFixed(2)}`)
        .width('100%').fontSize(20).fontColor('#176B35')
      Text('按现场单价计算，不代表市场比价。按个或盒售卖的食材可先不填价格。')
        .fontSize(12).fontColor('#6F7C70')
      Button(this.added ? '已加入食材篮' : '确认并加入食材篮').width('100%').height(46)
        .backgroundColor('#176B35').enabled(this.canAdd()).onClick(() => this.add())
    }.width('100%').padding(16).backgroundColor('#FFFEF9').borderRadius(18)
      .enabled(!this.busy && !this.saving)
  }

  build() {
    Column({ space: 14 }) {
      Row() {
        Column({ space: 5 }) {
          Text('买菜帮我选').fontSize(24).fontWeight(FontWeight.Bold)
          Text('先看一份食材，再决定买多少').fontSize(12).fontColor('#6F7C70')
        }.alignItems(HorizontalAlign.Start).layoutWeight(1)
        Button('服务连接').fontSize(12).enabled(!this.busy).onClick(() => this.showConnection = !this.showConnection)
      }.width('100%')
      if (this.showConnection) {
        Column({ space: 10 }) {
          Text('填写自己的后端地址，无需在手机填写模型密钥。').fontSize(13)
          TextInput({ text: this.server, placeholder: 'https://你的后端地址' })
            .onChange((value: string) => this.server = value)
          Text('本机调试默认 127.0.0.1:8000，需要 USB 端口转发。').fontSize(12).fontColor('#6F7C70')
          Button('保存连接').enabled(this.ready && !this.busy).onClick(() => this.saveConnection())
        }.padding(16).backgroundColor('#FFFEF9').borderRadius(18)
      }
      if (this.photo && !this.manual) {
        Image(this.photo).width('100%').height(230).objectFit(ImageFit.Contain)
          .backgroundColor('#E4EDDE').borderRadius(22)
      } else if (!this.manual) {
        Column({ space: 14 }) {
          Text('📷').fontSize(56)
          Text('拍清整体与需要检查的部位').fontSize(16)
          Text('一次选择一份食材，避开遮挡与过暗环境').fontSize(12).fontColor('#6F7C70')
        }.width('100%').height(210).justifyContent(FlexAlign.Center).backgroundColor('#E4EDDE').borderRadius(22)
      }
      Row({ space: 10 }) {
        Button('拍一张').layoutWeight(1).backgroundColor('#176B35').onClick(() => this.selectPhoto(true))
        Button('从相册选').layoutWeight(1).onClick(() => this.selectPhoto(false))
      }.width('100%').enabled(!this.busy && !this.saving)
      if (this.photo && !this.manual) {
        Text('点击识别后，照片将发送至配置的后端及 AI 服务进行分析。').fontSize(12).fontColor('#6F7C70')
        Button(this.busy ? '正在处理，请稍候…' : this.hasResult ? '重新分析' : '识别这份食材')
          .width('100%').height(46).backgroundColor('#176B35').enabled(!this.busy && !this.saving)
          .onClick(() => this.recognize())
      }
      if (this.busy) { LoadingProgress().width(32).height(32) }
      if (this.message) {
        Text(this.message).width('100%').fontSize(13).padding(14).backgroundColor('#FFF2D7').borderRadius(14)
      }
      if (!this.manual) {
        Button('也可以手动录入').fontSize(13).enabled(!this.busy && !this.saving).onClick(() => this.useManual())
      } else {
        Text('手动录入模式：不提供照片分析，请自行确认食材状态。').fontSize(12).fontColor('#6F7C70')
      }
      this.ResultView()
      if (this.hasResult || this.manual) { this.PurchaseForm() }
      Text(`食材篮 · ${this.basket.length} 份`).fontSize(18).fontWeight(FontWeight.Bold).width('100%')
      if (this.basket.length === 0) {
        Text('确认后的食材会保存在这里，供后续搭配一餐使用。').fontSize(13).fontColor('#6F7C70')
      }
      ForEach(this.basket, (item: BasketItem) => {
        Row({ space: 10 }) {
          Column({ space: 5 }) {
            Text(`${item.name} · ${item.grams}克`).fontSize(15).fontWeight(FontWeight.Bold)
            Text(item.totalCents === null ? '未填写价格' : `预计 ¥${(item.totalCents / 100).toFixed(2)}`)
              .fontSize(12).fontColor('#6F7C70')
          }.layoutWeight(1).alignItems(HorizontalAlign.Start)
          Button('移除').fontSize(12).enabled(!this.saving).onClick(() => this.remove(item.id))
        }.width('100%').padding(14).backgroundColor('#FFFEF9').borderRadius(16)
      }, (item: BasketItem) => item.id)
    }.width('100%').alignItems(HorizontalAlign.Start)
  }
}
