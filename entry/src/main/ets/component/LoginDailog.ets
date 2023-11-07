
@Extend(Button) function fancy() {
  .fontColor("#0A59F7")
  .backgroundColor("#0A59F7")
  .width(120)
  .height(40)
  .border({ width: 2, color: "#254FF7" })
}


@CustomDialog
struct LoginDialog {
  controller: CustomDialogController
  cancel: () => void
  confirm: () => void
  build() {
    Column() {
      Image("/common/pics/ic_user_portrait.svg")
      .objectFit(ImageFit.Contain)
      .width("7%")
      .margin({top:20})
      Row(){
        Text('账号: ').fontSize(20).margin({ top: 10, bottom: 10 })
        TextInput({text:"admin"})
          .type(InputType.Number)
          .width("50%")
      }
      Row(){
        Text('密码: ').fontSize(20).margin({ top: 10, bottom: 10 })
        TextInput({text:"123456"})
          .type(InputType.Password)
          .width("50%")
      }
      Row({space:20}) {
        Button('取消')
          .fancy()
          .onClick(() => {
            // this.controller.close()
            this.cancel()
          }).fontColor(Color.Black)
          .backgroundColor("#F1F3F5")
        Button('确认')
          .fancy()
          .onClick(() => {
            this.controller.close()
            this.confirm()
          }).fontColor(Color.White)

      }.margin({ bottom: 10,top:20})
    }
  }
}
export  default  LoginDialog
