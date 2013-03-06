//
//  AppDelegate.m
//  Dropbox Autopause
//
//  Created by Joel Edström on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "PrefsWindowController.h"


@interface AppDelegate()
@property (strong, nonatomic) PowerSourceStatus* powerStatus;
@property (strong, nonatomic) NSStatusItem* statusItem;
@property (strong, nonatomic) NSWindowController* windowController;
@property (strong, nonatomic) AppPrefs* prefs;
@end

static NSMenuItem* makeMenuItem(NSString* title, SEL sel, id target) {
    NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:title action:sel keyEquivalent:@""];
    [item setTarget:target];
    
    return item;
}

static void terminateProcess(NSString *bundleId) {
    NSArray* runningApps = [NSRunningApplication runningApplicationsWithBundleIdentifier:bundleId];
    for (NSRunningApplication* app in runningApps)
        [app terminate];
}

static void pauseProcess(NSString *bundleId) {
    NSArray* runningApps = [NSRunningApplication runningApplicationsWithBundleIdentifier:bundleId];
    for (NSRunningApplication* app in runningApps) {
        
        NSString* cmd = [NSString stringWithFormat:@"/bin/kill -STOP %d", app.processIdentifier];
        system(cmd.UTF8String);
    }
}

static void unpauseProcess(NSString *bundleId) {
    NSArray* runningApps = [NSRunningApplication runningApplicationsWithBundleIdentifier:bundleId];
    for (NSRunningApplication* app in runningApps) {
        
        NSString* cmd = [NSString stringWithFormat:@"/bin/kill -CONT %d", app.processIdentifier];
        system(cmd.UTF8String);
    }
}

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification*)aNotification
{
    self.powerStatus = [PowerSourceStatus new];
    self.powerStatus.delegate = self;
    
    self.prefs = [AppPrefs new];
    self.prefs.delegate = self;
    
    self.statusItem = [[NSStatusBar systemStatusBar]
                       statusItemWithLength:NSSquareStatusItemLength];
    
    NSImage* img = [NSImage imageNamed:@"ugly.png"];
    img.size = NSMakeSize(22, 22);
    img.template = YES;
    self.statusItem.image = img;
    self.statusItem.highlightMode = YES;
    
    [self buildStatusMenu];
    
}

- (void)openPrefs {
    if (!self.windowController)
        self.windowController = [[PrefsWindowController alloc] initWithWindowNibName:@"Prefs"];

    [self.windowController showWindow:self];
}

- (void)buildStatusMenu {
    NSMenu* menu = [[NSMenu alloc] initWithTitle:@""];
    NSDictionary* appPrefs = [self.prefs getAllAppPrefs];
    
    for (NSString* bundleId in appPrefs.keyEnumerator) {
        
        NSNumber* m = appPrefs[bundleId][APP_MODE];
        NSString* mode = m == nil || m.integerValue == APP_MODE_TERMINATE
                       ? @"TERMINATE"
                       : @"PAUSE";
        
        NSString* title =
            [NSString stringWithFormat:@"%@ [%@]", bundleId, mode];
        
        NSMenuItem* i = makeMenuItem(title, @selector(appInMenuClicked:), self);
        
        NSNumber* tempPause = appPrefs[bundleId][APP_TEMP_PAUSE];
        i.state = tempPause == nil || tempPause.boolValue == NO ? 1 : 0;
        
        [menu addItem: i];
    }
    
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItem:makeMenuItem(@"Preferences...", @selector(openPrefs), self)];
    [menu addItem:makeMenuItem(@"Quit", @selector(terminate:), NSApp)];
    
    self.statusItem.menu = menu;
}

- (void)appInMenuClicked:(id)sender {
    NSString* bundleId = [[sender title] componentsSeparatedByString:@" "][0];
    
    [self.prefs toggleTemporaryPauseForBundleId:bundleId];
    
    // bit of a hack
    [self connectedToCharger];
    [self disconnectedFromCharger];
    [self.powerStatus poll];
}

#pragma mark - PowerSourceStatusDelegate

- (void)connectedToCharger {
    
    NSWorkspace* ws = [NSWorkspace sharedWorkspace];
    
    NSDictionary* appPrefs = [self.prefs getAllAppPrefs];
    
    for (NSString* bundleId in appPrefs.keyEnumerator) {
                                        
        [ws launchAppWithBundleIdentifier:bundleId
                                  options:NSWorkspaceLaunchDefault| NSWorkspaceLaunchWithoutActivation
           additionalEventParamDescriptor:nil
                         launchIdentifier:nil];
        
        unpauseProcess(bundleId);
    }
    
    
}
- (void)disconnectedFromCharger {
    
    NSDictionary* appPrefs = [self.prefs getAllAppPrefs];
    
    
    for (NSString* bundleId in appPrefs.keyEnumerator) {
        NSNumber* m = appPrefs[bundleId][APP_MODE];
        BOOL term = m == nil || m.integerValue == APP_MODE_TERMINATE ? YES : NO;
        NSNumber* t = appPrefs[bundleId][APP_TEMP_PAUSE];
        BOOL tempPause = t == nil || t.boolValue == NO ? 0 : 1;
        
        if (term && !tempPause)
            terminateProcess(bundleId);
        else if (!term && !tempPause)
            pauseProcess(bundleId);
        
    }
    
}

#pragma mark - AppPrefsDelegate

- (void)appPrefsChangedTo:(NSDictionary*)prefs {
    [self buildStatusMenu];
}

@end
