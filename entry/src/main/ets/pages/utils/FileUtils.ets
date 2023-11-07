import common from '@ohos.app.ability.common';
import fs from '@ohos.file.fs';
import image from '@ohos.multimedia.image';
import fileio from '@ohos.fileio';
import QHttp from './Http';
import systemDateTime from '@ohos.systemDateTime';

export default class FileUtils {
  public static async printFileList() {
    console.info("YZJ 调用文件函数")

    // 获取应用文件路径
    let context = getContext(this) as common.UIAbilityContext;
    let cacheDir = context.cacheDir;
    let options = {
      "recursion": true,
      "listNum": 0,
      "filter": {
        "suffix": [".png", ".jpg", ".jpeg", ".mp4"],
        "displayName": ["%abc", "efg%"],
        "fileSizeOver": 1024,
        "lastModifiedAfter": new Date().getTime(),
      }
    };

    let filePath = cacheDir + "/video1.mp4";
    let res = await fs.access(filePath)
    if (!res) {
      console.info("YZJ 文件不存在，正在复制文件")
      await this.copy_rawfile__to_sandbox()
    }
    console.info("YZJ", cacheDir)
    fs.listFile(cacheDir).then((filenames) => {
      console.info("YZJ listFile succeed");
      for (let i = 0; i < filenames.length; i++) {
        console.info("YZJ fileName: %s", filenames[i]);
      }
    }).catch((err) => {
      console.info("YZJ list file failed with error message: " + err.message + ", error code: " + err.code);
    });
  }

  public static getRes() {
    // 获取应用文件路径
    let context = getContext(this) as common.UIAbilityContext;
    try {
      context.resourceManager.getRawFd("video1.mp4", (error, value) => {
        if (error != null) {
          console.log(`callback getRawFd failed error code: ${error.code}, message: ${error.message}.`);
        } else {
          let fd = value.fd;
          let offset = value.offset;
          let length = value.length;
          console.info("YZJ" + fd)
        }
      });
    } catch (error) {
      console.error(`callback getRawFd failed, error code: ${error.code}, message: ${error.message}.`)
    }
    ;

  }
  // 将摄像头拍摄的图片数据 保存在沙箱中，沙箱地址/data/app/el2/100/base/com.fsr.fatiguedetection/haps/entry/cache
  // 图片保存成功后，上传到云服务器进行推理并返回结果
  // IO操作相关接口参考
  public static async savePictureSand(buffer: ArrayBuffer,img:image.Image) {
    console.info("YZJ ")
    let context = getContext(this) as common.UIAbilityContext;
    let cacheDir = context.cacheDir;
    let fileName = await this.getFileName();
    let filePath = cacheDir + "/" + fileName;
    let ss = fs.createStreamSync(filePath, "w+");
    console.info("YZJ 准备开始保存")
    ss.write(buffer, (err, bytesWritten) => {
      if (err) {
        console.info("YZJ write stream failed with error message: " + err.message + ", error code: " + err.code);
      } else {
        if (bytesWritten) {
          console.info("YZJ write succeed and size is:" + bytesWritten);

          QHttp.toModelArtSingle(fileName);
        }
      }
    });


    await img.release()
  }

  public static async getFileName() {
    let time;
    try {
      time = await systemDateTime.getCurrentTime()

    } catch (e) {
      console.info(`YZJ  Failed to get currentTime. message:${e.message}, code:${e.code}`);
    }
    if(time ==null){
      time = "Images"
    }
    return time+".jpg"

  }

  //用来拷贝rawfile文件中的input.txt到应用沙箱目录下
  // 未启用
  public static async copy_rawfile__to_sandbox() {
    let context = getContext(this) as common.UIAbilityContext;
    let cacheDir = context.cacheDir;
    try {
      let file = cacheDir + "/video1.mp4";
      let sss = fs.createStreamSync(file, "w"); //没有会创建一个空的input.txt
      sss.closeSync();
      context.resourceManager.getRawFd("video1.mp4").then(value => {
        let fd = value.fd;
        console.info("YZJ", fd)
        let offset = value.offset;
        let length = value.length;
        fs.copyFileSync(fd, file);
      }).catch(error => {
        console.log(`YZJ promise getRawFd error error code: ${error.code}, message: ${error.message}.`);
      });
    } catch (error) {
      console.error(`YZJ promise getRawFd failed, error code: ${error.code}, message: ${error.message}.`);
    }
    ;


  }
}