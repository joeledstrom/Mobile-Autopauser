//
//  PrefsWindowController.m
//  Dropbox Autopause
//
//  Created by Joel Edström on 3/5/13.
//
//

#import "PrefsWindowController.h"
#import "PrefsCellView.h"


@interface PrefsWindowController ()

@end

@implementation PrefsWindowController

NSArray* _runningApps;
AppPrefs* _prefs;
NSDictionary* _cachedAppPrefs;


- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.window makeKeyAndOrderFront:nil];
    
    NSArray* apps = [[NSWorkspace sharedWorkspace] runningApplications];
    NSMutableArray* filteredApps = [NSMutableArray array];
    for (NSRunningApplication* app in apps) {
        if (app.bundleIdentifier != nil &&
            ![app.bundleIdentifier isEqualTo:[NSRunningApplication currentApplication].bundleIdentifier]) {
            
            [filteredApps addObject:app];
        }
    }
    
    
    _runningApps = [NSArray arrayWithArray:filteredApps];
    _prefs = [AppPrefs new];
    _prefs.delegate = self;
    _cachedAppPrefs = [_prefs getAllAppPrefs];
    [self.tableView reloadData];
}


#pragma mark - AppPrefsDelegate
- (void)appPrefsChangedTo:(NSDictionary*)prefs {
    _cachedAppPrefs = prefs;
    [self.tableView reloadData];
}



#pragma mark - NSTableViewDelegate and NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [_runningApps count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    PrefsCellView* v = [tableView makeViewWithIdentifier:@"appCell" owner:self];
    NSRunningApplication* app = _runningApps[row];
    v.imageView.image = app.icon;
    v.textField.stringValue = app.localizedName;
    
    NSDictionary* pref = _cachedAppPrefs[app.bundleIdentifier];
    
    if (!pref)
        v.segmentedControl.selectedSegment = 0;
    else if ([pref[APP_MODE] isEqualTo:@(APP_MODE_TERMINATE)])
        v.segmentedControl.selectedSegment = 1;
    else
        v.segmentedControl.selectedSegment = 2;
    
    [v.segmentedControl setTarget:self];
    [v.segmentedControl setAction:@selector(clickHandler:)];
    [v.segmentedControl setTag:row];
    return v;
}

- (void)clickHandler:(NSControl*)sender {
    NSSegmentedControl* segControl = (NSSegmentedControl*)sender;
    NSRunningApplication* app = _runningApps[sender.tag];
    
    switch (segControl.selectedSegment) {
        case 0:
            [_prefs removeBundleId:app.bundleIdentifier];
            break;
        case 1:
            [_prefs switchToTerminateForBundleId:app.bundleIdentifier];
            break;
        case 2:
            [_prefs switchToPauseForBundleId:app.bundleIdentifier];
            break;
    }
}


@end
