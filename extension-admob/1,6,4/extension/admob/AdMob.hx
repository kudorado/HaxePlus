package extension.admob;

import openfl.Lib;
import flixel.FlxG;

class AdMob {

    private static var initialized:Bool=false;
    private static var testingAds:Bool=false;
    private static var childDirected:Bool=false;

    ////////////////////////////////////////////////////////////////////////////

    private static var __init:Void->Void = function(){};
    private static var __initShit:String->String->String->Bool->Bool->Dynamic->Void = function(bannerId:String, interstitialId:String, gravityMode:String, testingAds:Bool, tagForChildDirectedTreatment:Bool, callback:Dynamic){};

    private static var __initHaxeObject:Dynamic->Void = function(instance:Dynamic){};

    private static var __showBanner:Void->Void = function(){};
    private static var __requestRating:Void->Void = function(){};

    private static var __hideBanner:Void->Void = function(){};
    private static var __showInterstitial:Void->Bool = function(){ return false; };
    private static var __showRewardVideo:Void->Bool = function(){ return false; };

    private static var __onResize:Void->Void = function(){};
    private static var __refresh:Void->Void = function(){};

    ////////////////////////////////////////////////////////////////////////////

    private static var lastTimeInterstitial:Int = 60*1000;
    private static var displayCallsCounter:Int = 0;
    
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    public static function showRewardVideo():Bool
    {
		var result:Bool = __showRewardVideo();
		return result;
    }

    public static function showInterstitial(minInterval:Int=60, minCallsBeforeDisplay:Int=0) {
        // displayCallsCounter++;
        // #if android 
        // minInterval = 30;
        // #end
        minInterval = 0;

        if( (Lib.getTimer()-lastTimeInterstitial)<(minInterval*1000) ) return false;
        // if( minCallsBeforeDisplay > displayCallsCounter ) return false;
	    	// displayCallsCounter = 0;

        lastTimeInterstitial = Lib.getTimer();

            #if android
             return __showInterstitial();
            #end

            #if ios
             return __showInterstitial();
            #end
       
      
        return false;
    }

    public static function tagForChildDirectedTreatment(){
        if ( childDirected ) return;
        if ( initialized ) {
            var msg:String;
            msg = "FATAL ERROR: If you want to set tagForChildDirectedTreatment, you must enable them before calling INIT!.\n";
            msg+= "Throwing an exception to avoid displaying ads withtou tagForChildDirectedTreatment.";
            //KUDORADOtrace(msg);
            throw msg;
            return;
        }
        childDirected = true;       
    }
    
    public static function enableTestingAds() {
        if ( testingAds ) return;
        if ( initialized ) {
            var msg:String;
            msg = "FATAL ERROR: If you want to enable Testing Ads, you must enable them before calling INIT!.\n";
            msg+= "Throwing an exception to avoid displaying read ads when you want testing ads.";
            //KUDORADOtrace(msg);
            throw msg;
            return;
        }
        testingAds = true;
    }

    public static function initHaxeObject() 
    {
        __initHaxeObject(getInstance());
	}   
    public static function initAndroid(){
        // if(initialized) return;
        // initialized = true;
        #if android
        try{
            // JNI METHOD LINKING
            __init = lime.system.JNI.createStaticMethod("admobex/AdMobEx", "init", "()V");
            __showBanner = lime.system.JNI.createStaticMethod ("admobex/AdMobEx", "showBanner", "()V");
            __hideBanner = lime.system.JNI.createStaticMethod("admobex/AdMobEx", "hideBanner", "()V");
            __showInterstitial = lime.system.JNI.createStaticMethod("admobex/AdMobEx", "showInterstitial", "()V");
            __onResize = lime.system.JNI.createStaticMethod("admobex/AdMobEx", "onResize", "()V");
            __showRewardVideo = lime.system.JNI.createStaticMethod("admobex/AdMobEx", "showRewardVideo", "()Z");
            // __initHaxeObject = lime.system.JNI.createStaticMethod("admobex/AdMobEx", "initHaxeObject", "(Lorg/haxe/lime/HaxeObject)V");
            __initShit = lime.system.JNI.createStaticMethod("admobex/AdMobEx", "initShit", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ZZLorg/haxe/lime/HaxeObject;)V");
            __initShit("", "", "", false, false, getInstance());
            // __init();
            // __initHaxeObject(getInstance());


        }catch(e:Dynamic){
            //KUDORADOtrace("Android INIT Exception: "+e);
        }

        #end
    }
    
    public static function initIOS(bannerId:String, interstitialId:String, gravityMode:GravityMode){
        #if ios
        if(initialized) return;
        initialized = true;
        try{
            // CPP METHOD LINKING
            __initShit = cpp.Lib.load("adMobEx","admobex_init",6);
            __showRewardVideo = cpp.Lib.load("adMobEx","admobex_banner_show",0);
            __hideBanner = cpp.Lib.load("adMobEx","admobex_banner_hide",0);
            __showInterstitial = cpp.Lib.load("adMobEx","admobex_interstitial_show",0);
            __refresh = cpp.Lib.load("adMobEx","admobex_banner_refresh",0);
			// __init(bannerId,interstitialId,(gravityMode==GravityMode.TOP)?'TOP':'BOTTOM',testingAds, childDirected, getInstance()._onInterstitialEvent);
            __initShit(bannerId, "", "", false, false, getInstance()._onInterstitialEvent);
        }catch(e:Dynamic)
        {
            trace("iOS INIT Exception: "+e);
        }
        #end
    }
    
    public static function showBanner() {
        return;
        try {
            __showBanner();
        } catch(e:Dynamic) {
            //KUDORADOtrace("ShowAd Exception: "+e);
        }
    }
    
    public static function hideBanner() {
        // if(!MainMenuState.allowHideBannerShit) return;

        try {
            __hideBanner();
        } catch(e:Dynamic) {
            //KUDORADOtrace("HideAd Exception: "+e);
        }
    }
    
    public static function onResize() {
        try{
            __onResize();
        }catch(e:Dynamic){
            //KUDORADOtrace("onResize Exception: "+e);
        }
    }

    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////

    public static inline var LEAVING:String = "LEAVING";
    public static inline var FAILED:String = "FAILED";
    public static inline var CLOSED:String = "CLOSED";
    public static inline var DISPLAYING:String = "DISPLAYING";
    public static inline var LOADED:String = "LOADED";
    public static inline var LOADING:String = "LOADING";

    ////////////////////////////////////////////////////////////////////////////

    public static var onInterstitialEvent:String->Void = function (evName:String) {
        trace("empty ev");
    };
    private static var instance:AdMob = null;

    private static function getInstance():AdMob{
        if (instance == null) instance = new AdMob();
        return instance;
    }

    ////////////////////////////////////////////////////////////////////////////

    private function new(){}

	public function _onInterstitialEvent(event:String) {
        switch (event){
            case 'LEAVING'://REWARD CALLBACK
            if (onInterstitialEvent != null)
            {
                onInterstitialEvent(event);
                trace("video callback");
            }
            case "CLOSED":
                FlxG.sound.muted = false;

            case "DISPLAYING":
                FlxG.sound.muted = true;

        }   
       
       // else //KUDORADOtrace("Interstitial event: "+event+ " (assign AdMob.onInterstitialEvent to get this events and avoid this traces)");
    }
    
}
