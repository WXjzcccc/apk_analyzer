class ApkInfo {
  String? id;
  String? packageName;
  String? versionName;
  String? versionCode;
  String? appName;
  String? iconPath;
  String? apkPath;
  String? apkSize;
  String? minSdkVersion;
  String? targetSdkVersion;
  String? compileSdkVersion;
  String? launcherActivity;
  String? packedInfo;
  String? builtInfo;
  List<String>? permissions;
  List<String>? activities;
  List<String>? services;
  List<String>? broadcastReceivers;
  List<String>? providers;
  Map<String, String>? metaData;

  ApkInfo({
    this.id,
    this.packageName,
    this.versionName,
    this.versionCode,
    this.appName,
    this.iconPath,
    this.apkPath,
    this.apkSize,
    this.minSdkVersion,
    this.targetSdkVersion,
    this.compileSdkVersion,
    this.launcherActivity,
    this.packedInfo,
    this.builtInfo,
    this.permissions,
    this.activities,
    this.services,
    this.broadcastReceivers,
    this.providers,
    this.metaData,
  });

  ApkInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    packageName = json['packageName'];
    versionName = json['versionName'];
    versionCode = json['versionCode'];
    appName = json['appName'];
    iconPath = json['iconPath'];
    apkPath = json['apkPath'];
    apkSize = json['apkSize'];
    minSdkVersion = json['minSdkVersion'];
    targetSdkVersion = json['targetSdkVersion'];
    compileSdkVersion = json['compileSdkVersion'];
    launcherActivity = json['launcherActivity'];
    packedInfo = json['packedInfo'];
    builtInfo = json['builtInfo'];
    permissions = json['permissions']?.cast<String>();
    activities = json['activities']?.cast<String>();
    services = json['services']?.cast<String>();
    broadcastReceivers = json['broadcastReceivers']?.cast<String>();
    providers = json['providers']?.cast<String>();
    metaData = json['metaData'] != null
        ? Map<String, String>.from(json['metaData'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['packageName'] = packageName;
    data['versionName'] = versionName;
    data['versionCode'] = versionCode;
    data['appName'] = appName;
    data['iconPath'] = iconPath;
    data['apkPath'] = apkPath;
    data['apkSize'] = apkSize;
    data['minSdkVersion'] = minSdkVersion;
    data['targetSdkVersion'] = targetSdkVersion;
    data['compileSdkVersion'] = compileSdkVersion;
    data['launcherActivity'] = launcherActivity;
    data['packedInfo'] = packedInfo;
    data['builtInfo'] = builtInfo;
    data['permissions'] = permissions;
    data['activities'] = activities;
    data['services'] = services;
    data['broadcastReceivers'] = broadcastReceivers;
    data['providers'] = providers;
    if (metaData != null) {
      data['metaData'] = metaData;
    }
    return data;
  }
}