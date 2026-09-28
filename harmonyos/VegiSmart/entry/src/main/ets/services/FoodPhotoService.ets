import { common } from '@kit.AbilityKit';
import { camera, cameraPicker } from '@kit.CameraKit';
import { fileIo, fileUri } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { util } from '@kit.ArkTS';

export class FoodPhotoService {
  static async takePhoto(context: common.UIAbilityContext): Promise<string> {
    // 固定沙箱缓存文件，避免每次拍照留下新文件或自动存入相册。
    const path = `${context.cacheDir}/food_capture.jpg`;
    const file = await fileIo.open(path, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE);
    await fileIo.close(file);
    const result = await cameraPicker.pick(context, [cameraPicker.PickerMediaType.PHOTO], {
      cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK,
      saveUri: fileUri.getUriFromPath(path)
    });
    if (result.resultCode !== 0 || !result.resultUri) { return ''; }
    return FoodPhotoService.toDataUrl(result.resultUri);
  }

  static async choosePhoto(): Promise<string> {
    const picker = new photoAccessHelper.PhotoViewPicker();
    const selection = await picker.select({
      MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
      maxSelectNumber: 1
    });
    if (selection.photoUris.length === 0) { return ''; }
    return FoodPhotoService.toDataUrl(selection.photoUris[0]);
  }

  private static async toDataUrl(uri: string): Promise<string> {
    const file = await fileIo.open(uri, fileIo.OpenMode.READ_ONLY);
    let source: image.ImageSource | undefined = undefined;
    let pixels: image.PixelMap | undefined = undefined;
    let packer: image.ImagePacker | undefined = undefined;
    try {
      source = image.createImageSource(file.fd);
      const info = await source.getImageInfo();
      const scale = Math.min(1, 1600 / Math.max(info.size.width, info.size.height));
      pixels = await source.createPixelMap({
        desiredSize: {
          width: Math.max(1, Math.round(info.size.width * scale)),
          height: Math.max(1, Math.round(info.size.height * scale))
        }
      });
      packer = image.createImagePacker();
      const buffer = await packer.packing(pixels, { format: 'image/jpeg', quality: 85 });
      if (buffer.byteLength > 4000000) { throw new Error('图片过大，请重新拍摄单份食材'); }
      const encoded = new util.Base64Helper().encodeToStringSync(new Uint8Array(buffer));
      return `data:image/jpeg;base64,${encoded}`;
    } finally {
      if (packer) { await packer.release(); }
      if (pixels) { await pixels.release(); }
      if (source) { await source.release(); }
      await fileIo.close(file);
    }
  }
}
