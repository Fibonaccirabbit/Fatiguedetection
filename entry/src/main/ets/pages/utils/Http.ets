import common from '@ohos.app.ability.common';
import fs from '@ohos.file.fs';
import request from '@ohos.request';
import http from '@ohos.net.http';
import token from './Token';
import FileUtils from './FileUtils';
import axios, { FormData } from '@ohos/axios'
import emitter from '@ohos.events.emitter';
import Constant from './Constant';
import { DEFAULT } from '@ohos/hypium';

// 定义一个eventId为1的事件，事件优先级为High 用来通知UI更新结果
let event = {
  eventId: 1,
  priority: emitter.EventPriority.HIGH
};

let event2 = {
  eventId: 2,
  priority: emitter.EventPriority.HIGH
};


export default class QHttp {

  // buffer : Array<number> = [0,0,0,0];
  public static flag = 0;
  // 获取服务器Token 未启用
  public static getToken() {
    // 每一个httpRequest对应一个HTTP请求任务，不可复用
    let httpRequest = http.createHttp();
    // 用于订阅HTTP响应头，此接口会比request请求先返回。可以根据业务需要订阅此消息
    // 从API 8开始，使用on('headersReceive', Callback)替代on('headerReceive', AsyncCallback)。 8+
    httpRequest.on('headersReceive', (header) => {
      console.info('header: ' + JSON.stringify(header));
    });
    // let url = "https://modelarts.cn-north-4.myhuaweicloud.com/v1/f2035025b1ae4bc585120e15733032c3/services"
    let url = "https://iam.myhuaweicloud.com/v3/auth/tokens?nocatalog=true"
    httpRequest.request(url,
      // 填写HTTP请求的URL地址，可以带参数也可以不带参数。URL地址需要开发者自定义。请求的参数可以在extraData中指定"EXAMPLE_URL",
      {
        method: http.RequestMethod.POST, // 可选，默认为http.RequestMethod.GET
        // 开发者根据自身业务需要添加header字段
        header: {
          'Content-Type': 'application/json'
        },
        // 当使用POST请求时此字段用于传递内容
        extraData: {
          "auth": {
            "identity": {
              "methods": [
                "password"
              ],
              "password": {
                "user": {
                  "name": "fa",
                  "password": "Ry505604",
                  "domain": {
                    "name": "siloha"
                  }
                }
              }
            },
            "scope": {
              "project": {
                "name": "cn-north-4" //IAM用户所属帐号名
              }
            }
          }
        },
        expectDataType: http.HttpDataType.STRING, // 可选，指定返回数据的类型
        usingCache: true, // 可选，默认为true
        priority: 1, // 可选，默认为1
        connectTimeout: 60000, // 可选，默认为60000ms
        readTimeout: 60000, // 可选，默认为60000ms
        usingProtocol: http.HttpProtocol.HTTP1_1, // 可选，协议类型默认值由系统自动指定
      },
      (err, data) => {
        if (!err) {
          // data.result为HTTP响应内容，可根据业务需要进行解析
          console.info('YZJ Result:' + JSON.stringify(data.result));
          console.info('YZJ code:' + JSON.stringify(data.responseCode));
          // data.header为HTTP响应头，可根据业务需要进行解析
          console.info('YZJ header:' + JSON.stringify(data.header));
          console.info('YZJ cookies:' + JSON.stringify(data.cookies)); // 8+
          // 当该请求使用完毕时，调用destroy方法主动销毁
          httpRequest.destroy();
        } else {
          console.info('YZJ error:' + JSON.stringify(err));
          // 取消订阅HTTP响应头事件
          httpRequest.off('headersReceive');
          // 当该请求使用完毕时，调用destroy方法主动销毁
          httpRequest.destroy();
        }
      }
    )

  }
  // 上传视频到云服务器未启用
  public static toModelArt() {
    // 获取应用文件路径
    let context = getContext(this) as common.UIAbilityContext;
    let cacheDir = context.cacheDir;

    // 新建一个本地应用文件
    let file = fs.openSync(cacheDir + '/test.txt', fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    fs.writeSync(file.fd, 'upload file test');
    fs.closeSync(file);

    // 上传任务配置项
    let uploadConfig = {
      url: 'https://f773cda9c120461981a587734e3272a6.apig.cn-north-4.huaweicloudapis.com/v1/infers/c19e9a34-e05f-451b-ae81-0ee00158d6c1',
      header: {
        'X-Auth-Token': token
      },
      method: 'POST',
      files: [
        {
          filename: 'video1.mp4', name: 'images', uri: 'internal://cache/video1.mp4', type: 'mp4'
        }
      ],
      data: [
      // { name: 'name', value: 'value' }
      ]
    }

    // 将本地应用文件上传至网络服务器
    try {
      console.info("YZJ 发送！")
      request.uploadFile(context, uploadConfig)
        .then((uploadTask) => {
          let headerCallback = (headers) => {
            console.info("YZJ upOnHeader headers:" + JSON.stringify(headers));
            try {
              let res = JSON.parse(headers["body"])
              console.info("YZJ " + JSON.stringify(res.result.drowsy[0].category))
              let eventData = this.solveRes(res.result.drowsy[0].category)
              emitter.emit(event, eventData);
            } catch (err) {
              console.error("YZJ 解析错误")
            }
          };
          uploadTask.on('headerReceive', headerCallback);


          uploadTask.on('complete', (taskStates) => {
            for (let i = 0; i < taskStates.length; i++) {
              console.info(`YZJ upload complete taskState: ${JSON.stringify(taskStates[i])}`);
            }
          });
        })
        .catch((err) => {
          console.error(`YZJ Invoke uploadFile failed, code is ${err.code}, message is ${err.message}`);
        })
    } catch (err) {
      console.error(`YZJ Invoke uploadFile failed, code is ${err.code}, message is ${err.message}`);
    }
  }
  // 启用中，图片上传云服务器推理并返回结果
  // 文件上传请参考 https://docs.openharmony.cn/pages/v4.0/zh-cn/application-dev/file-management/app-file-upload-download.md/
  public static toModelArtSingle(fileName: string) {
    // 获取应用文件路径
    let context = getContext(this) as common.UIAbilityContext;
    let cacheDir = context.cacheDir;

    // 新建一个本地应用文件
    let fn = fileName+".jpg"
    // 上传任务配置项
    let uploadConfig = {
      url: 'https://0981a1e9c2734771ad217de2914832ec.apig.cn-north-4.huaweicloudapis.com/v1/infers/74ddae38-22e0-433f-b3ba-946ad5a78232',
      // url:"http://192.168.43.127:12600/upload",
      header: {
        'X-Auth-Token': token
      },
      method: 'POST',
      files: [
        {
          filename: fn, name: 'images', uri: 'internal://cache/' + fileName, type: 'jpg'
        }
      ],
      data: [
      // { name: 'name', value: 'value' }
      ]
    }
    // 将本地应用文件上传至网络服务器
    try {
      console.info("YZJ 发送！")
      request.uploadFile(context, uploadConfig)
        .then((uploadTask) => {
          // header
          let headerCallback = (headers) => {
            console.info("YZJ upOnHeader headers:" + JSON.stringify(headers));
            try {
              // 读取返回结果
              let res = JSON.parse(headers["body"])
              console.info("YZJ " + JSON.stringify(res.result.category))
              // 处理返回结果
              let eventData = this.solveRes(res.result.category)
              // 携带结果通知所有订阅了 eventId 为1事件的对象。这里主要是通知UI更新结果
              emitter.emit(event2, eventData);
            } catch (err) {
              console.info("YZJ 解析错误！")
            }
          };
          // 订阅返回结果
          uploadTask.on('headerReceive', headerCallback);
          // 订阅上传是否成功事件
          uploadTask.on('complete', (taskStates) => {
            for (let i = 0; i < taskStates.length; i++) {
              //上传完成
              console.info(`YZJ upload complete taskState: ${JSON.stringify(taskStates[i])}`);
            }
          });
        })
        .catch((err) => {
          console.error(`YZJ Invoke uploadFile failed, code is ${err.code}, message is ${err.message}`);
        })
    } catch (err) {
      console.error(`YZJ Invoke uploadFile failed, code is ${err.code}, message is ${err.message}`);
    }
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
        eventData.data.content = "闭眼"
        this.flag ++;
        break;
      case Constant.state2:
        eventData.data.content = "哈欠"
        this.flag ++;
        break;
      case Constant.state3:
        eventData.data.content = "打电话"
        this.flag ++;
        break;
      case Constant.state4:
        eventData.data.content = "左顾右盼"
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