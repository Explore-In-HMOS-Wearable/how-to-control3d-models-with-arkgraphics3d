import { ArkGraphics } from './ArkGraphics';

@Entry
@Component
struct Index {
  build() {
    RelativeContainer() {
      ArkGraphics()
    }
    .height('100%')
    .width('100%')
  }
}