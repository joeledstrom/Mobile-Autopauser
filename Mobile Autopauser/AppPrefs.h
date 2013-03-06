//
//  AppPrefs.h
//  Dropbox Autopause
//
//  Created by Joel Edström on 3/6/13.
//
//

#import <Foundation/Foundation.h>


enum {
    APP_MODE_TERMINATE,
    APP_MODE_PAUSE
};

extern NSString* const APP_MODE;
extern NSString* const APP_TEMP_PAUSE;

@protocol AppPrefsDelegate <NSObject>
- (void)appPrefsChangedTo:(NSDictionary*)prefs;
@end

@interface NSDictionary()

@end

@interface AppPrefs : NSObject
- (void)removeBundleId:(NSString*)bundleId;
- (void)switchToTerminateForBundleId:(NSString*)bundleId;
- (void)switchToPauseForBundleId:(NSString*)bundleId;
- (void)toggleTemporaryPauseForBundleId:(NSString*)bundleId;
- (NSDictionary*)getAllAppPrefs;

@property (weak, nonatomic) id<AppPrefsDelegate> delegate;

@end
