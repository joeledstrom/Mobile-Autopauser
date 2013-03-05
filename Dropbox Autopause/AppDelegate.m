//
//  AppDelegate.m
//  Dropbox Autopause
//
//  Created by Joel Edström on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import <IOKit/ps/IOPowerSources.h>


static const NSString* DROPBOX_ID = @"com.getdropbox.dropbox";

void onPowerSourceChanged(void *context) {    
    
    NSDictionary *chargerDetails = CFBridgingRelease(IOPSCopyExternalPowerAdapterDetails());
    
      
    //NSLog(@"onPowerSourceChanged: %s", chargerDetails ? "charger" : "battery");
    
    if (chargerDetails) {
        [[NSWorkspace sharedWorkspace] launchAppWithBundleIdentifier:(NSString*)DROPBOX_ID options:NSWorkspaceLaunchDefault | NSWorkspaceLaunchWithoutActivation additionalEventParamDescriptor:nil launchIdentifier:nil];
    } else {
        
        NSArray *runningApps = [[NSWorkspace sharedWorkspace] runningApplications];
        
        for (NSRunningApplication* app in runningApps) {
            if ([app.bundleIdentifier isEqual:DROPBOX_ID]) {
                [app terminate];
            }
        }
    }
    
    
}



@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    CFRunLoopSourceRef runLoopSrc = IOPSNotificationCreateRunLoopSource(onPowerSourceChanged, nil);
    
    CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSrc, kCFRunLoopDefaultMode);
    
    CFRelease(runLoopSrc);
    
    
}

@end
