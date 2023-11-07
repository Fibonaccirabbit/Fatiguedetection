
import emitter from '@ohos.events.emitter';
import Constant from '../pages/utils/Constant';
import VideoCreateComponent from './Video'

@Component
struct Test{
  @State curSate:string = "正常";

  aboutToAppear(){
    // 收到eventId为1的事件后执行该回调
    let callback = (eventData) => {
      console.info('event callback');
      this.curSate = eventData.data.content
    };

    // 订阅eventId为1的事件
    emitter.on(Constant.onModelArtMp4, callback);
  }
  build(){
    Row(){
      VideoCreateComponent()
        .height("100%")
        .width("70%")

      Column(){
        Text("视频监测")
          .fontSize(24)
          .fontWeight(500)
          .height("15%")
          .width("20%")
          .backgroundColor('#F1F3F5')
          .margin({top:5})
          .textAlign(TextAlign.Center)

        Text(this.curSate)
          .fontSize(24)
          .fontWeight(500)
          .height("30%")
          .width("30%")
          .fontFamily("medium")
          .textAlign(TextAlign.Center)

      }
    }
    .width("100%")
    .alignItems(VerticalAlign.Center)


  }
}

export default Test;