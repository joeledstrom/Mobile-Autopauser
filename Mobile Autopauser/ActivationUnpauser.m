//
//  ActivationUnpauser.m
//  Mobile Autopauser
//
//  Created by Joel Edström on 3/13/13.
//
//

#import "ActivationUnpauser.h"
#import "ProcessUtils.h"

@implementation ActivationUnpauser {
    AppPrefs* _prefs;
    NSDictionary* _cachedAppPrefs;
    AppPref* _unpausedApp;
}

- (id)init
{
    self = [super init];
    if (self) {
        _prefs = [AppPrefs new];
        _prefs.delegate = self;
        [self filterAndCachePrefs:[_prefs getAllAppPrefs]];
        
        [[NSWorkspace sharedWorkspace].notificationCenter
         addObserver:self
            selector:@selector(activatedApp:)
                name:NSWorkspaceDidActivateApplicationNotification
              object:nil];
    }
    return self;
}

- (void)activatedApp:(NSNotification*)n {
    
    if (_unpausedApp) {
        pauseProcess(_unpausedApp.bundleId);
        _unpausedApp = nil;
    }
    
    NSRunningApplication* a = n.userInfo[NSWorkspaceApplicationKey];
    AppPref* pausedApp = _cachedAppPrefs[a.bundleIdentifier];
    
    if (pausedApp) {
        unpauseProcess(pausedApp.bundleId);
        _unpausedApp = pausedApp;
    }
    
    
}

- (void)filterAndCachePrefs:(NSArray*)prefs {
    NSMutableDictionary* d = [NSMutableDictionary new];
    [prefs enumerateObjectsUsingBlock:^(AppPref* a, NSUInteger idx, BOOL *stop) {
        if (a.mode == APP_MODE_PAUSE)
            d[a.bundleId] = a;
    }];
    
    _cachedAppPrefs = [d copy];
}

- (void)appPrefsChangedTo:(NSArray*)prefs {
    [self filterAndCachePrefs:prefs];
}

- (void)dealloc {
    [[NSWorkspace sharedWorkspace].notificationCenter removeObserver:self];
}
@end
