//
//  AppDelegate.m
//  Dropbox Autopause
//
//  Created by Joel Edström on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"


static NSString* DROPBOX_ID = @"com.getdropbox.dropbox";


@interface AppDelegate()
@property (strong, nonatomic) PowerSourceStatus* powerStatus;
@end

@implementation AppDelegate

- (void)connectedToCharger {
    NSLog(@"connected");
    
    NSWorkspace* ws = [NSWorkspace sharedWorkspace];
    
    [ws launchAppWithBundleIdentifier:DROPBOX_ID
                              options:NSWorkspaceLaunchDefault | NSWorkspaceLaunchWithoutActivation
       additionalEventParamDescriptor:nil
                     launchIdentifier:nil];
    
}
- (void)disconnectedFromCharger {
    NSLog(@"disconnected");
    
    NSArray* runningApps = [[NSWorkspace sharedWorkspace] runningApplications];
    
    for (NSRunningApplication* app in runningApps) {
        if ([app.bundleIdentifier isEqual:DROPBOX_ID]) {
            [app terminate];
        }
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.powerStatus = [PowerSourceStatus new];
    self.powerStatus.delegate = self;
    
}

@end
