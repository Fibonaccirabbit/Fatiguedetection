// xxx.ets
import LoadDialog from './LoadDailog'
@Extend(Button) function fancy(con: Boolean = true) {
  .fontColor(Color.White)
  .backgroundColor("#0A59F7")
  .width(120)
  .height(40)
  .border({ width: 2, color: "#254FF7" })

}

@Component
struct Upgrade {
  @State videoSrc: Resource = $rawfile('video1.mp4')
  @State previewUri: string = "/common/pics/videoPreview.jpg"
  @State curRate: PlaybackSpeed = PlaybackSpeed.Speed_Forward_1_00_X
  @State isAutoPlay: boolean = false
  @State showControls: boolean = true
  @State startIsPressed: boolean = false;
  controller: VideoController = new VideoController()
  dialogController: CustomDialogController = new CustomDialogController({
    builder: LoadDialog({
      cancel: this.onCancel,
      confirm: this.onAccept,
    }),
    alignment: DialogAlignment.Center,  // 可设置dialog的对齐方式，设定显示在底部或中间等，默认为底部显示
  })
  onCancel(){

  }
  onAccept(){

  }
  build() {
    Column() {
      Image("/common/pics/ic_logo.png")
        .objectFit(ImageFit.Contain)
        .width('100%')
        .backgroundColor("#F1F3F5")
        .height("60%")
        .border({radius:20})

      Column() {
        Text("当前版本：V1.0")
        Button('检查更新').onClick(() => {
        }).margin(5).fancy(this.startIsPressed)
          .onClick(()=>{
            this.dialogController.open()
          })
      }
      .margin({top:"8%"})
      .backgroundColor("#ffffffff")

    }
    .width("100%")

  }
}

export default Upgrade
