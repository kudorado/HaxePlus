#include <AdMobEx.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFAudio.h>
#import "GoogleMobileAds/GADInterstitialAd.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/AdSupport.h>
#import "GoogleMobileAds/GoogleMobileAds.h"
#import "IronSource/IronSource.h"
extern "C"
{
    #import "GoogleMobileAds/GADBannerView.h"
}

extern "C" void reportInterstitialEvent (const char* event);
static const char* ADMOB_LEAVING = "LEAVING";
static const char* ADMOB_FAILED = "FAILED";
static const char* ADMOB_CLOSED = "CLOSED";
static const char* ADMOB_DISPLAYING = "DISPLAYING";
static const char* ADMOB_LOADED = "LOADED";
static const char* ADMOB_LOADING = "LOADING";

////////////////////////////////////////////////////////////////////////

static bool _admobexChildDirected = true;

GADRequest *_admobexGetGADRequest(){
    GADRequest *request = [GADRequest request];
    if(_admobexChildDirected)
    {
        NSLog(@"AdMobEx: enabling COPPA support");
        [request tagForChildDirectedTreatment:YES];
    }
    return request;        
}

////////////////////////////////////////////////////////////////////////
//banner
@interface BannerViewListener : NSObject<GADBannerViewDelegate> {
}
@property(nonatomic, strong) GADBannerView *bannerView;

- (id)reInit:(NSString*)ID;
- (id)requestIDFA:(NSString*)BANNER;
- (id)showBanner:(NSString*)shit;
- (id)hideBanner:(NSString*)shit;
- (id)addBannerViewToView:(UIView*)shit;

// - (bool)isReady;

@end

@implementation BannerViewListener

-(id)initWithID: (NSString*)ID {

    UIWindow* win =  [[UIApplication sharedApplication] keyWindow];
    UIViewController* vc = [win rootViewController];

    self.bannerView = [[GADBannerView alloc] initWithAdSize: kGADAdSizeBanner];
    self.bannerView.adUnitID = ID;
    self.bannerView.rootViewController = vc;
    self.bannerView.delegate = self;



    GADRequest *request = _admobexGetGADRequest();
   [self.bannerView loadRequest:request];

    NSLog(@"banner shit load");

}

- (id)addBannerViewToView:(UIView *)shit {

}

- (id)requestIDFA:(NSString*)BANNER {
  [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
    [self initWithID:BANNER];
  }];
}

- (id) showBanner :(NSString*) shit{
        NSLog(@"show banner 91");
    if(self.bannerView){
        self.bannerView.hidden = false;
        NSLog(@"show banner 94");
  
    }
}
- (id) hideBanner :(NSString*) shit{
    NSLog(@"hide banner 97");
    if(self.bannerView){
        NSLog(@"show banner 99");
        self.bannerView.hidden = true;
    }
}
 
- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
  NSLog(@"bannerViewDidReceiveAd");
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
  NSLog(@"bannerView:didFailToReceiveAdWithError: %@", [error localizedDescription]);

}

- (void)bannerViewDidRecordImpression:(GADBannerView *)bannerView {
  NSLog(@"bannerViewDidRecordImpression");
}

- (void)bannerViewWillPresentScreen:(GADBannerView *)bannerView {
  NSLog(@"bannerViewWillPresentScreen");
}

- (void)bannerViewWillDismissScreen:(GADBannerView *)bannerView {
  NSLog(@"bannerViewWillDismissScreen");
}

- (void)bannerViewDidDismissScreen:(GADBannerView *)bannerView {
  NSLog(@"bannerViewDidDismissScreen");
}
@end

@interface RewardListener : NSObject <ISRewardedVideoDelegate> {
}
@property(nonatomic, strong) GADRewardedAd *reward;
- (id)initWithID:(NSString*)ID;
- (id)show:(NSString*)shit;
- (bool)isReady;
- (id)requestIDFA:(NSString*)INTERSTITIAL;
- (id)initWithID:(NSString*)ID;
@end

@implementation RewardListener
- (id)initWithID:(NSString*)ID {

    self = [super init];
    if(!self) return nil;

    [IronSource setRewardedVideoDelegate:self];
    [ISIntegrationHelper validateIntegration];

    NSLog(@"IS Start Loading Reward");

    return self;

}

-(id)reInit: (NSString*)ID {
    self = [super init];
    if(!self) return nil;

    NSLog(@"IS reload reward");
    return self;

}


- (bool)isReady{
    NSLog(@"shit 192");

    if([IronSource hasRewardedVideo])
        return true;

    return false;
}

- (id)show:(NSString*) shit{
    NSLog(@"show reward shityeah 218");


        //create the view
        UIWindow* win =  [[UIApplication sharedApplication] keyWindow];
        UIViewController* vc = [win rootViewController];
        [IronSource showRewardedVideoWithViewController: vc];

}
- (id)requestIDFA:(NSString*)INTERSTITIAL {
    [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
    // Tracking authorization completed. Start loading ads here.
    [self initWithID: INTERSTITIAL];
    // [[InterstitialListener alloc] :interstitialID];
  }];
}


//Called after a rewarded video has changed its availability.
//@param available The new rewarded video availability. YES if available //and ready to be shown, NO otherwise.
- (void)rewardedVideoHasChangedAvailability:(BOOL)available {
     //Change the in-app 'Traffic Driver' state according to availability.
}
// Invoked when the user completed the video and should be rewarded.
// If using server-to-server callbacks you may ignore this events and wait *for the callback from the ironSource server.
//
// @param placementInfo An object that contains the placement's reward name and amount.
//
- (void)didReceiveRewardForPlacement:(ISPlacementInfo *)placementInfo {
}
//Called after a rewarded video has attempted to show but failed.
//@param error The reason for the error
- (void)rewardedVideoDidFailToShowWithError:(NSError *)error {
}
//Called after a rewarded video has been opened.
- (void)rewardedVideoDidOpen {
        reportInterstitialEvent(ADMOB_DISPLAYING);

}
//Called after a rewarded video has been dismissed.
- (void)rewardedVideoDidClose {   
    reportInterstitialEvent(ADMOB_CLOSED);
    reportInterstitialEvent(ADMOB_LEAVING);

}
//Invoked when the end user clicked on the RewardedVideo ad
- (void)didClickRewardedVideo:(ISPlacementInfo *)placementInfo{
}
//Note: the events DidStart & DidEnd below are not available for all supported rewarded video ad networks. Check which events are available per ad network you choose //to include in your build.
//We recommend only using events which register to ALL ad networks you //include in your build.
 //Called after a rewarded video has started playing.
- (void)rewardedVideoDidStart {
}
//Called after a rewarded video has finished playing.
- (void)rewardedVideoDidEnd 
{
}

@end


@interface InterstitialListener : NSObject <ISInterstitialDelegate> {}
@property(nonatomic, strong) GADInterstitialAd *interstitial;
- (id)initWithID:(NSString*)ID;
- (id)show:(NSString*)shit;
- (bool)isReady;
- (id)requestIDFA:(NSString*)INTERSTITIAL;
- (id)initWithID:(NSString*)ID;

@end

@implementation InterstitialListener
- (id)initWithID:(NSString*)ID {

    self = [super init];
    if(!self) return nil;

    [IronSource setInterstitialDelegate:self];
    [IronSource initWithAppKey: ID];
    [IronSource loadInterstitial];

    [ISIntegrationHelper validateIntegration];

    NSLog(@"IS Start Loading Interstitial");

    return self;
}

-(id)reInit: (NSString*)ID {
    self = [super init];
    if(!self) return nil;

    [IronSource loadInterstitial];

    NSLog(@"IS reload Interstitial");
    return self;

}


- (bool)isReady{
    NSLog(@"shit 192");

    if([IronSource hasInterstitial])
        return true;

    return false;
}

- (id)show:(NSString*) shit{
    NSLog(@"show interstitial shityeah 218");

    UIWindow* win =  [[UIApplication sharedApplication] keyWindow];
    UIViewController* vc = [win rootViewController];
    [IronSource showInterstitialWithViewController: vc];

}

-(void)interstitialDidLoad 
{

}

-(void)interstitialDidFailToShowWithError:(NSError *)error 
{
      NSLog(@"Failed to show interstitial ad with error: %@", [error localizedDescription]);

}

-(void)didClickInterstitial {


}
-(void)interstitialDidClose {
    reportInterstitialEvent(ADMOB_CLOSED);

    [IronSource loadInterstitial];

    NSLog(@"IS Interstitial closed!");
    NSLog(@"Request new Interstitial closed!");

}

-(void)interstitialDidOpen {
    reportInterstitialEvent(ADMOB_DISPLAYING);

}

//Invoked when there is no Interstitial Ad available after calling load //function. @param error - will contain the failure code and description.
-(void)interstitialDidFailToLoadWithError:(NSError *)error {
      NSLog(@"Failed to load interstitial ad with error: %@", [error localizedDescription]);

}

//Invoked right before the Interstitial screen is about to open. 
-(void)interstitialDidShow {
    NSLog(@"IS Interstitial loaded!");
}

- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad
didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    NSLog(@"Ad did fail to present full screen content.");
}

/// Tells the delegate that the ad presented full screen content.
- (void)adDidPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    NSLog(@"Ad did present full screen content.");
}

/// Tells the delegate that the ad dismissed full screen content.
- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
   NSLog(@"Ad did dismiss full screen content.");
}
- (id)requestIDFA:(NSString*)INTERSTITIAL {
    [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
    // Tracking authorization completed. Start loading ads here.
    [self initWithID: INTERSTITIAL];

    // [[InterstitialListener alloc] :interstitialID];
  }];
}
@end

namespace admobex {
	
    // static GADBannerView *bannerView;
	static InterstitialListener *interstitialListener;
    static RewardListener *rewardListener;

    static BannerViewListener *bannerViewListener;
    static bool bottom;

    static NSString *interstitialID;
    
	UIViewController *root;
    
	void init(const char *__BannerID, const char *__InterstitialID, const char *gravityMode, bool testingAds, bool tagForChildDirectedTreatment){

        root = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        // NSString *GMODE = [NSString stringWithUTF8String:gravityMode];
        // NSString *bannerID = [NSString stringWithUTF8String:__BannerID];
        interstitialID = [NSString stringWithUTF8String:__BannerID];
        _admobexChildDirected = tagForChildDirectedTreatment;
        NSLog(interstitialID);
       
        NSLog(@"init is babe!");

        [IronSource shouldTrackReachability:YES];

        interstitialListener = [InterstitialListener alloc];
        [interstitialListener  requestIDFA:interstitialID];

        rewardListener = [RewardListener alloc];
        [rewardListener  requestIDFA:interstitialID];


        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategorySoloAmbient error: nil];
        [[AVAudioSession sharedInstance] setActive: true error: nil];


        // [interstitialListener initWithID:interstitialID]; 
        //  [self initWithID:INTERSTITIAL];
        // bannerViewListener = [BannerViewListener alloc];
        // [bannerViewListener requestIDFA:bannerID];

    }
    
    bool showBanner(){

         if([IronSource hasRewardedVideo])
         {
             [rewardListener show:@"shit"];
              NSLog(@"show reward true ");
              return true;
          }
        else
            return false;

    }
    
    void hideBanner(){
       

    }
    
	void refreshBanner(){
        NSLog(@"refreshBanner 326");

         if(bannerViewListener==nil) return;

        // if(bannerViewListener.bannerView){
		// [bannerViewListener.bannerView loadRequest:_admobexGetGADRequest()];
        // }
        NSLog(@"refreshBanner 333");

	}

    bool showInterstitial(){
        NSLog(@"showInterstitial 328");

        if(interstitialListener==nil) {
            NSLog(@"interstitialListener nil");
            return false;
        }

        if(![interstitialListener isReady])
        {
            NSLog(@"interstitialListener not ready");
            return false;
        }

        NSLog(@"showInterstitial 384");
        [interstitialListener show:@"shit"];

        return true;
    }


}
