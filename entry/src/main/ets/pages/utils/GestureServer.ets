import socket from '@ohos.net.socket';
import wifi from '@ohos.wifi';
import emitter from '@ohos.events.emitter';
import QHttp from './Http';
import Constant from './Constant';

let event2 = {
  eventId: 2,
  priority: emitter.EventPriority.HIGH
};
export default class GestureServer {
  public static udp;
  public static local_ip = "192.168.43.45";
  public static remote_ip = "192.168.43.127"
  public static isConnected = false;
  public static numOfTimer = 0;
  public static flag = 0;

  public static start(){
    this.udp = socket.constructUDPSocketInstance();
    // this.getIpAddress()
    this.udp.bind({address: this.local_ip, port: 8888, family: 1}, err => {
      if (err) {
        console.log('YZJ bind fail');
        console.log("YZJ"+JSON.stringify(err))
        return;
      }
      console.log('YZJ bind success');
    })

    let messageView = '';
    this.udp.on('message', value => {
      for (var i = 0; i < value.message.length; i++) {
        let messages = value.message[i]
        let message = String.fromCharCode(messages);
        messageView += message;
      }
      console.log('on message message: ' + JSON.stringify(messageView));
      console.log('remoteInfo: ' + JSON.stringify(value.remoteInfo));
    });
  }

  public static getIpAddress() {
    let ip = wifi.getIpInfo().ipAddress;
    this.local_ip= (ip >> 24 & 0xFF) + "." + ((ip >> 16) & 0xFF) + "." + ((ip >> 8) & 0xFF) + "." + (ip & 0xFF);
    console.info("YZJ "+this.local_ip)
  }
  public static solveRes(data: number) {
    let eventData = {
      data: {
        "content": "正常",
        "id": 1,
        "isEmpty": false,
        "isTired":false,
        "curTime":"00:00:00"
      },
      isTired:false
    };
    switch (data) {
      case Constant.state0:
        eventData.data.content = "正常"
        this.flag = 0
        break;
      case Constant.state1:
        eventData.data.content = "打电话"
        this.flag ++;
        break;
      case Constant.state2:
        eventData.data.content = "哈欠"
        this.flag ++;
        break;
      case Constant.state3:
        eventData.data.content = "左顾右盼"
        this.flag ++;
        break;
      case Constant.state4:
        eventData.data.content = "闭眼"
        this.flag ++;
        break;
      default:
        eventData.data.content = "正常"
        this.flag=0;
        break;

    }
    if(this.flag >=3){
      this.flag = 0
      eventData.data.isTired = true;
    }

    return eventData;

  }


}