//
//  AppDelegate.h
//  Dropbox Autopause
//
//  Created by Joel Edström on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PowerSourceStatus.h"
#import "AppPrefs.h"

@interface AppDelegate : NSObject
    <NSApplicationDelegate, PowerSourceStatusDelegate, AppPrefsDelegate>
@end
