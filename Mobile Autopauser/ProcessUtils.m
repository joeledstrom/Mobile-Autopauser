//
//  ProcessUtils.m
//  Mobile Autopauser
//
//  Created by Joel Edström on 3/13/13.
//
//

#import "ProcessUtils.h"


void startProcess(NSString* bundleId) {
    NSWorkspace* ws = [NSWorkspace sharedWorkspace];
    
    [ws launchAppWithBundleIdentifier:bundleId
                              options:NSWorkspaceLaunchDefault| NSWorkspaceLaunchWithoutActivation
       additionalEventParamDescriptor:nil
                     launchIdentifier:nil];
}

void terminateProcess(NSString *bundleId) {
    NSArray* runningApps = [NSRunningApplication runningApplicationsWithBundleIdentifier:bundleId];
    for (NSRunningApplication* app in runningApps)
        [app terminate];
}

void pauseProcess(NSString *bundleId) {
    NSArray* runningApps = [NSRunningApplication runningApplicationsWithBundleIdentifier:bundleId];
    for (NSRunningApplication* app in runningApps) {
        
        NSString* cmd = [NSString stringWithFormat:@"/bin/kill -STOP %d", app.processIdentifier];
        system(cmd.UTF8String);
    }
}

void unpauseProcess(NSString* bundleId) {
    NSArray* runningApps = [NSRunningApplication runningApplicationsWithBundleIdentifier:bundleId];
    for (NSRunningApplication* app in runningApps) {
        
        NSString* cmd = [NSString stringWithFormat:@"/bin/kill -CONT %d", app.processIdentifier];
        system(cmd.UTF8String);
    }
}
