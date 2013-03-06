//
//  AppPrefs.m
//  Dropbox Autopause
//
//  Created by Joel Edström on 3/6/13.
//
//

#import "AppPrefs.h"

typedef NSDictionary* (^prefChangeFunc)(NSMutableDictionary* pref);



@implementation AppPrefs

NSString* const APP_MODE = @"mode";
NSString* const APP_TEMP_PAUSE = @"tempPause";
NSString* const KEY = @"appPrefs";

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(updated)
                name:NSUserDefaultsDidChangeNotification object:nil];
    }
    return self;
}

- (void)removeBundleId:(NSString*)bundleId {
    [self change:bundleId to:^(NSMutableDictionary* pref) {
        return (NSDictionary*)nil;
    }];
}
- (void)switchToTerminateForBundleId:(NSString*)bundleId {
    [self change:bundleId to:^(NSMutableDictionary* pref) {
        pref[APP_MODE] = @(APP_MODE_TERMINATE);
        return pref;
    }];
}
- (void)switchToPauseForBundleId:(NSString*)bundleId {
    [self change:bundleId to:^(NSMutableDictionary* pref) {
        pref[APP_MODE] = @(APP_MODE_PAUSE);
        return pref;
    }];
}
- (void)toggleTemporaryPauseForBundleId:(NSString*)bundleId {
    [self change:bundleId to:^(NSMutableDictionary* pref) {
        NSNumber* last = pref[APP_TEMP_PAUSE];
        pref[APP_TEMP_PAUSE] = @(last.boolValue == YES ? NO : YES);
        
        return pref;
    }];
}
- (NSDictionary*)getAllAppPrefs {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:KEY];
}
// appPrefs = {bundleId: {terminateMode: 0, tempPause = TRUE}} 

- (void)change:(NSString*)bundleId to:(prefChangeFunc)func {
    
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* appPrefs = [userDefaults objectForKey:KEY];
    
    if (!appPrefs)
        appPrefs = @{};
    
    
    NSDictionary* pref = ((NSDictionary*)appPrefs[bundleId]);
    
    if (!pref)
        pref = @{APP_MODE: @(APP_MODE_TERMINATE), APP_TEMP_PAUSE: @(NO)};
    
    
    NSMutableDictionary* mutablePref = [NSMutableDictionary dictionaryWithDictionary:pref];
    NSDictionary* changedPref = func(mutablePref);
    NSMutableDictionary* changedAppPrefs =
    [NSMutableDictionary dictionaryWithDictionary:appPrefs];
    
    if (changedPref)
        changedAppPrefs[bundleId] = changedPref;
    else
        [changedAppPrefs removeObjectForKey:bundleId];
    
    
    if (![changedAppPrefs isEqualToDictionary:appPrefs]) {
        [userDefaults setObject:changedAppPrefs forKey:KEY];
        
        //[userDefaults synchronize];  // TODO: research: necessary?
                
        [self sendToDelegate:[NSDictionary dictionaryWithDictionary:changedAppPrefs]];
        
    }
    
}

- (void)sendToDelegate:(NSDictionary*)prefs {
    if ([self.delegate conformsToProtocol:@protocol(AppPrefsDelegate)])
        [self.delegate appPrefsChangedTo:prefs];
        
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - NSUserDefaultsDidChangeNotification
- (void)updated {
    [self sendToDelegate:[self getAllAppPrefs]];
}
@end
