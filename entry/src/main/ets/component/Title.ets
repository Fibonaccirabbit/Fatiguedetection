import font from '@ohos.font';
@Component
struct Title {
  aboutToAppear() {
    font.registerFont({
      familyName: 'medium',
      familySrc: '/font/HarmonyOS_Sans_Medium.ttf' // font文件与pages目录同级
    })
  }
  build() {
     Row(){
       Text("Fatigue detection")
         .fontWeight(400)
         .fontSize(24)
         .width("100%")
         .margin(10)
         .fontFamily('medium')
         .fontColor(Color.Black)

     }
     .height("100%")
     .width("100%")
     .alignItems(VerticalAlign.Center)
     .justifyContent(FlexAlign.Start)
    .backgroundColor("#F1F3F5")
  }
}

export default Title;