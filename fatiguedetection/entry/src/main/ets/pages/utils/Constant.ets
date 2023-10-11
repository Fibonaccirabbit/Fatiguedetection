import { DEFAULT } from '@ohos/hypium'

export default class Constant {

  // Tab-bar ui
  public static tabBarHomeUI = ["/common/pics/ic_public_home_filled_pressed.svg",
    "/common/pics//ic_public_home_filled.svg"
  ]
  public static tabBarUpgradeUI = ["/common/pics/ic_public_upgrade_filled_pressed.svg",
    "/common/pics/ic_public_upgrade_filled.svg"
  ]
  public static tabBarSettingUI = ["/common/pics/ic_public_settings_filled_pressed.svg",
    "/common/pics/ic_public_settings_filled.svg"
  ]
  public static tabBarTestUI = ["/common/pics/ic_gallery_ai_photography_on_pressed.svg",
    "/common/pics/ic_gallery_ai_photography_on.svg"
  ]

  public static state0 = 0;
  public static state1 = 1;
  public static state2 = 2;
  public static state3 = 3;
  public static state4 = 4;

  public static onModelArtMp4 = {
    eventId: 1
  };

  public static onModelArtReal = {
    eventId: 2
  };

  public static onLogRecord = {
    eventId: 4
  }

  public static stopAudio = {
    eventId: 5
  }
  public static audioEffect = "01.wav"

}