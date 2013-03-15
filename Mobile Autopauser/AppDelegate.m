//
//  AppDelegate.m
//  Dropbox Autopause
//
//  Created by Joel Edström on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "PrefsWindowController.h"
#import "ProcessUtils.h"
#import "ActivationUnpauser.h"


@interface AppDelegate()
@property (strong, nonatomic) PowerSourceStatus* powerStatus;
@property (strong, nonatomic) NSStatusItem* statusItem;
@property (strong, nonatomic) NSWindowController* windowController;
@property (strong, nonatomic) AppPrefs* prefs;
@property (strong, nonatomic) ActivationUnpauser* activationUnpauser;
@end

static NSMenuItem* makeMenuItem(NSString* title, SEL sel, id target) {
    NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:title action:sel keyEquivalent:@""];
    [item setTarget:target];
    
    return item;
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
        
        if (ps == POWER_STATUS_CONNECTED && app.mode != APP_MODE_NO_ACTION) {
            startProcess(app.bundleId);
            unpauseProcess(app.bundleId);
        }
        
        if (ps == POWER_STATUS_DISCONNECTED) {
            
            if (app.mode != APP_MODE_NO_ACTION && app.tempPaused) {
                startProcess(app.bundleId);
                unpauseProcess(app.bundleId);
            }
           
            if (app.mode == APP_MODE_TERMINATE && !app.tempPaused)
                terminateProcess(app.bundleId);
            
            if (app.mode == APP_MODE_PAUSE && !app.tempPaused)
                pauseProcess(app.bundleId);
        }
    }
    
    if (ps == POWER_STATUS_DISCONNECTED) {
        self.activationUnpauser = [ActivationUnpauser new];
    } else {
        self.activationUnpauser = nil;
    }
}

#pragma mark - AppPrefsDelegate

- (void)appPrefsChangedTo:(NSDictionary*)prefs {
    [self buildStatusMenu];
}

@end
