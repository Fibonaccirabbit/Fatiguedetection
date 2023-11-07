
@Extend(Button) function fancy() {
  .fontColor("#0A59F7")
  .backgroundColor("#0A59F7")
  .width(120)
  .height(40)
  .border({ width: 2, color: "#254FF7" })
}

@Entry
@CustomDialog
struct LoadDialog {
  controller: CustomDialogController
  cancel: () => void
  confirm: () => void
  build() {
    Column() {
      Row(){
        Text('检查更新中: ').fontSize(20).margin({ top: 10, bottom: 10 })
        Button({  stateEffect: true }) {
          LoadingProgress().width(50).height(50).color("#0A59F7").backgroundColor("#FFFFFF")
        }
      }

      Row({space:20}) {
        Button('取消')
          .fancy()
          .onClick(() => {
            // this.controller.close()
            this.cancel()
          }).fontColor(Color.White)


      }.margin({ bottom: 10,top:20})
    }
  }
}
export  default  LoadDialog
