import emitter from '@ohos.events.emitter';
import  AVPlayerDemo from '../pages/utils/AudioManager';
import Constant from '../pages/utils/Constant';
import cameraComponent from './Camera'

@Extend(Button) function fancy(con: Boolean = true) {
  .fontColor(con ? "#E84026" : "#0A59F7")
  .backgroundColor("#F1F3F5")
  .width(120)
  .height(40)
  .border({ width: 2, color: "#254FF7" })

}

@Entry
@Component
struct Home {
  @State curState: string = "正常";
  private av = new AVPlayerDemo();

  // 页面初始化生命周期函数
  aboutToAppear() {
    // 订阅eventID为1的事件，该事件时疲劳检测结果的通知 通过curState修改UI
    let callback = (eventData) => {
      // console.info('event callback');
      this.curState = eventData.data.content
      // if (eventData.data.isTired == true) {
      //   console.info("YZJ 检测到疲劳驾驶！")
      //     if(this.av.isComplete){
      //       this.av.isComplete = false;
      //       this.av.avPlayerFdSrcDemo();
      //     }
      // }
    };
    let callback2 = (eventData) => {
      console.info('event callback');
      this.av.stop();
    };
    // 订阅云服务通知
    emitter.on(Constant.onModelArtReal, callback);
    // 订阅警报通知
    emitter.on(Constant.stopAudio,callback2)
  }
  onPageShow(){

  }
  onPageHide(){
    // 页面隐藏时关闭音乐
    this.av.stop();
  }
  aboutToDisappear(){
    // 退出页面时关闭音乐
    this.av.stop();
  }
  build() {
    Column() {
      Row() {
        // 摄像头组件 由component/Camera.ets导出
        cameraComponent()
          .width("70%")
          .height("100%")
          .margin({ left: 20 })
        // 实时检测字样
        Column() {
          Text("实时监测")
            .fontSize(24)
            .fontWeight(500)
            .height("15%")
            .width("20%")
            .backgroundColor('#F1F3F5')
            .margin({ top: 5 })
            .textAlign(TextAlign.Center)
          Text(this.curState)
            .fontSize(48)
            .fontWeight(500)
            .height("30%")
            .width("30%")
            .fontFamily("medium")
            .textAlign(TextAlign.Center)
          Button("停止音乐")
            .fancy()
            .onClick(()=>{
              // this.av.stop();
            })

        }
      }
    }
    .alignItems(HorizontalAlign.Start)
  }
}

export default Home