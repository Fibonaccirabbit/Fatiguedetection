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
  @State curSate: string = "正常";
  private av = new AVPlayerDemo();

  aboutToAppear() {
    // 收到eventId为1的事件后执行该回调
    let callback = (eventData) => {
      console.info('event callback');
      this.curSate = eventData.data.content
      if (eventData.data.isTired == true) {
        console.info("YZJ 检测到疲劳驾驶！")
          if(this.av.isComplete){
            this.av.isComplete = false;
            this.av.avPlayerFdSrcDemo();
          }
      }
    };
    let callback2 = (eventData) => {
      console.info('event callback');
      this.av.stop();
    };
    // 订阅eventId为2的事件
    emitter.on(Constant.onModelArtReal, callback);
    emitter.on(Constant.stopAudio,callback2)
  }
  onPageShow(){

  }
  onPageHide(){
    this.av.stop();
  }
  aboutToDisappear(){
    this.av.stop();
  }
  build() {

    Column() {
      Row() {
        cameraComponent()
          .width("70%")
          .height("100%")
          .margin({ left: 20 })
        Column() {
          Text("实时监测")
            .fontSize(24)
            .fontWeight(500)
            .height("15%")
            .width("20%")
            .backgroundColor('#F1F3F5')
            .margin({ top: 5 })
            .textAlign(TextAlign.Center)
          Text(this.curSate)
            .fontSize(48)
            .fontWeight(500)
            .height("30%")
            .width("30%")
            .fontFamily("medium")
            .textAlign(TextAlign.Center)
          Button("停止音乐")
            .fancy()
            .onClick(()=>{
              this.av.stop();
            })

        }
      }
    }
    .alignItems(HorizontalAlign.Start)
  }
}

export default Home