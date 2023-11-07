import font from '@ohos.font'
import cameraComponent from '../component/Camera'
import camera from '../component/Camera'
import Home from '../component/Home'
import LoadDialog from '../component/LoadDailog'
import LoginDialog from '../component/LoginDailog'
import Settings from '../component/Settings'
import Test from '../component/Test'
import Title from "../component/Title"
import Upgrade from '../component/Upgrade'
import Constant from './utils/Constant'

// xxx.ets
@Entry
@Component
struct Index {
  @State fontColor: string = '#182431'
  @State selectedFontColor: string = '#007DFF'
  @State currentIndex: number = 0
  private controller: TabsController = new TabsController()

  // 对话框
  dialogController: CustomDialogController = new CustomDialogController({
    builder: LoginDialog({
      cancel: this.onCancel,
      confirm: this.onAccept,
    }),
    alignment: DialogAlignment.Center,  // 可设置dialog的对齐方式，设定显示在底部或中间等，默认为底部显示
  })

  aboutToAppear() {
    // 注册字体
    font.registerFont({
      familyName: 'medium',
      familySrc: '/font/HarmonyOS_Sans_Medium.ttf' // font文件与pages目录同级
    })
  }
  onPageShow(){
   this.dialogController.open()
  }
  onCancel(){
   // this.dialogController.close()
  }
  onAccept(){
    // this.dialogController.close();
  }
  @Builder TabBuilder(index: number, name: string, src: string []) {
    Column() {
      Image(this.currentIndex === index ? src[0] : src[1])
        .width(24)
        .height(24)
        .margin({ bottom: 4 })
        .objectFit(ImageFit.Contain)
      Text(name)
        .fontColor(this.currentIndex === index ? this.selectedFontColor : this.fontColor)
        .fontSize(10)
        .fontWeight(500)
        .lineHeight(14)
    }.width('100%').height('100%').justifyContent(FlexAlign.Center)
  }

  build() {
    Column() {
      Title()
        .height("15%")
      Tabs({ barPosition: BarPosition.Start, controller: this.controller }) {
        // 主页
        TabContent() {
          Home()
        }
        .backgroundColor("#FFFFFF")
        .tabBar(this.TabBuilder(0, "主页", Constant.tabBarHomeUI))
        // 单视频检测页面
        TabContent() {
          Column() {
            Row() {
              Test()
                .margin({ left: "5%" })
            }
          }
          .backgroundColor("#FFFFFF")
          .width("100%")
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.Start)
        }
        .tabBar(this.TabBuilder(1, "测试", Constant.tabBarTestUI))
        // 系统更新页面
        TabContent() {
          Column() {
            Upgrade()
              .width("70%")
          }
          .width("100%")
          .alignItems(HorizontalAlign.Center)
        }
        .backgroundColor("#FFFFFF")
        .tabBar(this.TabBuilder(2, "OTA", Constant.tabBarUpgradeUI))
        // 设置页面
        TabContent() {
          Settings()
            .width("100%")
            .height("100%")
        }
        .backgroundColor("#FFFFFF")
        .tabBar(this.TabBuilder(3, "设置", Constant.tabBarSettingUI))
      }
      .vertical(true)
      .height("85%")
      .onChange((index: number) => {
        this.currentIndex = index
      })
      .backgroundColor('#F1F3F5')
    }.width('100%')
  }
}
