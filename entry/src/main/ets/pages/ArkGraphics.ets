import { Animation, Scene, Camera, EnvironmentBackgroundType, SceneResourceFactory, Color } from '@kit.ArkGraphics3D';
import { AnimatorResult } from '@kit.ArkUI';
import { Constants } from '../utils/Constant';
import Logger from '../utils/Logger';

@Entry
@Component
export struct ArkGraphics {
  @State sceneOpt: SceneOptions | null = null;
  private progressValue: number = 0;
  private animationEnabled: Boolean = false;
  private animationDuration: number = 0;
  private animationIsRunning: Boolean = false;
  @State animationCallbackInvoked: string = Constants.STRING_NO;
  @State enable: boolean = true;
  scene: Scene | null = null;
  cam: Camera | null = null;
  backAnimator: AnimatorResult | undefined = undefined;
  anim: Animation | null = null;

  aboutToAppear(): void {
    this.init();
  }

  onPageHide(): void {
    if (this.scene) {
      this.scene.destroy();
    }

    this.cam = null;
    this.scene = null;
  }

  init(): void {
    this.backAnimator = this.getUIContext().createAnimator(Constants.ANIMATION_OPTION);
    this.backAnimator.onFrame = () => {
      if (this.scene?.animations[0]) {
        this.animationEnabled = this.scene.animations[0].enabled;
        this.animationDuration = this.scene.animations[0].duration;
        this.animationIsRunning = this.scene.animations[0].running;
        this.progressValue = this.scene.animations[0].progress;
      }
    }
    if (this.scene === null) {
      Scene.load($rawfile('gltf/flower/scene.gltf'))
        .then(async (result: Scene) => {
          this.scene = result;
          let rf: SceneResourceFactory = this.scene.getResourceFactory();
          this.scene.environment.backgroundType = EnvironmentBackgroundType.BACKGROUND_NONE;

          if (this.anim) {
            this.anim.enabled = true;
            this.anim.onStarted(() => {
              Logger.info('onStarted');
              this.animationCallbackInvoked = 'animation on start';
            });

            this.anim.onFinished(() => {
              Logger.info('onFinished');
              this.animationCallbackInvoked = 'animation on finish';
            });

            Logger.info('ready to create a new animation.');
          } else {
            Logger.error('No animation found in scene.');
          }

          this.cam = await rf.createCamera({ 'name': 'Camera' });
          this.cam.enabled = true;
          this.cam.clearColor = {
            r: 1,
            g: 1,
            b: 1,
            a: 1
          } as Color;

          this.sceneOpt = { scene: this.scene, modelType: ModelType.SURFACE } as SceneOptions;
        })
        .catch((error: string) => {
          Logger.error(`init error: ${error}`);
        });
    }
  }

  build() {
    Scroll() {
      Column() {
        Column() {
          if (this.sceneOpt) {
            Component3D(this.sceneOpt)
              .renderWidth($r('app.string.sixty_percent'))
              .renderHeight($r('app.string.sixty_percent'))
              .backgroundColor(Color.Transparent)
              .onAppear(() => {
                if (!this.scene || !this.scene.animations[0]) {
                  return;
                }
                let anim: Animation = this.scene.animations[0];
                anim.onStarted(() => {
                  this.animationCallbackInvoked = Constants.STRING_START;
                });
                anim.onFinished(() => {
                  this.animationCallbackInvoked = Constants.STRING_FINISH;
                });
                this.backAnimator?.play();
              })
          } else {
            Text($r('app.string.loading')).fontColor(Color.Grey)
          }
        }
        .width('90%')
        .height('80%')
        .borderRadius($r('app.float.board_radius_normal'))
        .justifyContent(FlexAlign.Center)

        Column({ space: Constants.LIST_SPACE }) {
          Button(this.enable ? 'Disable animation' : 'Enable animation')
            .onClick(() => {
              if (!this.scene || !this.scene.animations[0]) {
                return;
              }
              this.enable = !this.enable;
              this.scene.animations[0].enabled = this.enable;
            })
            .width(Constants.FULL_PERCENT)
            .height(24)
            .margin({ top: 4 })

          Button($r('app.string.start'))
            .onClick(async () => {
              if (!this.scene || !this.scene.animations[0]) {
                return;
              }
              let anim: Animation = this.scene.animations[0];
              anim.start();
            })
            .width(Constants.FULL_PERCENT)
            .height(24)

          Button($r('app.string.pause'))
            .onClick(async () => {
              if (!this.scene || !this.scene.animations[0]) {
                return;
              }
              let anim: Animation = this.scene.animations[0];
              anim.pause();
            })
            .width(Constants.FULL_PERCENT)
            .height(24)

          Button('Rotate 45°')
            .onClick(() => {
              if (!this.scene || !this.scene.root) {
                return;
              }
              const node = this.scene.root.getNodeByPath('Sketchfab_Scene/Sketchfab_model/root/GLTF_SceneRootNode');
              if (node) {
                const angle = Math.PI / 4;
                node.rotation = {
                  x: Math.sin(angle / 2),
                  y: 0,
                  z: 0,
                  w: Math.cos(angle / 2)
                };
              } else {
                console.error('Node cannot find!');
              }
            })
            .width(Constants.FULL_PERCENT)
            .height(24)

          Button('Move Down 2 units')
            .onClick(() => {
              if (!this.scene || !this.scene.root) {
                return;
              }
              const node = this.scene.root.getNodeByPath('Sketchfab_Scene/Sketchfab_model/root/GLTF_SceneRootNode');
              if (node) {
                node.position.y -= 2;
              } else {
                console.error('Node cannot find!');
              }
            })
            .width(Constants.FULL_PERCENT)
            .height(24)

          Button('Move Up 2 units')
            .onClick(() => {
              if (!this.scene || !this.scene.root) {
                return;
              }
              const node = this.scene.root.getNodeByPath('Sketchfab_Scene/Sketchfab_model/root/GLTF_SceneRootNode');
              if (node) {
                node.position.y += 2;
              } else {
                console.error('Node cannot find!');
              }
            })
            .width(Constants.FULL_PERCENT)
            .height(24)

        }
        .width(Constants.FULL_PERCENT)
        .justifyContent(FlexAlign.End)
      }
      .width(Constants.FULL_PERCENT)
      .padding($r('app.float.page_padding_left'))
      .justifyContent(FlexAlign.SpaceBetween)
    }.width(Constants.FULL_PERCENT)
    .height(Constants.FULL_PERCENT)

  }
}