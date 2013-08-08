
(function(){
    /* __tib__csAttr function is used to identify extra attributes mentioned in current loading script */
	if(window["__tib__csAttr"]==undefined)
        window["__tib__csAttr"] = function(name,scriptName){
            var allScripts = document.getElementsByTagName("script"), scriptTag;
            for(var i = allScripts.length; i >=0 ;i-- ){
                if(allScripts[i-1].src && allScripts[i-1].src.indexOf(scriptName)!=-1){
                    scriptTag = allScripts[i-1];
                    return scriptTag.getAttribute(name);
                }
            }
            return undefined;
        }
    var objName = __tib__csAttr("tib-obj-name","TIB.js") || "TIB", TIB = window[objName] = {};
    TIB.version = "1.0.0";
    TIB._host = "";
    TIB.currentUser = undefined;
    TIB.loggedIn = false;
    TIB.__mode = window["__tib__mode"] || undefined;
    if(TIB.__mode=="debug")
    {
        TIB.logger = window.console;
    }
    else{
        TIB.logger = {
            log: function(){},
            info: function(){}
        }
    }
    var _scriptProcessing = 0, eventQueue = {},
    _events = TIB.__events = {
        on: function(name,callback){
            eventQueue[name] = eventQueue[name] || [];
            eventQueue[name].push(callback);
            
           
        },
        execute: function(){
            var name = arguments[0], args = [].slice.call(arguments, 1),cq = eventQueue[name] || [];
            for(var i in cq){
                if(typeof(cq[i])=="function")cq[i](args);
            }
        },
        off: function(name){
            eventQueue[name] = [];
        }
    },
    _scriptsBasePath = "/connect/js/",
    _scripts = {
        include: function(name,callback){
            var s = window.document.createElement("script");
            s.type = "text/javascript";
            s.setAttribute("tib-obj-name", objName);
            s.src = _protocal() + TIB._host + _scriptsBasePath + name + ".js";
            _scriptProcessing += 1;
            TIB.__events.on("load:"+name,function(){
                _scriptProcessing -= 1;
                if(typeof(callback)=="function")callback();
                if(_scriptProcessing==0)_scriptsOnLoad();

            })
            document.getElementsByTagName("body")[0].appendChild(s);
        }
    },
    _sslEnable = false,
    _protocal = function(){
        return "http"+(_sslEnable ? "s" : "") + "://"
    },
    _scriptsOnLoad = function(){
        if(typeof(_onScripsLoadsCallback)=="function")
            _onScripsLoadsCallback();
    },
    _onScripsLoadsCallback = null,
    _registerStylesheet = function(url){
        var s = window.document.createElement("link");
        s.type = "text/css";
        s.rel = "stylesheet";
        s.media = "all";
        s.href = _protocal()+ TIB._host + url;
        document.getElementsByTagName("head")[0].appendChild(s);
    },
    /* Function called when cross domain channel is established/connected*/
    _initializedChannel = function(callback){
        TIB.PageBus.subscribe("tibbr:proxy:connected", function(){
            _api({
                url:"/users/find_by_session",
                method:"GET",
                onResponse:function(data){
                    if(data && data.id){
                        TIB.currentUser = data;
                        TIB.loggedIn = true;
                        _events.execute("login",data);
                    }
                    if(typeof callback=="function")
                        callback();

                }
            })
            TIB.PageBus.unsubscribe("tibbr:proxy:connected");
        });
    },
    _createProxyClient = function(url,id,container, frameOptions,onConnect){
        container = container || document.createElement("div");
        frameOptions = frameOptions || {
            scrolling: "no",
            style: {
                border:"white solid 1px",
                width: "0",
                height: "0",
                visibility:"hidden",
                display:"none"
            }
        };
        return new TIB.OpenAjax.hub.IframeContainer( window.tibbrManagedHub, id,
        {
            Container: {
                onSecurityAlert: function( source, alertType ) { },
                onConnect: function(){
                    onConnect.call()
                }
            },
            IframeContainer: {
                parent: container,
                iframeAttrs: frameOptions ,
                uri: url,
                tunnelURI:  TIB._tunnelUrl
            }
        }
        )._iframe;
    },
    _setupCORS = function(callback){
        TIB.OpenAjax  = TIB.__pageBus.openAjax;
        TIB.smash = TIB.__pageBus.smash;
        TIB.PageBus.init();

        var cont = document.createElement("div"), cb = function(){
            _initializedChannel(callback);
        };
        cont.id = "tib-connet-proxy";
        var hostprefix = encodeURIComponent(TIB._host);
        var proxyConnect = _createProxyClient(_protocal()+ TIB._host+"/connect/connect_proxy.html?obref="+objName+"&hpfx=" + hostprefix, "proxyConnect",document.getElementsByTagName("body")[0],false,cb);
    },
    _setup = function(callback){
        _onScripsLoadsCallback = function(){
            _setupCORS(callback);
        };
        _scripts.include("pagebus");
        _scripts.include("tibbr.pagebus");
        if(TIB._pluginsEnabled){
            _registerStylesheet("/connect/stylesheets/tibbr_share.css");
            _scripts.include("tib-min",function(){
                _scripts.include("plugins");
            });
        }
        if(TIB._parentTibbr)
            _scripts.include("parent_connector");
    },
    __apiResponseHandler = function(data,params){
        params.onResponse(data.r, data.rc);
        TIB.PageBus.unsubscribe(params.handlerId);

    },
    _api = function(args){
        args["handlerId"] = "api:response:"+Math.floor(Math.random() * 1111);
        args.url = _protocal() +TIB._host +"" + args.url;
      
        var params = {
            "u": args.url,
            "m": args.method,
            "t": args.type,
            "d": args.params,
            "hid" : args.handlerId
        };
        TIB.PageBus.publish("api:call", params);
        TIB.PageBus.subscribe(args["handlerId"],function(data){
            __apiResponseHandler(data,args)
        });
    },
    _login = function(callback){
        TIB.PageBus.publish("tibbr:login:request");
        if(callback)
            TIB.onLogin(callback)
        TIB.PageBus.subscribe("tibbr:login:response",function(data){
            TIB.currentUser = data;
            TIB.loggedIn = true;
            _events.execute("login",data);
            TIB.PageBus.unsubscribe("tibbr:login:response");
        });
    };


    TIB.onInit = function(callback){
        _events.on("initialize",callback);
    };
    TIB.onLogin = function(callback){
        _events.on("login",callback);/*_loginCallbacks.push(callback)*/
    };
    TIB.login = _login;
    TIB.initialized = false;
    TIB.__addProxyClient = _createProxyClient;
    TIB.init = function(options){
        if(TIB.initialized)
        return false;
        window.__tibHost = TIB._host = options.host;
        TIB._tunnelUrl = options.tunnelUrl+"?objname="+objName;
        TIB._protocal = _protocal;
        TIB._parentTibbr = options.renderInTibbr;
        TIB._pluginsEnabled = options.plugins;
        TIB.api = _api;
        _setup(function(){
            if(TIB.initialized)
             return false;
            TIB.initialized = true;
            TIB.api = _api;
            _events.execute("initialize");
            if(typeof(options.onInitialize) =="function")
                options.onInitialize();
        });
    
    };
})();
