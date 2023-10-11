
import emitter from '@ohos.events.emitter'
import systemDateTime from '@ohos.systemDateTime'
import Constant from '../pages/utils/Constant'
import LogItem from '../pages/utils/LogItem'

@Entry
@Component
struct Settings{
  private fruits: string[] = ['音效1', '音效2', '音效3', '音效4']
  @State select: number = 0
  @State arr : number []= []
  logArr: Array<LogItem> = []
  @State alignListItem: ListItemAlign = ListItemAlign.Start


  aboutToAppear(){
    console.info("YZJ settings!")
    // 收到eventId为1的事件后执行该回调
    let callback = (eventData) => {
      console.info('YZJ event callback');
      try {
        systemDateTime.getCurrentTime(true, (error, time) => {
          if (error) {
            console.info(`YZJ Failed to get currentTime. message: ${error.message}, code: ${error.code}`);
            return;
          }
          this.toLog(time,eventData.data.content)
          console.info(`YZJ Succeeded in getting currentTime : ${time}`);
        });
      } catch(e) {
        console.info(`YZJ Failed to get currentTime. message: ${e.message}, code: ${e.code}`);
      }
    };
    // 订阅eventId为2的事件
    emitter.on(Constant.onModelArtReal, callback);
  }
  toLog(time,state){
    console.info("YZJ 更新日志")
    const nanoseconds =  time;
    const milliseconds = Math.floor(nanoseconds/1000000);
    const currentDate = new Date()

    currentDate.setTime(milliseconds)
    let newLog = new LogItem();
    newLog.time = currentDate.getHours()+":"+currentDate.getMinutes()+":"+currentDate.getSeconds()
    newLog.state = state;
    console.info("YZJ 更新日志"+newLog.time)
    this.arr.push(this.arr.length)
    this.logArr.push(newLog)
  }
  build(){
     Row(){
       Row(){
         Text("警报音效：   ")
           .fontSize(16)
           .fontWeight(400)
           .margin({top:"26%"})

         TextPicker({ range: this.fruits, selected: this.select })
           .onChange((value: string, index: number) => {
             this.select = index;
             Constant.audioEffect = "0" + index.toString() + '.wav';
             console.info('Picker item changed, value: ' + value + ', index: ' + index)
           })
           .height("100%")

       }
       .backgroundColor('#F1F3F5')
       .border({radius:20})
       .justifyContent(FlexAlign.Center)
       .alignItems(VerticalAlign.Top)
       .width("40%")
       .margin({top:"5%",left:"5%",bottom:"5%"})

       Column(){
         Row(){
           Text("自动更新 ")
             .fontSize(16)
             .fontWeight(400)
           Toggle({ type: ToggleType.Switch, isOn: false })
             .selectedColor('#007DFF')
             .switchPointColor('#FFFFFF')
             .onChange((isOn: boolean) => {
               console.info('Component status:' + isOn)
             })
         }
         Row(){
           Text("开启日志")
             .fontSize(16)
             .fontWeight(400)
           Toggle({ type: ToggleType.Switch, isOn: false })
             .selectedColor('#007DFF')
             .switchPointColor('#FFFFFF')
             .onChange((isOn: boolean) => {
               console.info('Component status:' + isOn)
             })
         }

         List({ space: 20, initialIndex: 0 }) {
           ForEach(this.arr, (item) => {
             ListItem() {
               Row(){
                 Text(this.logArr[item].time)
                   .width('30%').height(30).fontSize(16)
                   .textAlign(TextAlign.Center).borderRadius(10).backgroundColor(0xFFFFFF)
                 Text(this.logArr[item].state)
                   .width('70%').height(30).fontSize(16)
                   .textAlign(TextAlign.Center).borderRadius(10).backgroundColor(0xFFFFFF)
               }
             }
           }, item => item)
         }
         .listDirection(Axis.Vertical) // 排列方向
         .scrollBar(BarState.Off)
         .divider({ strokeWidth: 2, color: 0xFFFFFF, startMargin: 20, endMargin: 20 }) // 每行之间的分界线
         .edgeEffect(EdgeEffect.Spring) // 边缘效果设置为Spring
         .onScroll((scrollOffset: number, scrollState: ScrollState) => {
           console.info(`onScroll scrollState = ${ScrollState[scrollState]}, scrollOffset = ${[scrollOffset]}`)
         })
         .height("60%")
         .width('90%')

       }
       .backgroundColor('#F1F3F5')
       .border({radius:20})
       .justifyContent(FlexAlign.Center)
       .width("45%")
       .margin("5%")
     }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Start)
  }
}

export default Settings;