import { common } from '@kit.AbilityKit';
import { PHOTO_LIBRARY, LibraryPhoto } from '../model/PhotoLibrary';

@Component
export struct PhotoLibrarySheet {
  @State page: number = 0;
  @State selected: number = -1;
  onClose: () => void = () => {};

  private async openLink(url: string): Promise<void> {
    try {
      const context = this.getUIContext().getHostContext() as common.UIAbilityContext;
      await context.startAbility({ action: 'ohos.want.action.viewData', uri: url,
        entities: ['entity.system.browsable'] });
    } catch (_) { this.getUIContext().getPromptAction().showToast({ message: '暂时无法打开来源页面' }); }
  }

  build() {
    Column({ space: 10 }) {
      Row() {
        Text(this.selected < 0 ? '菜品图库' : PHOTO_LIBRARY[this.selected].name).fontSize(21).fontWeight(FontWeight.Bold)
        Blank()
        Button('×').width(44).height(44).backgroundColor(Color.Transparent).fontColor('#202A23')
          .accessibilityText('关闭图库').onClick(this.onClose)
      }.width('100%')
      if (this.selected < 0) {
        Text(`${PHOTO_LIBRARY.length} 道家常菜 · 成品参考照片`).fontSize(12).fontColor('#637067')
        ForEach([0, 1], (row: number) => {
          Row({ space: 10 }) {
            ForEach(PHOTO_LIBRARY.slice(this.page * 4 + row * 2, this.page * 4 + row * 2 + 2), (photo: LibraryPhoto) => {
              Button({ type: ButtonType.Normal }) {
                Column({ space: 6 }) {
                  Image($rawfile(photo.file)).width('100%').height(86).objectFit(ImageFit.Cover)
                  Text(photo.name).fontSize(14).fontColor('#202A23').margin({ bottom: 8 })
                }.width('100%')
              }.layoutWeight(1).padding(0).backgroundColor('#FFFEF9').borderRadius(12).clip(true)
                .onClick(() => this.selected = PHOTO_LIBRARY.findIndex((item: LibraryPhoto) => item.id === photo.id))
            }, (photo: LibraryPhoto) => photo.id)
          }.width('100%')
        })
        Row() {
          Button('上一页').height(44).backgroundColor('#E5EDDC').fontColor('#286749').enabled(this.page > 0)
            .onClick(() => this.page--)
          Blank()
          Text(`${this.page + 1} / ${Math.ceil(PHOTO_LIBRARY.length / 4)}`).fontSize(12)
          Blank()
          Button('下一页').height(44).backgroundColor('#E5EDDC').fontColor('#286749')
            .enabled((this.page + 1) * 4 < PHOTO_LIBRARY.length).onClick(() => this.page++)
        }.width('100%')
      } else {
        Image($rawfile(PHOTO_LIBRARY[this.selected].file)).width('100%').height(160).objectFit(ImageFit.Contain)
        Text('成品参考照片，实际配料和摆盘以菜谱为准。').fontSize(12).fontColor('#637067')
        Text(`摄影：${PHOTO_LIBRARY[this.selected].author}`).fontSize(12).fontColor('#637067')
        Row({ space: 8 }) {
          Button(PHOTO_LIBRARY[this.selected].license).layoutWeight(1).fontSize(12).height(44)
            .backgroundColor('#E5EDDC').fontColor('#286749').onClick(() => this.openLink(PHOTO_LIBRARY[this.selected].licenseUrl))
          Button('原图与来源 ↗').layoutWeight(1).fontSize(12).height(44)
            .backgroundColor('#E5EDDC').fontColor('#286749').onClick(() => this.openLink(PHOTO_LIBRARY[this.selected].sourcePage))
        }
        Button('返回图库').width('100%').height(44).backgroundColor('#286749').fontColor(Color.White)
          .onClick(() => this.selected = -1)
      }
    }.width('100%').padding({ left: 20, right: 20, top: 8, bottom: 24 })
  }
}
