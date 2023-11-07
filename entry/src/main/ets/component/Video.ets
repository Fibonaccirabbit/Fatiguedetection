// xxx.ets
import FileUtils from '../pages/utils/FileUtils'
import QHttp from '../pages/utils/Http'
@Extend(Button) function fancy (con:Boolean = true) {
  .fontColor(con?"#E84026":"#0A59F7")
  .backgroundColor("#F1F3F5")
  .width(120)
  .height(40)
  .border({width:2,color:"#254FF7"})

}

@Component
struct VideoCreateComponent {
  @State videoSrc: Resource = $rawfile('video1.mp4')
  @State previewUri: string = "/common/pics/videoPreview.jpg"
  @State curRate: PlaybackSpeed = PlaybackSpeed.Speed_Forward_1_00_X
  @State isAutoPlay: boolean = false
  @State showControls: boolean = true
  @State startIsPressed: boolean = false;

  controller: VideoController = new VideoController()

  build() {
    Column() {
      Video({
        src: this.videoSrc,
        previewUri: this.previewUri,
        currentProgressRate: this.curRate,
        controller: this.controller
      }).width('100%').height("70%")
        .margin({top:"3%"})
        .autoPlay(this.isAutoPlay)
        .controls(this.showControls)
        .gesture(
          // 绑定滑动手势且限制仅在竖直方向滑动时触发
          SwipeGesture({ direction: SwipeDirection.Vertical })
            // 当滑动手势触发时，获取滑动的速度和角度，实现对组件的布局参数的修改
            .onAction((event: GestureEvent) => {
              // this.speed = event.speed;
              // this.rotateAngle = event.angle;
            }))
        .onStart(() => {
          console.info('onStart')
        })
        .onPause(() => {
          console.info('onPause')
        })
        .onFinish(() => {
          console.info('onFinish')
        })
        .onError(() => {
          console.info('onError')
        })
        .onPrepared((e) => {
          console.info('onPrepared is ' + e.duration)
        })
        .onSeeking((e) => {
          console.info('onSeeking is ' + e.time)
        })
        .onSeeked((e) => {
          console.info('onSeeked is ' + e.time)
        })
        .onUpdate((e) => {
          console.info('onUpdate is ' + e.time)
        })


      Row() {
        Button('开始').onClick(() => {
          this.controller.start() // 开始播放
          this.startIsPressed = !this.startIsPressed;
          // FileUtils.printFileList()
          QHttp.toModelArt()
        }).margin(5).fancy(this.startIsPressed)
        Button('暂停').onClick(() => {

        }).margin(5).fancy(false)

      }
    }
    .width("100%")

  }
}

export default VideoCreateComponent
