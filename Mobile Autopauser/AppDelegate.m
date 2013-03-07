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


static void startAndUnpauseProcess(NSString* bundleId) {
    NSWorkspace* ws = [NSWorkspace sharedWorkspace];
    
    [ws launchAppWithBundleIdentifier:bundleId
                              options:NSWorkspaceLaunchDefault| NSWorkspaceLaunchWithoutActivation
       additionalEventParamDescriptor:nil
                     launchIdentifier:nil];
    
    
    NSArray* runningApps = [NSRunningApplication runningApplicationsWithBundleIdentifier:bundleId];
    for (NSRunningApplication* app in runningApps) {
        
        NSString* cmd = [NSString stringWithFormat:@"/bin/kill -CONT %d", app.processIdentifier];
        system(cmd.UTF8String);
    }
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
    [self powerStatusChanged];
    
}

- (void)openPrefs {
    if (!self.windowController)
        self.windowController = [[PrefsWindowController alloc] initWithWindowNibName:@"Prefs"];

    [self.windowController showWindow:self];
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)buildStatusMenu {
    NSMenu* menu = [[NSMenu alloc] initWithTitle:@""];
    NSArray* appPrefs = [self.prefs getAllAppPrefs];
    
    for (AppPref* app in appPrefs) {
        
        if (app.mode != APP_MODE_NO_ACTION) {
            NSString* m = app.mode == APP_MODE_TERMINATE ? @"TERMINATE" : @"PAUSE";
            NSString* title = [NSString stringWithFormat:@"%@ [%@]", app.bundleId, m];
            NSMenuItem* i = makeMenuItem(title, @selector(appInMenuClicked:), self);
            i.state = !app.tempPaused;
            
            [menu addItem: i];
        }
    }
    
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItem:makeMenuItem(@"Preferences...", @selector(openPrefs), self)];
    [menu addItem:makeMenuItem(@"Quit", @selector(terminate:), NSApp)];
    
    self.statusItem.menu = menu;
}

- (void)appInMenuClicked:(id)sender {
    NSString* bundleId = [[sender title] componentsSeparatedByString:@" "][0];
    
    self.prefs[bundleId] = [self.prefs[bundleId] toggleTemporaryPause];
    
    [self powerStatusChanged];
}

#pragma mark - PowerSourceStatusDelegate

- (void)powerStatusChanged {
    
    NSArray* appPrefs = [self.prefs getAllAppPrefs];
    PowerStatus ps = self.powerStatus.powerStatus;
        
    for (AppPref* app in appPrefs) {
        
        if (ps == POWER_STATUS_CONNECTED && app.mode != APP_MODE_NO_ACTION)
            startAndUnpauseProcess(app.bundleId);
        
        
        if (ps == POWER_STATUS_DISCONNECTED) {
            
            if (app.mode != APP_MODE_NO_ACTION && app.tempPaused)
                startAndUnpauseProcess(app.bundleId);
           
            if (app.mode == APP_MODE_TERMINATE && !app.tempPaused)
                terminateProcess(app.bundleId);
            
            if (app.mode == APP_MODE_PAUSE && !app.tempPaused)
                pauseProcess(app.bundleId);
        }
    }
}

#pragma mark - AppPrefsDelegate

- (void)appPrefsChangedTo:(NSDictionary*)prefs {
    [self buildStatusMenu];
}

@end
