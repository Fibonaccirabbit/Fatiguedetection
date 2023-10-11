import socket from '@ohos.net.socket';
import wifi from '@ohos.wifi';
import emitter from '@ohos.events.emitter';
import QHttp from './Http';
import Constant from './Constant';

let event2 = {
  eventId: 2,
  priority: emitter.EventPriority.HIGH
};
export default class AIServer {
  public static tcp;
  public static local_ip;
  public static remote_ip = "192.168.43.127"
  public static isConnected = false;
  public static numOfTimer = 0;
  public static flag = 0;
  public static connectServer() {
    // 创建一个TCPSocket连接，返回一个TCPSocket对象。
    this.tcp = socket.constructTCPSocketInstance();
    this.getIpAddress()
    // 订阅TCPSocket相关的订阅事件
    this.tcp.on('message', value => {
      console.log("YZJ on message")
      let buffer = value.message
      let dataView = new DataView(buffer)
      let str = ""
      for (let i = 0; i < dataView.byteLength; ++i) {
        str += String.fromCharCode(dataView.getUint8(i))
      }
      let res = this.solveRes(parseInt(str))
      emitter.emit(event2, res);
      console.log("YZJ on connect received:" + str)
    });
    this.tcp.on('connect', () => {
      console.log("YZJ on connect")
    });
    this.tcp.on('close', () => {
      console.log("YZJ on close")
    });

    // 绑定IP地址和端口。
    let bindAddress = {
      address: this.local_ip,
      port: 126001, // 绑定端口，如1234
      family: 1
    };
    this.tcp.bind(bindAddress, err => {
      if (err) {
        console.log('YZJ bind fail');
        return;
      }
      console.log('YZJ bind success');
      // 连接到指定的IP地址和端口。
      let connectAddress = {
        address: this.remote_ip,
        port: 12600, // 连接端口，如5678
        family: 1
      };
      this.tcp.connect({
        address: connectAddress, timeout: 6000
      }, err => {
        if (err) {
          console.log('YZJ connect fail');
          return;
        }
        this.isConnected = true;
        this.startPre();
        console.log('YZJ connect success');

      });
    });
  }

  public static startPre() {
    // 发送数据
    this.tcp.send({
      data: '1'
    }, err => {
      if (err) {
        console.log('YZJ send fail');
        return;
      }
     this.numOfTimer =  setInterval(()=>{
        this.getData();
      },66)
      console.log('send success');
    })
  }

  public static getData(){
    this.tcp.send({
      data: '3'
    }, err => {
      if (err) {
        this.isConnected  = false;
        console.log('YZJ send fail');
        return;
      }

      console.log('send success');
    })
  }
  public static sendSingle(bytes:Uint8Array){
    this.connectServer()
    this.tcp.send({
      data: bytes.buffer
    }, err => {
      if (err) {
        this.isConnected  = false;
        console.log('YZJ send fail');
        return;
      }

      console.log('YZJ send success');
      this.tcp = null;
    })

  }

  public static stopPre() {
    // 发送数据
    clearInterval(this.numOfTimer)
  }
  //获取本机ip地址
  public static getIpAddress() {
    let ip = wifi.getIpInfo().ipAddress;
    this.local_ip= (ip >> 24 & 0xFF) + "." + ((ip >> 16) & 0xFF) + "." + ((ip >> 8) & 0xFF) + "." + (ip & 0xFF);
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