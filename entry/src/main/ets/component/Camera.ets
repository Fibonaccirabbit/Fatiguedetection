import camera from '@ohos.multimedia.camera'
import image from '@ohos.multimedia.image'
import media from '@ohos.multimedia.media'
import taskpool from '@ohos.taskpool'
import AIServer from '../pages/utils/AIserver'
import FileUtils from '../pages/utils/FileUtils'
import QHttp from '../pages/utils/Http'
import worker from '@ohos.worker';
import emitter from '@ohos.events.emitter'
import FatigueDetect from '../pages/ai/FatigueDetect'
import AVPlayerDemo from '../pages/utils/AudioManager'
import Prompt from '@system.prompt'
import GestureServer from '../pages/utils/GestureServer'

let wk = new worker.ThreadWorker("entry/ets/workers/worker.ts");


@Extend(Button) function fancy(con: Boolean = true) {
  .fontColor(con ? "#E84026" : "#0A59F7")
  .backgroundColor("#F1F3F5")
  .width(120)
  .height(40)
  .border({ width: 2, color: "#254FF7" })
}

@Entry
@Component
struct cameraComponent {
  private surfaceId: string = ''
  private xcomponentController: XComponentController = new XComponentController()
  private photoOutput = null;
  @State startIsPressed: boolean = false;
  private imageReceiver;
  @State isCloudPreStart: boolean = false;
  @State isLocalPreStart: boolean = false;
  @State isK210PreStart: boolean = false;
  @State isGesturePreStart: boolean = false;
  private cloudPreTimerNum: number;
  private isCameraStarted: boolean = false;
  private buffer: ArrayBuffer;
  private workCount = 0;
  private localMode = false;

  // 接口参考 https://docs.openharmony.cn/pages/v4.0/zh-cn/application-dev/ui/arkts-common-components-xcomponent.md/
  build() {
    Column() {
      // xComponent函数 摄像头数据渲染载体
      XComponent({
        id: 'xcomponent',
        type: 'surface',
        controller: this.xcomponentController
      })
        .onLoad(() => {
          this.xcomponentController.setXComponentSurfaceSize({ surfaceWidth: 1920, surfaceHeight: 1080 });
          this.surfaceId = this.xcomponentController.getXComponentSurfaceId()
          // 初始化摄像头
          this.prepared();
        })
        .width('100%')
        .height('70%')

      Row({ space: 20 }) {
        Button("云端检测")
          .fancy(this.isCloudPreStart)
          .margin({ top: 15 })
          .onClick(() => {
            if (this.isCloudPreStart == false) {
              Prompt.showToast({ message: "正在进行云端检测" })
              this.isCloudPreStart = true;
              // 启用云检测时开启
              // this.startRealTimePre();

            }
            else {
              Prompt.showToast({ message: "结束云端检测" })
              this.isCloudPreStart = false;
              // 启用云检测时开启
              // clearInterval(this.cloudPreTimerNum)
            }
          })
        Button("边缘检测")
          .fancy(this.isK210PreStart)
          .margin({ top: 15 })
          .onClick(() => {
            if (this.isK210PreStart == false) {
              // 开启边缘设备检测
              Prompt.showToast({ message: "正在进行边缘检测" })
              this.isK210PreStart = true;
              if (AIServer.tcp == undefined || AIServer.isConnected == false) {
                AIServer.connectServer();
              }
            }
            else {
              // 关闭边缘设备检测
              Prompt.showToast({ message: "结束边缘检测" })
              this.isK210PreStart = false;
              if (AIServer.tcp != undefined) {
                AIServer.stopPre();
                AIServer.tcp.close()
                AIServer.tcp = null;
              }
            }
          })

        Button("端检测")
          .fancy(this.isLocalPreStart)
          .margin({ top: 15 })
          .onClick(() => {
            if (this.isLocalPreStart == false) {
              Prompt.showToast({ message: "正在进行端检测" })
              this.isLocalPreStart = true
              // 开始端检测
              this.startRealTimePre();
              // 加载本地模型
              FatigueDetect.loadModel();
            }
            else {
              // 关闭端检测
              clearInterval(this.cloudPreTimerNum)
              Prompt.showToast({ message: "结束端检测" })
              this.isLocalPreStart = false
              // this.takePic();
            }
          })
      }
    }
  }
  // 开始实时检测 原理是通过一个计时器 不断拍摄图片，保存本地进行端检测或者上传图片到云端检测
  startRealTimePre() {
    this.cloudPreTimerNum = setInterval(() => {
      this.takePic();
    }, 60000)
  }
  // 拍照函数
  async takePic() {
    let settings = {
      quality: camera.QualityLevel.QUALITY_LEVEL_LOW, // 设置图片质量高
      rotation: camera.ImageRotation.ROTATION_0 // 设置图片旋转角度0
    }
    // 使用当前拍照设置进行拍照
    this.photoOutput.capture(settings, async (err) => {
      if (err) {
        console.error('YZJ Failed to capture the photo ${err.message}');
        return;
      }

      console.info('YZJ Callback invoked to indicate the photo capture request success.');
    });
  }
  // 摄像头预览流准备，在xComponent组件初始化成功时候调用
  // 接口参考 https://docs.openharmony.cn/pages/v4.0/zh-cn/application-dev/media/camera-shooting-case.md/
  async prepared() {
    console.info("YZJ 启动相机")
    // 创建CameraManager对象
    let context: any = getContext(this)
    let cameraManager = camera.getCameraManager(context)
    if (!cameraManager) {
      console.error("YZJ camera.getCameraManager error")
      return;
    }
    // 监听相机状态变化


    // 获取相机列表
    let cameraArray = cameraManager.getSupportedCameras();
    if (cameraArray.length <= 0) {
      console.error("YZJ cameraManager.getSupportedCameras error")
      return;
    }

    for (let index = 0; index < cameraArray.length; index++) {
      console.info('YZJ cameraId : ' + cameraArray[index].cameraId); // 获取相机ID
      console.info('YZJ cameraPosition : ' + cameraArray[index].cameraPosition); // 获取相机位置
      console.info('YZJ cameraType : ' + cameraArray[index].cameraType); // 获取相机类型
      console.info('YZJ connectionType : ' + cameraArray[index].connectionType); // 获取相机连接类型
    }

    // 创建相机输入流
    let cameraInput
    try {
      cameraInput = cameraManager.createCameraInput(cameraArray[1]);
    } catch (error) {
      console.error('YZJ Failed to createCameraInput errorCode = ' + error.code);
    }

    // 监听cameraInput错误信息
    let cameraDevice = cameraArray[1];
    cameraInput.on('error', cameraDevice, (error) => {
      console.info(`YZJ Camera input error code: ${error.code}`);
    })

    // 打开相机
    await cameraInput.open();

    // 获取相机设备支持的输出流能力
    let cameraOutputCap = cameraManager.getSupportedOutputCapability(cameraArray[1]);
    if (!cameraOutputCap) {
      console.error("YZJ YZJ cameraManager.getSupportedOutputCapability error")
      return;
    }
    console.info("YZJ outputCapability: " + JSON.stringify(cameraOutputCap));

    let previewProfilesArray = cameraOutputCap.previewProfiles;
    if (!previewProfilesArray) {
      console.error("YZJ createOutput previewProfilesArray == null || undefined")
    }

    let photoProfilesArray = cameraOutputCap.photoProfiles;
    if (!photoProfilesArray) {
      console.error("YZJ createOutput photoProfilesArray == null || undefined")
    }


    // 创建预览输出流,其中参数 surfaceId 参考上文 XComponent 组件，预览流为XComponent组件提供的surface
    let previewOutput
    try {
      previewOutput = cameraManager.createPreviewOutput(previewProfilesArray[0], this.surfaceId)
    } catch (error) {
      console.error("YZJ Failed to create the PreviewOutput instance.")
    }

    // 监听预览输出错误信息
    previewOutput.on('error', (error) => {
      console.info(`YZJ Preview output error code: ${error.code}`);
    })

    // 创建ImageReceiver对象，并设置照片参数：分辨率大小是根据前面 photoProfilesArray 获取的当前设备所支持的拍照分辨率大小去设置
    // this.imageReceiver =  image.createImageReceiver(1920, 1080, 4, 8)
    // this.imageReceiver.on('imageArrival', () => {
    //   console.info("YZJ 拍照！")
    //
    // })
    await this.photoReceiver()
    // 获取照片显示SurfaceId
    let photoSurfaceId = await this.imageReceiver.getReceivingSurfaceId()
    // // 创建拍照输出流
    try {
      this.photoOutput = cameraManager.createPhotoOutput(photoProfilesArray[0], photoSurfaceId)
    } catch (error) {
      console.error('YZJ Failed to createPhotoOutput errorCode = ' + error.code);
    }

    let previewOutputForFrame
    // //创建二路输出流
    // try {
    //   previewOutputForFrame = cameraManager.createPreviewOutput(previewProfilesArray[0], photoSurfaceId)
    // } catch (error) {
    //   console.error("YZJ Failed to create the PreviewOutput instance.")
    // }

    //创建会话
    let captureSession
    try {
      captureSession = cameraManager.createCaptureSession()
    } catch (error) {
      console.error('YZJ Failed to create the CaptureSession instance. errorCode = ' + error.code);
    }

    // 监听session错误信息
    captureSession.on('error', (error) => {
      console.info(`YZJ Capture session error code: ${error.code}`);
    })

    // 开始配置会话
    try {
      captureSession.beginConfig()
    } catch (error) {
      console.error('YZJ Failed to beginConfig. errorCode = ' + error.code);
    }

    // 向会话中添加相机输入流
    try {
      captureSession.addInput(cameraInput)
    } catch (error) {
      console.error('YZJ Failed to addInput. errorCode = ' + error.code);
    }

    // 向会话中添加预览输出流
    try {
      captureSession.addOutput(previewOutput)
    } catch (error) {
      console.error('YZJ Failed to addOutput(previewOutput). errorCode = ' + error.code);
    }

    // 向会话中添加拍照输出流
    try {
      captureSession.addOutput(this.photoOutput)
    } catch (error) {
      console.error('YZJ Failed to addOutput(photoOutput). errorCode = ' + error.code);
    }

    // 向会话中添加二路输出流
    // try {
    //   captureSession.addOutput(previewOutputForFrame)
    // } catch (error) {
    //   console.error('YZJ Failed to addOutput(photoOutput). errorCode = ' + error.code);
    // }
    // 提交会话配置
    await captureSession.commitConfig()

    // 启动会话
    await captureSession.start().then(() => {
      this.isCameraStarted = true;

      console.info('YZJ Promise returned to indicate the session start success.');
    })


  }
  // 创建图片接收器并进行订阅
  // 接口参考 https://docs.openharmony.cn/pages/v4.0/zh-cn/application-dev/reference/apis/js-apis-image.md/
  async photoReceiver() {
    this.imageReceiver = image.createImageReceiver(224, 224, 4, 8)
    this.buffer = new ArrayBuffer(4096)

    this.imageReceiver.on('imageArrival', () => {
      // console.log("YZJ -service-imageArrival" + this.workCount)
      let event = {
        eventId: 3,
        priority: emitter.EventPriority.LOW
      };
      let eventData = {
        data: {
          "content": "c",
          "id": 1,
          "isEmpty": false,
        }
      };
      // 发送eventId为1的事件，事件内容为eventData
      emitter.emit(event, eventData);
      return null
    })
  }
  // 线程间通信参考 https://docs.openharmony.cn/pages/v4.0/zh-cn/application-dev/application-models/itc-with-emitter.md/
  onResListen() {
    // 定义一个eventId为3的事件
    let event = {
      eventId: 3
    };
    // 收到eventId为3的事件后执行该回调
    //  收到eventId为3的事件时，从图片缓冲区photoReceiver中取出一张图片，并且进行端检测/云检测
    let callback = (eventData) => {
      // console.info('YZJ event callback');
      // 从缓冲区中读取下一张图片，缓冲区最多存3张图片，必须手动读取并释放，才能接收新的图片数据
      this.imageReceiver.readNextImage((err, image) => {
        if (err || image === undefined) {
          console.info("YZJ" + err)
          return
        }
        let buffer = new ArrayBuffer(4096)
        // 读取图片数据
        image.getComponent(4, (errMsg, img) => {
          if (errMsg || img === undefined) {
            console.info("YZJ" + errMsg)
            return
          }
          if (img.byteBuffer) {
            console.info("YZJ 拍照成功")
            // 保留图片数据
            buffer = img.byteBuffer
            // 释放图片，此时缓冲区空余位置+1
            image.release()
            // 进行端检测
            FatigueDetect.predict(buffer, image)
            // 进行云检测时启用
            // FileUtils.savePictureSand(buffer, image)
          }


        })
      })

    };
    // 订阅eventId为3的事件
    emitter.on(event, callback);
  }

  onPageHide() {
    console.info("YZJ ++")
    emitter.off(3)
  }

  aboutToAppear() {
    console.info("YZJ ++")
    this.onResListen()
  }

  aboutToDisappear() {
    console.info("YZJ ++")
    emitter.off(3)

  }

  onBackPress() {
    console.info("YZJ ++")
    emitter.off(3)
  }
}

export default cameraComponent