import { FoodPurchasePanel } from '../components/FoodPurchasePanel';

interface ShoppingItem {
  name: string;
  amount: string;
  price: string;
  checked: boolean;
}

@Entry
@Component
struct Index {
  @State activeTab: number = 0;
  @State people: number = 2;
  @State selectedPlan: boolean = false;
  @State shopping: ShoppingItem[] = [
    { name: '番茄', amount: '300g', price: '¥3.2', checked: false },
    { name: '鸡蛋', amount: '3枚', price: '¥4.5', checked: false },
    { name: '嫩豆腐', amount: '200g', price: '¥3.8', checked: false },
    { name: '小油菜', amount: '250g', price: '¥4.2', checked: false },
    { name: '香菇', amount: '120g', price: '¥5.6', checked: false }
  ];

  @Builder
  Header(title: string, subtitle: string) {
    Row() {
      Column() {
        Text(title).fontSize(22).fontWeight(FontWeight.Bold).fontColor('#17321F')
        Text(subtitle).fontSize(11).fontColor('#6F7C70').margin({ top: 3 })
      }.alignItems(HorizontalAlign.Start)
      Button('✦', { type: ButtonType.Circle })
        .width(38).height(38).fontColor('#176B35').backgroundColor('#FFFEF9')
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ bottom: 18 })
  }

  @Builder
  PrimaryButton(label: string, action: () => void) {
    Button(label)
      .width('100%').height(48)
      .fontSize(14).fontWeight(FontWeight.Bold).fontColor(Color.White)
      .backgroundColor('#176B35').borderRadius(15).margin({ top: 16 })
      .onClick(action)
  }

  @Builder
  HomePage() {
    Column() {
      this.Header('菜小智', '让AI从看见食材走向会买、会搭、会做')
      Stack({ alignContent: Alignment.BottomEnd }) {
        Column() {
          Text('AI 线下生鲜决策助手').fontSize(12).fontColor('#6F7C70')
          Text('从看见食材，到会买、会搭、会做')
            .width('70%').fontSize(24).fontWeight(FontWeight.Bold)
            .fontColor('#17321F').margin({ top: 8 })
          Text('拍照识别食材，查看外观观察与挑选建议，计算计划购买费用。')
            .width('68%').fontSize(12).lineHeight(19).fontColor('#5F705F').margin({ top: 7 })
          Button('拍照识菜')
            .height(42).fontColor(Color.White).fontWeight(FontWeight.Bold)
            .backgroundColor('#176B35').borderRadius(14).margin({ top: 15 })
            .onClick(() => this.activeTab = 1)
        }.width('100%').height(215).padding(22).alignItems(HorizontalAlign.Start)
          .backgroundColor('#E4F3D3').borderRadius(28)
        Text('🥬').fontSize(86).margin({ right: 3, bottom: -8 })
      }.width('100%').height(215)

      Text('今天买什么').width('100%').fontSize(17).fontWeight(FontWeight.Bold)
        .margin({ top: 24, bottom: 12 })
      Row() {
        this.ActionCard('📷', '买菜帮我选', '挑选与用量', 1)
        this.ActionCard('🥗', '智能搭配', '补全一餐', 2)
        this.ActionCard('🧺', '购物清单', '预算不超支', 3)
      }.width('100%').justifyContent(FlexAlign.SpaceBetween)

      Column() {
        Row() {
          Column() {
            Text('番茄豆腐轻食餐').fontSize(17).fontWeight(FontWeight.Bold)
            Text('营养均衡 · 新手友好 · 25分钟').fontSize(11).fontColor('#6F7C70').margin({ top: 5 })
          }.alignItems(HorizontalAlign.Start)
          Text('88分').fontSize(15).fontWeight(FontWeight.Bold).fontColor('#176B35')
        }.width('100%').justifyContent(FlexAlign.SpaceBetween)
        Text('🍅  番茄炒蛋   🧊  香煎豆腐   🥬  清炒油菜')
          .width('100%').fontSize(12).margin({ top: 18 })
        this.PrimaryButton('生成我的一餐', () => this.activeTab = 2)
      }.width('100%').padding(18).margin({ top: 16 }).backgroundColor('#FFFEF9').borderRadius(22)

      Row() {
        Text('⏳').fontSize(22)
        Column() {
          Text('库存提醒').fontSize(13).fontWeight(FontWeight.Bold)
          Text('嫩豆腐预计明天到期，建议优先加入今晚菜单。')
            .fontSize(10).fontColor('#6F7C70').margin({ top: 4 })
        }.alignItems(HorizontalAlign.Start).margin({ left: 12 })
      }.width('100%').padding(15).margin({ top: 14 }).backgroundColor('#FFF2D7').borderRadius(18)
    }.width('100%')
  }

  @Builder
  ActionCard(icon: string, title: string, note: string, tab: number) {
    Column() {
      Text(icon).fontSize(28)
      Text(title).fontSize(11).fontWeight(FontWeight.Bold).margin({ top: 7 })
      Text(note).fontSize(9).fontColor('#6F7C70').margin({ top: 3 })
    }
    .width('31%').padding(12).backgroundColor('#FFFEF9').borderRadius(17)
    .onClick(() => this.activeTab = tab)
  }

  @Builder
  RecognizePage() {
    FoodPurchasePanel()
  }

  @Builder
  PairingPage() {
    Column() {
      this.Header('智能搭配', '营养 × 预算 × 库存')
      Text('已选食材').width('100%').fontSize(17).fontWeight(FontWeight.Bold).margin({ bottom: 12 })
      Row() {
        Text('🍅 番茄 300g').padding(12).backgroundColor('#FFFEF9').borderRadius(16)
        Text('🧊 豆腐 200g').padding(12).backgroundColor('#FFFEF9').borderRadius(16).margin({ left: 8 })
      }.width('100%')

      Row() {
        Text('用餐人数').fontSize(14).fontWeight(FontWeight.Bold)
        Row() {
          Button('−').onClick(() => this.people = Math.max(1, this.people - 1))
          Text(`${this.people}人`).fontSize(14).fontWeight(FontWeight.Bold).margin({ left: 8, right: 8 })
          Button('＋').onClick(() => this.people = Math.min(6, this.people + 1))
        }
      }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding(17)
       .margin({ top: 17 }).backgroundColor('#FFFEF9').borderRadius(20)

      Text('AI 一餐方案').width('100%').fontSize(17).fontWeight(FontWeight.Bold).margin({ top: 24, bottom: 12 })
      Column() {
        Row() {
          Column() {
            Text('方案 A · 番茄豆腐轻食餐').fontSize(16).fontWeight(FontWeight.Bold)
            Text('88分 · 预计¥28.6 · 25分钟').fontSize(11).fontColor('#6F7C70').margin({ top: 5 })
          }.alignItems(HorizontalAlign.Start)
        }.width('100%')
        Text('🍅 番茄炒蛋   🧊 香煎豆腐   🥬 清炒油菜').fontSize(12).margin({ top: 18 })
        this.PrimaryButton('选择并生成清单', () => {
          this.selectedPlan = true;
          this.activeTab = 3;
        })
      }.width('100%').padding(18).backgroundColor('#FFFEF9').borderRadius(22)
    }.width('100%')
  }

  @Builder
  ShoppingPage() {
    Column() {
      this.Header('购物清单', '缺什么、买多少、预计花多少')
      Row() {
        Column() {
          Text('方案预算').fontSize(12).fontColor(Color.White)
          Text('¥28.6').fontSize(31).fontWeight(FontWeight.Bold).fontColor(Color.White)
          Text('低于30元预算').fontSize(10).fontColor('#D8F2DC')
        }.alignItems(HorizontalAlign.Start)
        Text('🧺').fontSize(48)
      }.width('100%').justifyContent(FlexAlign.SpaceBetween).padding(19)
       .backgroundColor('#247941').borderRadius(23)

      Text('待购食材').width('100%').fontSize(17).fontWeight(FontWeight.Bold).margin({ top: 24, bottom: 10 })
      ForEach(this.shopping, (item: ShoppingItem, index: number) => {
        Row() {
          Text(item.checked ? '✓' : '')
            .width(28).height(28).textAlign(TextAlign.Center).fontColor(Color.White)
            .backgroundColor(item.checked ? '#48A95E' : '#E8EDE4').borderRadius(10)
          Column() {
            Text(`${item.name} · ${item.amount}`).fontSize(13).fontWeight(FontWeight.Bold)
            Text('参考价已核验 · 点击标记已购').fontSize(9).fontColor('#6F7C70').margin({ top: 3 })
          }.alignItems(HorizontalAlign.Start).layoutWeight(1).margin({ left: 11 })
          Text(item.price).fontSize(13).fontWeight(FontWeight.Bold)
        }.width('100%').padding(13).margin({ bottom: 8 }).backgroundColor('#FFFEF9').borderRadius(17)
         .onClick(() => {
           this.shopping[index].checked = !this.shopping[index].checked;
           this.shopping = this.shopping.slice();
         })
      }, (item: ShoppingItem) => item.name)
      Text('理性消费：若现场价格明显高于参考区间，可替换同类当季食材或调整购买量。')
        .fontSize(11).lineHeight(18).fontColor('#765F43').padding(14)
        .backgroundColor('#FFF2D7').borderRadius(16)
      this.PrimaryButton('食材买齐，进入做菜模式', () => {
        this.getUIContext().getPromptAction().showToast({ message: '定量菜谱：番茄300g、鸡蛋3枚、油12ml' });
      })
    }.width('100%')
  }

  @Builder
  ProfilePage() {
    Column() {
      this.Header('我的饮食档案', '让建议越用越贴合')
      Column() {
        Text('本周饮食概览').width('100%').fontSize(17).fontWeight(FontWeight.Bold)
        Row() {
          this.Stat('12', '食材种类')
          this.Stat('3.2', '蔬菜份/日')
          this.Stat('¥29', '餐均成本')
        }.width('100%').justifyContent(FlexAlign.SpaceBetween).margin({ top: 16 })
      }.width('100%').padding(18).backgroundColor('#FFFEF9').borderRadius(22)
      Text('家庭库存').width('100%').fontSize(17).fontWeight(FontWeight.Bold).margin({ top: 24, bottom: 10 })
      Column() {
        this.Stock('🧊', '嫩豆腐', '200g · 冷藏', '明天到期')
        this.Stock('🥚', '鸡蛋', '4枚 · 冷藏', '余量充足')
        this.Stock('🍜', '挂面', '约300g · 常温', '可用3餐')
      }.width('100%').padding(16).backgroundColor('#FFFEF9').borderRadius(22)
    }.width('100%')
  }

  @Builder
  Stat(value: string, label: string) {
    Column() {
      Text(value).fontSize(20).fontWeight(FontWeight.Bold)
      Text(label).fontSize(9).fontColor('#6F7C70').margin({ top: 4 })
    }.width('31%').padding(14).backgroundColor('#F4F7EE').borderRadius(16)
  }

  @Builder
  Stock(icon: string, name: string, amount: string, note: string) {
    Row() {
      Text(icon).width(40).height(40).fontSize(22).textAlign(TextAlign.Center).backgroundColor('#E3F4E5').borderRadius(13)
      Column() {
        Text(name).fontSize(13).fontWeight(FontWeight.Bold)
        Text(amount).fontSize(10).fontColor('#6F7C70').margin({ top: 3 })
      }.alignItems(HorizontalAlign.Start).layoutWeight(1).margin({ left: 10 })
      Text(note).fontSize(9).fontColor(note === '明天到期' ? '#E15B4F' : '#176B35')
    }.width('100%').padding({ top: 12, bottom: 12 })
  }

  @Builder
  BottomNav() {
    Row() {
      this.NavItem(0, '⌂', '首页')
      this.NavItem(1, '◎', '选食材')
      this.NavItem(2, '◫', '搭配')
      this.NavItem(3, '✓', '清单')
      this.NavItem(4, '○', '我的')
    }.width('100%').height(72).padding({ left: 8, right: 8 })
     .justifyContent(FlexAlign.SpaceAround).backgroundColor('#FFFEF9')
  }

  @Builder
  NavItem(index: number, icon: string, label: string) {
    Column() {
      Text(icon).fontSize(20).fontColor(this.activeTab === index ? '#176B35' : '#929A92')
      Text(label).fontSize(9).fontColor(this.activeTab === index ? '#176B35' : '#929A92').margin({ top: 3 })
    }.layoutWeight(1).onClick(() => this.activeTab = index)
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          if (this.activeTab !== 1) {
            Text('本页为功能原型，所示菜单、价格和库存是演示数据')
              .fontSize(11).fontColor('#8A542F').width('100%').margin({ bottom: 12 })
          }
          if (this.activeTab === 0) {
            this.HomePage()
          } else if (this.activeTab === 1) {
            this.RecognizePage()
          } else if (this.activeTab === 2) {
            this.PairingPage()
          } else if (this.activeTab === 3) {
            this.ShoppingPage()
          } else {
            this.ProfilePage()
          }
        }.width('100%').padding({ left: 18, right: 18, top: 18, bottom: 28 })
      }.layoutWeight(1).scrollBar(BarState.Off)
      this.BottomNav()
    }.width('100%').height('100%').backgroundColor('#F4F7EE')
  }
}
