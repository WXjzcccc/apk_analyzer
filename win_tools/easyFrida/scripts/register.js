(()=>{
    function klog(msg){
        var message = {}
        message['jsname'] = 'register.js'
        message['data'] = msg
        send(message)
    }

    function callRegisterNative(moduleName = '') {
        var libart = Process.findModuleByName("libart.so");
        const symbols = libart.enumerateSymbols();
        for (var symbol of symbols) {
            if (symbol.name.indexOf("RegisterNatives") != -1 && symbol.name.indexOf("CheckJNI") == -1) {
                var registerNativesAddr = symbol.address;
                Interceptor.attach(registerNativesAddr, {
                    onEnter: function (args) {
                        // const jClass = Java.vm.getEnv().getClassName(args[1]);
                        const methods = args[2];
                        const methodCount = args[3].toUInt32();
                        for (var i = 0; i < methodCount; i++) {
                            const methodName = methods.add(i * Process.pointerSize * 3).readPointer().readCString();
                            const methodSign = methods.add(i * Process.pointerSize * 3 + Process.pointerSize).readPointer().readCString();
                            const methodAddr = methods.add(i * Process.pointerSize * 3 + Process.pointerSize * 2).readPointer();
                            let module_so = Process.findModuleByAddress(methodAddr);
                            if (module_so == null) {
                                continue;
                            }
                            if (moduleName.includes(module_so.name) || moduleName == '') {
                                klog(`\n${module_so.name}注册了函数：\n`+
                                            `函数名：${methodName}\n`+
                                            `参数：${methodSign}\n`+
                                            `函数偏移地址：${methodAddr.sub(module_so.base)}`)
                            }
                        }
                    },
                    onLeave: function (retVal) {
    
                    }
                })
            }
        }
    }

    callRegisterNative();
})();