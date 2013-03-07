//
//  AppPrefs.m
//  Dropbox Autopause
//
//  Created by Joel Edström on 3/6/13.
//
//

#import "AppPrefs.h"

@implementation AppPref
- (id)init
{
    self = [super init];
    if (self) {
        self.mode = APP_MODE_NO_ACTION;
        self.tempPaused = NO;
    }
    return self;
}
- (AppPref*)toggleTemporaryPause {
    self.tempPaused = self.tempPaused ? NO : YES;
    return self;
}
@end

typedef BOOL (^usePrefsFunc)(NSMutableDictionary* appPrefs);


@implementation AppPrefs

static NSString* const APP_MODE = @"mode";
static NSString* const APP_TEMP_PAUSE = @"tempPause";
static NSString* const PREF_KEY = @"appPrefs";



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


- (void)usePrefsWith:(usePrefsFunc)func {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* appPrefs = [[userDefaults objectForKey:PREF_KEY] mutableCopy];
    
    if (!appPrefs)
        appPrefs = [NSMutableDictionary new];
    
    BOOL changed = func(appPrefs);
        
    if (changed)
       [userDefaults setObject:appPrefs forKey:PREF_KEY];
}

- (void)setObject:(AppPref*)pref forKeyedSubscript:(NSString*)bundleId {
    

    [self usePrefsWith:^(NSMutableDictionary* appPrefs) {
        assert([pref.bundleId isEqual:bundleId]);
        appPrefs[bundleId] = @{APP_MODE: @(pref.mode), APP_TEMP_PAUSE: @(pref.tempPaused)};
        return YES;
    }];
}

- (AppPref*)objectForKeyedSubscript:(NSString*)bundleId {
    AppPref* pref = [AppPref new];
    [self usePrefsWith:^(NSMutableDictionary* appPrefs) {
        NSDictionary* d = appPrefs[bundleId];
        
        pref.mode = [d[APP_MODE] integerValue];
        pref.tempPaused = [d[APP_TEMP_PAUSE] boolValue];
        pref.bundleId = bundleId;

        return NO;
    }];
   
    return pref;
}


- (NSArray*)getAllAppPrefs {
    NSMutableArray* prefs = [NSMutableArray new];
    [self usePrefsWith:^BOOL(NSMutableDictionary* appPrefs) {
        
        for (NSString* bundleId in appPrefs)
            [prefs addObject:self[bundleId]];
        
        return NO;
    }];
             
    return [prefs copy];
}

- (void)sendToDelegate:(NSArray*)prefs {
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
