// @ts-ignore
import mindSporeLite from '@ohos.ai.mindSporeLite';
import emitter from '@ohos.events.emitter';
import image from '@ohos.multimedia.image';
import Constant from '../utils/Constant';
import QHttp from '../utils/Http';

let event2 = {
  eventId: 2,
  priority: emitter.EventPriority.HIGH
};

export default class FatigueDetect {
  private static inputBuffer: Uint8Array;
  private static modelFile = '/data/storage/el2/base/haps/entry/files/int8.ms';
  private static msLiteModel;
  private static modelInputs;
  private static buffer;

  static async loadModel() {
    // 1.创建上下文
    let context: mindSporeLite.Context = {};
    context.target = ['cpu'];
    context.cpu = {}
    context.cpu.threadNum = 2;
    context.cpu.threadAffinityMode = 0;
    context.cpu.precisionMode = 'enforce_fp32';

    // 2.加载模型
    // this.modelFile = '/data/storage/el2/base/haps/entry/files/yolov5.ms';
    this.msLiteModel = await mindSporeLite.loadModelFromFile(this.modelFile, context);
    // let msLiteModel;


    mindSporeLite.loadModelFromFile(this.modelFile).then((result) => {
      this.msLiteModel = result;
      const modelInputs = result.getInputs();
      console.log("YZJ" + modelInputs[0].name);
      console.log("YZJ" + modelInputs[0].shape.toString());
      console.log("YZJ" + modelInputs[0].elementNum.toString());
      console.log("YZJ" + modelInputs[0].dtype.toString());
      console.log("YZJ" + modelInputs[0].format.toString());
      console.log("YZJ" + modelInputs[0].dataSize.toString());
    })
    this.modelInputs = this.msLiteModel.getInputs();
    this.buffer = new Float32Array(150528)
  }

  static async predict(arr:ArrayBuffer, img: image.Image) {
    await img.release()
    // 3.设置输入数据
    if (this.msLiteModel == undefined)
      return;

    console.info("YZJ 设置数据缓冲区完毕"+arr.byteLength)

    // var float32Array = new Float32Array(150528)
    this.buffer.set(new Float32Array(new Uint8Array(arr)))
    console.info("YZJ 结束缓存")
    this.modelInputs[0].setData( this.buffer.buffer);

    // arr.release()
    // arr.release()
    console.info("YZJ 设置数据缓冲区完毕")

    // 4.执行推理并打印输出
    console.log('YZJ=========MSLITE predict start=====')
    this.msLiteModel.predict(this.modelInputs).then((modelOutputs) => {
      let output0 = new Float32Array(modelOutputs[0].getData());
      console.log("YZJ" + JSON.stringify(output0));
      // for (let i = 0; i < output0.length; i++) {
      //   console.log("YZJ" + output0[i].toString());
      //   // this.softmax(output0)
      //   let eventData = QHttp.solveRes(parseInt(output0[i].toString()))
      //   emitter.emit(event2, eventData);
      // }

      this.softmax(output0)
    }

    )

    console.log('YZJ=========MSLITE predict success=====')
  }

  static release() {
    this.msLiteModel = null;
  }

  static uint8Array2Float32Array(uint8Array) {
    var i
    var l = uint8Array.length
    var outputData = new Float32Array(uint8Array.length)
    for (i = 0; i < l; i++) {
      outputData[i] = (uint8Array[i] - 128) / 128.0
    }
    return outputData
  }

  static toFloat32Array(arr) {
    var outputData = new Float32Array(arr.length)
    var i
    var l = arr.length
    for (i = 0; i < l; i++) {
      outputData[i] = (arr[i] - 128) / 128.0
    }
    return outputData
  }

  static softmax(arr) {
    const expArr = arr.map(x => Math.exp(x));
    const sumExp = expArr.reduce((acc, cur) => acc + cur)

    console.info("YZJ" + typeof expArr.map(x => x / sumExp))
    let obj = expArr.map(x => x / sumExp)
    let maxKey = null;
    let maxValue = -Infinity;
    for (const key in obj) {
      if (obj.hasOwnProperty(key)) {
        if (obj[key] > maxValue) {
          maxKey = key;
          maxValue = obj[key];
        }
      }
    }
    console.info("YZJ predict:" + maxKey)
    this.solveRes(parseInt(maxKey))
  }

  public static solveRes(data: number) {
    let eventData = {
      data: {
        "content": "正常",
        "id": 1,
        "isEmpty": false,
      }
    };
    switch (data) {
      case 0:
        eventData.data.content = "正常"
        break;
      case 4:
        eventData.data.content = "闭眼"
        break;
      case 2:
        eventData.data.content = "哈欠"
        break;
      case 1:
        eventData.data.content = "打电话"
        break;
      case 3:
        eventData.data.content = "左顾右盼"
        break;
      default:
        eventData.data.content = "正常"
        break;

    }

    // return eventData;
    emitter.emit(event2, eventData);
  }
}