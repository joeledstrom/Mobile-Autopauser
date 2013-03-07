//
//  AppPrefs.h
//  Dropbox Autopause
//
//  Created by Joel Edström on 3/6/13.
//
//

#import <Foundation/Foundation.h>




typedef enum {
    APP_MODE_NO_ACTION,
    APP_MODE_TERMINATE,
    APP_MODE_PAUSE
} AppMode;

@interface AppPref : NSObject
@property NSString* bundleId;
@property AppMode   mode;
@property BOOL      tempPaused;
- (AppPref*)toggleTemporaryPause;
@end


@protocol AppPrefsDelegate <NSObject>
- (void)appPrefsChangedTo:(NSArray*)prefs;
@end

@interface AppPrefs : NSObject
- (NSArray*)getAllAppPrefs;

// use subscripting syntax
- (void)setObject:(AppPref*)pref forKeyedSubscript:(NSString*)bundleId;
- (AppPref*)objectForKeyedSubscript:(NSString*)bundleId;

@property (weak) id<AppPrefsDelegate> delegate;

@end
