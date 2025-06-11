import 'package:apk_analyzer/utils/files.dart';

String _getToolPath() {
  return checkFileExists('pubspec.yaml') ? 'win_tools' : 'data/flutter_assets/win_tools';
}

String _getAapt2Path() {
  String toolPath = _getToolPath();
  return '$toolPath\\aapt2.exe';
}

String _getAaptPath() {
  String toolPath = _getToolPath();
  return '$toolPath\\aapt.exe';
}

String _getEasyFridaPath() {
  String toolPath = _getToolPath();
  return '$toolPath\\easyFrida';
}

String _getEasyFridaExePath() {
  String fridaPath = _getEasyFridaPath();
  return '$fridaPath\\easyFrida.exe';
}

String _getEasyFridaPluginPath() {
  String fridaPath = _getEasyFridaPath();
  return '$fridaPath\\scripts\\plugins.list';
}

String _getAdbPath() {
  String toolPath = _getToolPath();
  return '$toolPath\\adb.exe';
}

String _getFridaServerPath() {
  String toolPath = _getToolPath();
  return '$toolPath\\frida-server-16.1.4-android-';
}

const extractBadgingCommand = 'dump badging';
const extractManifestCommand = 'dump xmltree --file AndroidManifest.xml';
const extractResourcesCommand = 'dump resources';

final aaptPath = _getAaptPath();
final aapt2Path = _getAapt2Path();
final easyFridaExePath = _getEasyFridaExePath();
final easyFridaPluginPath = _getEasyFridaPluginPath();
const easyFridaClassCommand = '--className';
const easyFridaIsMethodCommand = '-m';
const easyFridaSpawnCommand = '-f';
const easyFridaAttachCommand = '-p';
const easyFridaPluginCommand = '-l';
const easyFridaLogCommand = '-o';

final toolPath = _getToolPath();

final adbPath = _getAdbPath();
const adbRootCommand = 'shell su -c';
const adbCheckInstalledCommand = 'pm list package';
const adbInstallCommand = 'install';
const adbUnameCommand = 'uname -a';
const adbFridaServer = '/data/local/tmp/fs_wxjzc';
const adbUploadCommand = 'push';
const adbCheckFSCommand = 'test -f /data/local/tmp/fs_wxjzc && echo 1 || echo 0';

final fsPath = _getFridaServerPath();


const logDirPath = './logs';
const logFilePath = '$logDirPath/app.log';

const tempDirPath = './temp';

const dangerPermissions = [
  'android.permission.READ_PHONE_STATE',
  'android.permission.WRITE_EXTERNAL_STORAGE',
  'android.permission.READ_EXTERNAL_STORAGE',
  'android.permission.CAMERA',
  'android.permission.RECORD_AUDIO',
  'android.permission.SEND_SMS',
  'android.permission.RECEIVE_SMS',
  'android.permission.READ_SMS',
  'android.permission.WRITE_SETTINGS',
  'android.permission.READ_CONTACTS',
  'android.permission.WRITE_CONTACTS',
  'android.permission.GET_ACCOUNTS',
  'android.permission.MANAGE_ACCOUNTS',
];

const sensitivePermissions = [
  'android.permission.USE_CREDENTIALS',
  'android.permission.ACCESS_FINE_LOCATION',
  'android.permission.ACCESS_COARSE_LOCATION',
  'android.permission.READ_CALENDAR',
  'android.permission.WRITE_CALENDAR',
];

const Map<String, Map<String, String>> permissionDescriptions = {
  "android.permission.ACCESS_CHECKIN_PROPERTIES": {
    "name": "访问登记属性",
    "description": "读取或写入登记check-in数据库属性表的权限",
  },
  "android.permission.ACCESS_COARSE_LOCATION": {
    "name": "获取错略位置",
    "description": "通过WiFi或移动基站的方式获取用户错略的经纬度信息,定位精度大概误差在30~1500米",
  },
  "android.permission.ACCESS_FINE_LOCATION": {
    "name": "获取精确位置",
    "description": "通过GPS芯片接收卫星的定位信息,定位精度达10米以内",
  },
  "android.permission.ACCESS_LOCATION_EXTRA_COMMANDS": {
    "name": "访问定位额外命令",
    "description": "允许程序访问额外的定位提供者指令",
  },
  "android.permission.ACCESS_MOCK_LOCATION": {
    "name": "获取模拟定位信息",
    "description": "获取模拟定位信息,一般用于帮助开发者调试应用",
  },
  "android.permission.ACCESS_NETWORK_STATE": {
    "name": "获取网络状态",
    "description": "获取网络信息状态,如当前的网络连接是否有效",
  },
  "android.permission.ACCESS_SURFACE_FLINGER": {
    "name": "访问Surface Flinger",
    "description": "Android平台上底层的图形显示支持,一般用于游戏或照相机预览界面和底层模式的屏幕截图",
  },
  "android.permission.ACCESS_WIFI_STATE": {
    "name": "获取WiFi状态",
    "description": "获取当前WiFi接入的状态以及WLAN热点的信息",
  },
  "android.permission.ACCOUNT_MANAGER": {
    "name": "账户管理",
    "description": "获取账户验证信息,主要为GMail账户信息,只有系统级进程才能访问的权限",
  },
  "android.permission.AUTHENTICATE_ACCOUNTS": {
    "name": "验证账户",
    "description": "允许一个程序通过账户验证方式访问账户管理ACCOUNT_MANAGER相关信息",
  },
  "android.permission.BATTERY_STATS": {
    "name": "电量统计",
    "description": "获取电池电量统计信息",
  },
  "android.permission.BIND_APPWIDGET": {
    "name": "绑定小插件",
    "description": "允许一个程序告诉appWidget服务需要访问小插件的数据库,只有非常少的应用才用到此权限",
  },
  "android.permission.BIND_DEVICE_ADMIN": {
    "name": "绑定设备管理",
    "description": "请求系统管理员接收者receiver,只有系统才能使用",
  },
  "android.permission.BIND_INPUT_METHOD": {
    "name": "绑定输入法",
    "description": "请求InputMethodService服务,只有系统才能使用",
  },
  "android.permission.BIND_REMOTEVIEWS": {
    "name": "绑定RemoteView",
    "description": "必须通过RemoteViewsService服务来请求,只有系统才能用",
  },
  "android.permission.BIND_WALLPAPER": {
    "name": "绑定壁纸",
    "description": "必须通过WallpaperService服务来请求,只有系统才能用",
  },
  "android.permission.BLUETOOTH": {
    "name": "使用蓝牙",
    "description": "允许程序连接配对过的蓝牙设备",
  },
  "android.permission.BLUETOOTH_ADMIN": {
    "name": "蓝牙管理",
    "description": "允许程序进行发现和配对新的蓝牙设备",
  },
  "android.permission.BRICK": {
    "name": "变成砖头",
    "description": "能够禁用手机,非常危险,顾名思义就是让手机变成砖头",
  },
  "android.permission.BROADCAST_PACKAGE_REMOVED": {
    "name": "应用删除时广播",
    "description": "当一个应用在删除时触发一个广播",
  },
  "android.permission.BROADCAST_SMS": {
    "name": "收到短信时广播",
    "description": "当收到短信时触发一个广播",
  },
  "android.permission.BROADCAST_STICKY": {
    "name": "连续广播",
    "description": "允许一个程序收到广播后快速收到下一个广播",
  },
  "android.permission.BROADCAST_WAP_PUSH": {
    "name": "WAP PUSH广播",
    "description": "WAP PUSH服务收到后触发一个广播",
  },
  "android.permission.CALL_PHONE": {
    "name": "拨打电话",
    "description": "允许程序从非系统拨号器里输入电话号码",
  },
  "android.permission.CALL_PRIVILEGED": {
    "name": "通话权限",
    "description": "允许程序拨打电话,替换系统的拨号器界面",
  },
  "android.permission.CAMERA": {"name": "拍照权限", "description": "允许访问摄像头进行拍照"},
  "android.permission.CHANGE_COMPONENT_ENABLED_STATE": {
    "name": "改变组件状态",
    "description": "改变组件是否启用状态",
  },
  "android.permission.CHANGE_CONFIGURATION": {
    "name": "改变配置",
    "description": "允许当前应用改变配置,如定位",
  },
  "android.permission.CHANGE_NETWORK_STATE": {
    "name": "改变网络状态",
    "description": "改变网络状态如是否能联网",
  },
  "android.permission.CHANGE_WIFI_MULTICAST_STATE": {
    "name": "改变WiFi多播状态",
    "description": "改变WiFi多播状态",
  },
  "android.permission.CHANGE_WIFI_STATE": {
    "name": "改变WiFi状态",
    "description": "改变WiFi状态",
  },
  "android.permission.CLEAR_APP_CACHE": {
    "name": "清除应用缓存",
    "description": "清除应用缓存",
  },
  "android.permission.CLEAR_APP_USER_DATA": {
    "name": "清除用户数据",
    "description": "清除应用的用户数据",
  },
  "android.permission.CWJ_GROUP": {
    "name": "底层访问权限",
    "description": "允许CWJ账户组访问底层信息",
  },
  "android.permission.CELL_PHONE_MASTER_EX": {
    "name": "手机优化大师扩展权限",
    "description": "手机优化大师扩展权限",
  },
  "android.permission.CONTROL_LOCATION_UPDATES": {
    "name": "控制定位更新",
    "description": "允许获得移动网络定位信息改变",
  },
  "android.permission.DELETE_CACHE_FILES": {
    "name": "删除缓存文件",
    "description": "允许应用删除缓存文件",
  },
  "android.permission.DELETE_PACKAGES": {
    "name": "删除应用",
    "description": "允许程序删除应用",
  },
  "android.permission.DEVICE_POWER": {
    "name": "电源管理",
    "description": "允许访问底层电源管理",
  },
  "android.permission.DIAGNOSTIC": {
    "name": "应用诊断",
    "description": "允许程序到RW到诊断资源",
  },
  "android.permission.DISABLE_KEYGUARD": {
    "name": "禁用键盘锁",
    "description": "允许程序禁用键盘锁",
  },
  "android.permission.DUMP": {
    "name": "转存系统信息",
    "description": "允许程序获取系统dump信息从系统服务",
  },
  "android.permission.EXPAND_STATUS_BAR": {
    "name": "状态栏控制",
    "description": "允许程序扩展或收缩状态栏",
  },
  "android.permission.FACTORY_TEST": {
    "name": "工厂测试模式",
    "description": "允许程序运行工厂测试模式",
  },
  "android.permission.FLASHLIGHT": {"name": "使用闪光灯", "description": "允许访问闪光灯"},
  "android.permission.FORCE_BACK": {
    "name": "强制后退",
    "description": "允许程序强制使用back后退按键,无论Activity是否在顶层",
  },
  "android.permission.GET_ACCOUNTS": {
    "name": "访问账户Gmail列表",
    "description": "访问GMail账户列表",
  },
  "android.permission.GET_PACKAGE_SIZE": {
    "name": "获取应用大小",
    "description": "获取应用的文件大小",
  },
  "android.permission.GET_TASKS": {
    "name": "获取任务信息",
    "description": "允许程序获取当前或最近运行的应用",
  },
  "android.permission.GLOBAL_SEARCH": {
    "name": "允许全局搜索",
    "description": "允许程序使用全局搜索功能",
  },
  "android.permission.HARDWARE_TEST": {
    "name": "硬件测试",
    "description": "访问硬件辅助设备,用于硬件测试",
  },
  "android.permission.INJECT_EVENTS": {
    "name": "注射事件",
    "description": "允许访问本程序的底层事件,获取按键、轨迹球的事件流",
  },
  "android.permission.INSTALL_LOCATION_PROVIDER": {
    "name": "安装定位提供",
    "description": "安装定位提供",
  },
  "android.permission.INSTALL_PACKAGES": {
    "name": "安装应用程序",
    "description": "允许程序安装应用",
  },
  "android.permission.INTERNAL_SYSTEM_WINDOW": {
    "name": "内部系统窗口",
    "description": "允许程序打开内部窗口,不对第三方应用程序开放此权限",
  },
  "android.permission.INTERNET": {
    "name": "访问网络",
    "description": "访问网络连接,可能产生GPRS流量",
  },
  "android.permission.KILL_BACKGROUND_PROCESSES": {
    "name": "结束后台进程",
    "description": "允许程序调用killBackgroundProcesses(String).方法结束后台进程",
  },
  "android.permission.MANAGE_ACCOUNTS": {
    "name": "管理账户",
    "description": "允许程序管理AccountManager中的账户列表",
  },
  "android.permission.MANAGE_APP_TOKENS": {
    "name": "管理程序引用",
    "description": "管理创建、摧毁、Z轴顺序,仅用于系统",
  },
  "android.permission.MTWEAK_USER": {
    "name": "高级权限",
    "description": "允许mTweak用户访问高级系统权限",
  },
  "android.permission.MTWEAK_FORUM": {
    "name": "社区权限",
    "description": "允许使用mTweak社区权限",
  },
  "android.permission.MASTER_CLEAR": {
    "name": "软格式化",
    "description": "允许程序执行软格式化,删除系统配置信息",
  },
  "android.permission.MODIFY_AUDIO_SETTINGS": {
    "name": "修改声音设置",
    "description": "修改声音设置信息",
  },
  "android.permission.MODIFY_PHONE_STATE": {
    "name": "修改电话状态",
    "description": "修改电话状态,如飞行模式,但不包含替换系统拨号器界面",
  },
  "android.permission.MOUNT_FORMAT_FILESYSTEMS": {
    "name": "格式化文件系统",
    "description": "格式化可移动文件系统,比如格式化清空SD卡",
  },
  "android.permission.MOUNT_UNMOUNT_FILESYSTEMS": {
    "name": "挂载文件系统",
    "description": "挂载、反挂载外部文件系统",
  },
  "android.permission.NFC": {
    "name": "允许NFC通讯",
    "description": "允许程序执行NFC近距离通讯操作,用于移动支持",
  },
  "android.permission.PERSISTENT_ACTIVITY": {
    "name": "永久Activity",
    "description": "创建一个永久的Activity,该功能标记为将来将被移除",
  },
  "android.permission.PROCESS_OUTGOING_CALLS": {
    "name": "处理拨出电话",
    "description": "允许程序监视,修改或放弃播出电话",
  },
  "android.permission.READ_CALENDAR": {
    "name": "读取日程提醒",
    "description": "允许程序读取用户的日程信息",
  },
  "android.permission.READ_CONTACTS": {
    "name": "读取联系人",
    "description": "允许应用访问联系人通讯录信息",
  },
  "android.permission.READ_FRAME_BUFFER": {
    "name": "屏幕截图",
    "description": "读取帧缓存用于屏幕截图",
  },
  "com.android.browser.permission.READ_HISTORY_BOOKMARKS": {
    "name": "读取收藏夹和历史记录",
    "description": "读取浏览器收藏夹和历史记录",
  },
  "android.permission.READ_INPUT_STATE": {
    "name": "读取输入状态",
    "description": "读取当前键的输入状态,仅用于系统",
  },
  "android.permission.READ_LOGS": {"name": "读取系统日志", "description": "读取系统底层日志"},
  "android.permission.READ_PHONE_STATE": {
    "name": "读取电话状态",
    "description": "访问电话状态",
  },
  "android.permission.READ_SMS": {"name": "读取短信内容", "description": "读取短信内容"},
  "android.permission.READ_SYNC_SETTINGS": {
    "name": "读取同步设置",
    "description": "读取同步设置,读取Google在线同步设置",
  },
  "android.permission.READ_SYNC_STATS": {
    "name": "读取同步状态",
    "description": "读取同步状态,获得Google在线同步状态",
  },
  "android.permission.REBOOT": {"name": "重启设备", "description": "允许程序重新启动设备"},
  "android.permission.RECEIVE_BOOT_COMPLETED": {
    "name": "开机自动允许",
    "description": "允许程序开机自动运行",
  },
  "android.permission.RECEIVE_MMS": {"name": "接收彩信", "description": "接收彩信"},
  "android.permission.RECEIVE_SMS": {"name": "接收短信", "description": "接收短信"},
  "android.permission.RECEIVE_WAP_PUSH": {
    "name": "接收Wap Push",
    "description": "接收WAP PUSH信息",
  },
  "android.permission.RECORD_AUDIO": {
    "name": "录音",
    "description": "录制声音通过手机或耳机的麦克",
  },
  "android.permission.REORDER_TASKS": {
    "name": "排序系统任务",
    "description": "重新排序系统Z轴运行中的任务",
  },
  "android.permission.RESTART_PACKAGES": {
    "name": "结束系统任务",
    "description": "结束任务通过restartPackage(String)方法,该方式将在外来放弃",
  },
  "android.permission.SEND_SMS": {"name": "发送短信", "description": "发送短信"},
  "android.permission.SET_ACTIVITY_WATCHER": {
    "name": "设置Activity观察其",
    "description": "设置Activity观察器一般用于monkey测试",
  },
  "com.android.alarm.permission.SET_ALARM": {
    "name": "设置闹铃提醒",
    "description": "设置闹铃提醒",
  },
  "android.permission.SET_ALWAYS_FINISH": {
    "name": "设置总是退出",
    "description": "设置程序在后台是否总是退出",
  },
  "android.permission.SET_ANIMATION_SCALE": {
    "name": "设置动画缩放",
    "description": "设置全局动画缩放",
  },
  "android.permission.SET_DEBUG_APP": {
    "name": "设置调试程序",
    "description": "设置调试程序,一般用于开发",
  },
  "android.permission.SET_ORIENTATION": {
    "name": "设置屏幕方向",
    "description": "设置屏幕方向为横屏或标准方式显示,不用于普通应用",
  },
  "android.permission.SET_PREFERRED_APPLICATIONS": {
    "name": "设置应用参数",
    "description": "设置应用的参数,已不再工作具体查看addPackageToPreferred(String)介绍",
  },
  "android.permission.SET_PROCESS_LIMIT": {
    "name": "设置进程限制",
    "description": "允许程序设置最大的进程数量的限制",
  },
  "android.permission.SET_TIME": {"name": "设置系统时间", "description": "设置系统时间"},
  "android.permission.SET_TIME_ZONE": {
    "name": "设置系统时区",
    "description": "设置系统时区",
  },
  "android.permission.SET_WALLPAPER": {
    "name": "设置桌面壁纸",
    "description": "设置桌面壁纸",
  },
  "android.permission.SET_WALLPAPER_HINTS": {
    "name": "设置壁纸建议",
    "description": "设置壁纸建议",
  },
  "android.permission.SIGNAL_PERSISTENT_PROCESSES": {
    "name": "发送永久进程信号",
    "description": "发送一个永久的进程信号",
  },
  "android.permission.STATUS_BAR": {
    "name": "状态栏控制",
    "description": "允许程序打开、关闭、禁用状态栏",
  },
  "android.permission.SUBSCRIBED_FEEDS_READ": {
    "name": "访问订阅内容",
    "description": "访问订阅信息的数据库",
  },
  "android.permission.SUBSCRIBED_FEEDS_WRITE": {
    "name": "写入订阅内容",
    "description": "写入或修改订阅内容的数据库",
  },
  "android.permission.SYSTEM_ALERT_WINDOW": {
    "name": "显示系统窗口",
    "description": "显示系统窗口",
  },
  "android.permission.UPDATE_DEVICE_STATS": {
    "name": "更新设备状态",
    "description": "更新设备状态",
  },
  "android.permission.USE_CREDENTIALS": {
    "name": "使用证书",
    "description": "允许程序请求验证从AccountManager",
  },
  "android.permission.USE_SIP": {
    "name": "使用SIP视频",
    "description": "允许程序使用SIP视频服务",
  },
  "android.permission.VIBRATE": {"name": "使用振动", "description": "允许振动"},
  "android.permission.WAKE_LOCK": {
    "name": "唤醒锁定",
    "description": "允许程序在手机屏幕关闭后后台进程仍然运行",
  },
  "android.permission.WRITE_APN_SETTINGS": {
    "name": "写入GPRS接入点设置",
    "description": "写入网络GPRS接入点设置",
  },
  "android.permission.WRITE_CALENDAR": {
    "name": "写入日程提醒",
    "description": "写入日程,但不可读取",
  },
  "android.permission.WRITE_CONTACTS": {
    "name": "写入联系人",
    "description": "写入联系人,但不可读取",
  },
  "android.permission.Read_EXTERNAL_STORAGE": {
    "name": "读取外部存储",
    "description": "允许程序读取外部存储,如SD卡上写文件",
  },
  "android.permission.WRITE_EXTERNAL_STORAGE": {
    "name": "写入外部存储",
    "description": "允许程序写入外部存储,如SD卡上写文件",
  },
  "android.permission.WRITE_GSERVICES": {
    "name": "写入Google地图数据",
    "description": "允许程序写入Google Map服务数据",
  },
  "com.android.browser.permission.WRITE_HISTORY_BOOKMARKS": {
    "name": "写入收藏夹和历史记录",
    "description": "写入浏览器历史记录或收藏夹,但不可读取",
  },
  "android.permission.WRITE_SECURE_SETTINGS": {
    "name": "读写系统敏感设置",
    "description": "允许程序读写系统安全敏感的设置项",
  },
  "android.permission.WRITE_SETTINGS": {
    "name": "读写系统设置",
    "description": "允许读写系统设置项",
  },
  "android.permission.WRITE_SMS": {"name": "编写短信", "description": "允许编写短信"},
};


const packedInfo = { //自己之前存特征的数据库不小心删了，这里从https://github.com/moyuwa/ApkCheckPack取的特征
  "360加固": {
    "sopath": [
      "assets/libjiagu.so"
    ],
    "soname": [
      "libjiagu.so",
      "libjgdtc.so",
      "libjgdtc_a64.so",
      "libjgdtc_art.so",
      "libjgdtc_x64.so",
      "libjgdtc_x86.so",
      "libjiagu.so",
      "libjiagu_a64.so",
      "libjiagu_art.so",
      "libjiagu_ls.so",
      "libjiagu_x64.so",
      "libjiagu_x86.so",
      "libprotectClass.so",
      "libSafeManageService.so"
    ],
    "other": [
      "assets/.appkey"
    ],
    "soregex": [
      r"libjiagu\\_...\\.so",
      r"libjgdtc\\_...\\.so"
    ]
  },
  "APKProtect": {
    "sopath": [
    ],
    "soname": [
      "libAPKProtect.so"
    ],
    "other": [
    ],
    "soregex": [
    ]
  },
  "apktoolplus": {
    "sopath": [
      "lib/armeabi/libapktoolplus_jiagu.so"
    ],
    "soname": [
      "libapktoolplus_jiagu.so"
    ],
    "other": [
      "assets/jiagu_data.bin",
      "assets/sign.bin"
    ],
    "soregex": [
    ]
  },
  "CFCA加固": {
    "sopath": [
    ],
    "soname": [
      "libbasec.so",
      "libbasec_x86.so",
      "libsecenh.so",
      "libsecenh_a64.so",
      "libsecenh_x86.so"
    ],
    "other": [
      "my_classes.jar"
    ],
    "soregex": [

    ]
  },
  "DexProtect加固": {
    "sopath": [
    ],
    "soname": [
    ],
    "other": [
      "assets/classes.dex.dat",
      "dp.arm-v7.so.dat",
      "dp.arm.so.dat"
    ],
    "soregex": [
    ]
  },
  "OPPO应用加固": {
    "sopath": [
    ],
    "soname": [
      "OPPOProtect.so",
      "OPPOProtect2019.so"
    ],
    "other": [
    ],
    "soregex": [
      r"OPPOProtect\\d\\d\\d\\d\\.so"
    ]
  },
  "OPPO安全检测SDK": {
    "sopath": [
      "jni/arm64-v8a/libomesStdSco.so",
      "jni/armeabi-v7a/libomesStdSco.so",
      "jni/x86/libomesStdSco.so",
      "jni/x86_64/libomesStdSco.so"
    ],
    "soname": [
      "libomesStdSco.so"
    ],
    "other": [
    ],
    "soregex": [
    ]
  },
  "UU安全加固": {
    "sopath": [
      "assets/libuusafe.jar.so",
      "assets/libuusafe.so",
      "lib/armeabi/libuusafeempty.so"
    ],
    "soname": [
      "libuusafe.jar.so",
      "libuusafe.so",
      "libuusafeempty.so"
    ],
    "other": [
    ],
    "soregex": [
    ]
  },
  "中国移动加固": {
    "sopath": [
      "lib/armeabi/libcmvmp.so",
      "lib/armeabi/libmogosec_dex.so",
      "lib/armeabi/libmogosec_sodecrypt.so",
      "lib/armeabi/libmogosecurity.so"
    ],
    "soname": [
      "libcmvmp.so",
      "libmogosec_dex.so",
      "libmogosec_sodecrypt.so",
      "libmogosecurity.so",
      "ibmogosecurity.so"
    ],
    "other": [
      "assets/mogosec_classes",
      "assets/mogosec_data",
      "assets/mogosec_dexinfo",
      "assets/mogosec_march"
    ],
    "soregex": [
    ]
  },
  "几维安全": {
    "sopath": [
      "lib/armeabi/kdpdata.so",
      "lib/armeabi/libkdp.so",
      "lib/armeabi/libkwscmm.so"
    ],
    "soname": [
      "kdpdata.so",
      "libkdp.so",
      "libkwscmm.so",
      "libkwscr.so",
      "libkwslinker.so"
    ],
    "other": [
      "assets/dex.dat"
    ],
    "soregex": [
    ]
  },
  "启明星辰": {
    "sopath": [
    ],
    "soname": [
      "libvenSec.so",
      "libvenustech.so"
    ],
    "other": [
    ],
    "soregex": [
    ]
  },
  "娜迦加固": {
    "sopath": [
    ],
    "soname": [
      "libchaosvmp.so",
      "libddog.so",
      "libfdog.so",
      "libhdog.so"
    ],
    "other": [
    ],
    "soregex": [
      r"lib.dog\\.so"
    ]
  },
  "娜迦加固（企业版）": {
    "sopath": [
    ],
    "soname": [
      "libedog.so"
    ],
    "other": [
    ],
    "soregex": [
    ]
  },
  "娜迦加固（开发者试用版-VMP）": {
    "sopath": [
    ],
    "soname": [
      "libvdog-x86.so",
      "libvdog.so"
    ],
    "other": [
    ],
    "soregex": [
      r"libvdog\\-...\\.so"
    ]
  },
  "娜迦加固（新版2022）": {
    "sopath": [
      "lib/armeabi/libxloader.so",
      "lib/armeabi-v7a/libxloader.so",
      "lib/arm64-v8a/libxloader.so"
    ],
    "soname": [
      "libxloader.so"
    ],
    "other": [
      "assets/maindata/fake_classes.dex"
    ],
    "soregex": [
    ]
  },
  "梆梆安全（企业版）": {
    "sopath": [
    ],
    "soname": [
      "libDexHelper-x86.so",
      "libDexHelper.so"
    ],
    "other": [
    ],
    "soregex": [
      r"libDexHelper\\-...\\.so"
    ]
  },
  "梆梆安全（免费版）": {
    "sopath": [
      "lib/armeabi/libSecShell-x86.so",
      "lib/armeabi/libSecShell.so"
    ],
    "soname": [
      "libSecShell_art.so",
      "libSecShell.so",
      "libSecShel1.so",
      "libsecexe.so",
      "libsecmain.so"
    ],
    "other": [
      "assets/secData0.jar"
    ],
    "soregex": [
    ]
  },
  "梆梆安全（定制版）": {
    "sopath": [
      "lib/armeabi/DexHelper.so"
    ],
    "soname": [
      "DexHelper.so"
    ],
    "other": [
      "assets/classes.jar"
    ],
    "soregex": [
    ]
  },
  "海云安加固": {
    "sopath": [
      "lib/armeabi/libitsec.so"
    ],
    "soname": [
      "libitsec.so"
    ],
    "other": [
      "assets/itse"
    ],
    "soregex": [
    ]
  },
  "深盾安全加固（Virbox Protector）": {
    "sopath": [
    ],
    "soname": [
      "ibvirbox32.so",
      "libvirbox64.so"
    ],
    "other": [
    ],
    "soregex": [
      r"libvirbox..\\.so"
    ]
  },
  "爱加密": {
    "sopath": [
      "assets/ijm_lib/armeabi/libexec.so",
      "assets/ijm_lib/X86/libexec.so",
      "lib/armeabi/libexecmain.so"
    ],
    "soname": [
      "libexecmain.so",
      "libexec.so"
    ],
    "other": [
      "assets/af.bin",
      "assets/signed.bin",
      "ijiami.dat"
    ],
    "soregex": [
    ]
  },
  "爱加密3代壳": {
    "sopath": [
    ],
    "soname": [
      "libexecv3.so"
    ],
    "other": [
      "assets/ijiami3.ajm"
    ],
    "soregex": [
    ]
  },
  "爱加密5代壳": {
    "sopath": [
      "assets/libijmDataEncryption.so"
    ],
    "soname": [
      "libijmDataEncryption.so"
    ],
    "other": [
      "assets/IJMDal.Data"
    ],
    "soregex": [
    ]
  },
  "爱加密企业版": {
    "sopath": [
    ],
    "soname": [
    ],
    "other": [
      "assets/ijiami.ajm"
    ],
    "soregex": [
    ]
  },
  "珊瑚灵御": {
    "sopath": [
      "assets/libreincp.so",
      "assets/libreincp_x86.so"
    ],
    "soname": [
      "libreincp.so",
      "libreincp_x86.so"
    ],
    "other": [
    ],
    "soregex": [
      r"libreincp\\_...\\.so"
    ]
  },
  "瑞星加固": {
    "sopath": [
    ],
    "soname": [
      "librsprotect.so"
    ],
    "other": [
    ],
    "soregex": [
    ]
  },
  "百度加固": {
    "sopath": [
      "lib/armeabi/libbaiduprotect.so"
    ],
    "soname": [
      "libbaiduprotect.so",
      "libbaiduprotect_art.so",
      "libbaiduprotect_x86.so"
    ],
    "other": [
      "assets/baiduprotect.jar",
      "assets/baiduprotect1.jar"
    ],
    "soregex": [
    ]
  },
  "盛大加固": {
    "sopath": [
    ],
    "soname": [
      "libapssec.so"
    ],
    "other": [
    ],
    "soregex": [
    ]
  },
  "网易易盾": {
    "sopath": [
    ],
    "soname": [
      "libnesec.so"
    ],
    "other": [
    ],
    "soregex": [
    ]
  },
  "网秦加固（国信灵通）": {
    "sopath": [
    ],
    "soname": [
      "libnqshield.so"
    ],
    "other": [
    ],
    "soregex": [
    ]
  },
  "腾讯Bugly": {
    "sopath": [
      "lib/arm64-v8a/libBugly.so"
    ],
    "soname": [
      "libBugly.so"
    ],
    "other": [
    ],
    "soregex": [
    ]
  },
  "腾讯乐固（VMP）": {
    "sopath": [
      "lib/arm64-v8a/libxgVipSecurity.so",
      "lib/armeabi-v7a/libxgVipSecurity.so"
    ],
    "soname": [
      "libxgVipSecurity.so"
    ],
    "other": [
    ],
    "soregex": [
    ]
  },
  "腾讯乐固（旧版）": {
    "sopath": [
      "lib/armeabi/libshella-xxxx.so",
      "lib/armeabi/libshellx-xxxx.so"
    ],
    "soname": [
      "liblegudb.so",
      "libshel1x.so",
      "libshell.so",
      "libshella-2.10.2.3.so",
      "libshella-2.9.0.2.so",
      "libshella-4.1.0.15.so",
      "libshella-4.1.0.19.so",
      "libshella.so",
      "libshellx.so",
      "libtup.so"
    ],
    "other": [
      "lib/armeabi/mix.dex",
      "lib/armeabi/mixz.dex",
      "tencent_stub"
    ],
    "soregex": [
      r"libshella\\-\\d+\\.\\d+\\.\\d+\\.\\d+\\.so"
    ]
  },
  "腾讯云加固": {
    "sopath": [
      "assets/libshellx-super.2021.so",
      "lib/armeabi/libshell-super.2019.so",
      "lib/armeabi/libshell-super.2020.so",
      "lib/armeabi/libshell-super.2021.so"
    ],
    "soname": [
      "libshell-super.2019.so",
      "libshellx-super.2021.so"
    ],
    "other": [
      "tencent_sub"
    ],
    "soregex": [
      r"libshellx\\-super\\.\\d+\\.so",
      r"libshell\\-super\\.\\d+\\.so"
    ]
  },
  "腾讯云移动应用安全": {
    "sopath": [
    ],
    "soname": [
    ],
    "other": [
      "0000000lllll.dex",
      "00000olllll.dex",
      "000O00ll111l.dex",
      "00O000ll111l.dex",
      "0OO00l111l1l",
      "o0oooOO0ooOo.dat"
    ],
    "soregex": [
    ]
  },
  "腾讯云移动应用安全（腾讯御安全）": {
    "sopath": [
    ],
    "soname": [
      "libBugly-yaq.so",
      "libshell-super.2019.so",
      "libshellx-super.2019.so",
      "libzBugly-yaq.so"
    ],
    "other": [
      "000000011111.dex",
      "000000111111.dex",
      "000001111111",
      "00000o11111.dex",
      "o0ooo000oo0o.dat",
      "t86",
      "tosprotection",
      "tosversion"
    ],
    "soregex": [
    ]
  },
  "腾讯加固": {
    "sopath": [
    ],
    "soname": [
      "libshell.so"
    ],
    "other": [
    ],
    "soregex": [
    ]
  },
  "腾讯手游加固": {
    "sopath": [
    ],
    "soname": [
      "libtprt.so"
    ],
    "other": [
    ],
    "soregex": [
    ]
  },
  "腾讯御安全": {
    "sopath": [
      "assets/libtosprotection.armeabi-v7a.so",
      "assets/libtosprotection.armeabi.so",
      "assets/libtosprotection.x86.so",
      "lib/armeabi/libtest.so",
      "lib/armeabi/libTmsdk-xxx-mfr.so"
    ],
    "soname": [
      "libtosprotection.armeabi-v7a.so",
      "libtosprotection.armeabi.so",
      "libtosprotection.x86.so"
    ],
    "other": [
      "assets/tosversion"
    ],
    "soregex": [
      r"libtosprotection\\..+\\.so"
    ]
  },
  "蛮犀加固": {
    "sopath": [
      "assets/mxsafe/arm64-v8a/libdSafeShell.so",
      "assets/mxsafe/x86_64/libdSafeShell.so",
      "assets/mx/lib/arm64-v8a/libmxacc.so",
      "assets/mx/lib/x86_64/libmxacc.so"
    ],
    "soname": [
      "libdSafeShell.so",
      "libmxacc.so"
    ],
    "other": [
      "assets/mxsafe.config",
      "assets/mxsafe.data",
      "assets/mxsafe.jar"
    ],
    "soregex": [
    ]
  },
  "通付盾": {
    "sopath": [
    ],
    "soname": [
      "libNSaferOnly.so",
      "libegis.so",
      "libgeiri.so",
      "libgeiri-x86.so"
    ],
    "other": [
    ],
    "soregex": [
    ]
  },
  "阿里云加固": {
    "sopath": [
    ],
    "soname": [
      "libdemolish.so",
      "libdemolishdata.so"
    ],
    "other": [
    ],
    "soregex": [
    ]
  },
  "阿里加固": {
    "sopath": [
      "assets/armeabi/libzuma.so",
      "assets/libpreverify1.so",
      "assets/libzuma.so",
      "assets/libzumadata.so"
    ],
    "soname": [
      "libzuma.so",
      "libpreverify1.so",
      "libmobisec.so",
      "libsgmain.so",
      "libsgsecuritybody.so"
    ],
    "other": [
      "aliprotect.dat"
    ],
    "soregex": [
    ]
  },
  "阿里聚安全": {
    "sopath": [
      "assets/armeabi/libfakejni.so",
      "assets/libpreverify1.so",
      "assets/libzuma.so",
      "assets/libzumadata.so"
    ],
    "soname": [
      "libdemolish.so",
      "libdemolishdata.so",
      "libfakejni.so",
      "libmobisec.so",
      "libpreverify1.so",
      "libsgmain.so",
      "libsgsecuritybody.so",
      "libzumadata.so"
    ],
    "other": [
      "aliprotect.dat"
    ],
    "soregex": [
    ]
  },
  "顶像科技": {
    "sopath": [
      "lib/armeabi/libx3g.so"
    ],
    "soname": [
      "libx3g.so",
      "libjni.so"
    ],
    "other": [
    ],
    "soregex": [
    ]
  },
  "google(play)加固": {
    "sopath": [
      "lib/arm64-v8a/libpairipcore.so",
      "lib/armeabi-v7a/libpairipcore.so",
      "lib/x86_64/libpairipcore.so",
      "lib/x86/libpairipcore.so"
    ],
    "soname": [
      "libpairipcore.so"
    ],
    "other": [
    ],
    "soregex": [
    ]
  },
  "LIAPP加固": {
    "sopath": [
    ],
    "soname": [
    ],
    "other": [
      "assets/LIAPP.ini",
      "assets/pkgInfo.txt"
    ],
    "soregex": [
      r"com\\..+UnityDataAssetPack.+\\.apk$",
      r"com\\..+AddressablesAssetPack.+\\.apk$"
    ]
  },
  "未知厂商": {
    "sopath": [
    ],
    "soname": [
      "libapk-protect.so"
    ],
    "other": [
    ],
    "soregex": [
    ]
  }
};