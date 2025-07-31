(() => {
    function klog(msg){
        var message = {}
        message['jsname'] = 'bypass.js'
        message['data'] = msg
        send(message)
    }
    
    const suFiles = [
        "/data/local/bin/su",
        "/data/local/su",
        "/data/local/xbin/su",
        "/dev/com.koushikdutta.superuser.daemon/",
        "/sbin/su",
        "/system/app/Superuser.apk",
        "/system/bin/failsafe/su",
        "/system/bin/su",
        "/su/bin/su",
        "/system/etc/init.d/99SuperSUDaemon",
        "/system/sd/xbin/su",
        "/system/xbin/busybox",
        "/system/xbin/daemonsu",
        "/system/xbin/su",
        "/system/sbin/su",
        "/vendor/bin/su",
        "/cache/su",
        "/data/su",
        "/dev/su",
        "/system/bin/.ext/su",
        "/system/usr/we-need-root/su",
        "/system/app/Kinguser.apk",
        "/data/adb/magisk",
        "/sbin/.magisk",
        "/cache/.disable_magisk",
        "/dev/.magisk.unblock",
        "/cache/magisk.log",
        "/data/adb/magisk.img",
        "/data/adb/magisk.db",
        "/data/adb/magisk_simple",
        "/init.magisk.rc",
        "/system/xbin/ku.sud",
        "/data/adb/ksu",
        "/data/adb/ksud",
    ]

    function preventRuntimeExit() {
        let runtime = Java.use("java.lang.Runtime");
        runtime.exit.implementation = function (code) {
        }
    }

    function preventSystemExit() {
        let system = Java.use("java.lang.System");
        system.exit.implementation = function (code) {
        }
    }

    function preventProcessKill() {
        let process = Java.use("android.os.Process");
        process.killProcess.implementation = function (pid) {
        }
    }

    function checkStringContainsSu(arg) {
        var str = String(arg)
        if (str.includes("root")|| str.includes("magisk")|| str.includes("frida")) {
            return true;
        }
        for (let suFile of suFiles) {
            if (suFile.includes(str)) {
                return true;
            }
        }
        return false;
    }

    function hookJavaFile() {
        // 禁止检查文件
        let UnixFileSystem = Java.use("java.io.UnixFileSystem");
        UnixFileSystem.checkAccess.implementation = function (file, mode) {
            var fileName = file.getAbsolutePath();
            if (checkStringContainsSu(fileName)) {
                return false;
            }
            return this.checkAccess(file, mode);
        }
        // 禁止检查文件
        let File = Java.use("java.io.File");
        File.exists.implementation = function () {
            var fileName = this.getPath();
            if (checkStringContainsSu(fileName)) {
                return false;
            }
            return this.exists();
        };
    }

    function hookNativeFile() {
        var fopen = Module.findExportByName("libc.so", "fopen");
        Interceptor.attach(fopen, {
            onEnter: function (args) {
                this.fileName = Memory.readUtf8String(args[0]);
            },
            onLeave: function (retval) {
                if (checkStringContainsSu(this.fileName)) {
                    retval.replace(ptr(0x0));
                }
            }
        });
    }

    function preventRuntimeExec() {
        let runtime = Java.use("java.lang.Runtime");
        runtime.exec.overload("[Ljava.lang.String;").implementation = function (cmds) {
            for (let cmd of cmds) {
                if (cmd == "su" || cmd == "sudo") {
                    var fakeCmd = cmds.slice();
                    fakeCmd[0] = "echo";
                    return this.exec(fakeCmd);
                }
            }
            return this.exec(cmds);
        }
    }

    function fakeRoot() {
        hookJavaFile();
        hookNativeFile();
    }

    function fakeEquals() {
        let string = Java.use("java.lang.String")
        string['equals'].implementation = function (arg) {
            if (checkStringContainsSu(arg) || checkStringContainsSu(this.toString())) {
                return false;
            }
            return this.equals(arg);
        }
        string['equalsIgnoreCase'].implementation = function (arg) {
            if (checkStringContainsSu(arg) || checkStringContainsSu(this.toString())) {
                return false;
            }
            return this.equals(arg);
        }
    }

    function fakeNativeStr() {
        let strcmp = Module.findExportByName("libc.so", "strcmp");
        Interceptor.attach(strcmp, {
            onEnter: function (args) {
                this.arg0 = Memory.readUtf8String(args[0]);
                this.arg1 = Memory.readUtf8String(args[1]);
            },
            onLeave: function (retval) {
                if (checkStringContainsSu(this.arg0) || checkStringContainsSu(this.arg1)) {
                    retval.replace(1);
                }
            }
        });
        let strncmp = Module.findExportByName("libc.so", "strncmp");
        Interceptor.attach(strncmp, {
            onEnter: function (args) {
                this.arg0 = Memory.readUtf8String(args[0]);
                this.arg1 = Memory.readUtf8String(args[1]);
            },
            onLeave: function (retval) {
                if (checkStringContainsSu(this.arg0) || checkStringContainsSu(this.arg1)) {
                    retval.replace(1);
                }
            }
        });
        let strstr = Module.findExportByName("libc.so", "strstr");
        Interceptor.attach(strstr, {
            onEnter: function (args) {
                this.arg0 = Memory.readUtf8String(args[0]);
                this.arg1 = Memory.readUtf8String(args[1]);
            },
            onLeave: function (retval) {
                if (checkStringContainsSu(this.arg0) || checkStringContainsSu(this.arg1)) {
                    retval.replace(ptr(0x0));
                }
            }
        });
    }


    function main(){
        preventRuntimeExit();
        preventRuntimeExec();
        preventSystemExit();
        preventProcessKill();
        fakeRoot();
        fakeEquals();
        fakeNativeStr();
    }

    Java.perform(() => {
        main();
    });
    
})();