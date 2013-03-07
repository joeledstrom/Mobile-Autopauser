//
//  PrefsWindowController.m
//  Dropbox Autopause
//
//  Created by Joel Edström on 3/5/13.
//
//

#import "PrefsWindowController.h"
#import "PrefsCellView.h"


@implementation PrefsWindowController

AppPrefs* _prefs;
NSArray* _cachedAppPrefs;
NSMutableDictionary* _iconCache;


- (void)populatePrefsWithApps {
    NSArray* apps = [[NSWorkspace sharedWorkspace] runningApplications];
    for (NSRunningApplication* app in apps) {
        if (app.bundleIdentifier != nil &&
            ![app.bundleIdentifier isEqual:[NSRunningApplication currentApplication].bundleIdentifier]) {
            
            if (!_prefs[app.bundleIdentifier]) {
                AppPref* pref = [AppPref new];
                pref.bundleId = app.bundleIdentifier;
                _prefs[app.bundleIdentifier] = pref;
            }
        }
    }
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.window makeKeyAndOrderFront:nil];
    
    _prefs = [AppPrefs new];
    _prefs.delegate = self;
    
    [self populatePrefsWithApps];
    _cachedAppPrefs = [_prefs getAllAppPrefs];
    [self.tableView reloadData];
}

- (void)windowWillClose:(NSNotification *)notification {
    _iconCache = nil;
}

- (NSImage*)getIconForBundleId:(NSString*)bundleId {
    if (!_iconCache)
        _iconCache = [NSMutableDictionary new];
    
    if (_iconCache[bundleId])
        return _iconCache[bundleId];
    
    NSWorkspace* ws = [NSWorkspace sharedWorkspace];
    NSURL* url = [ws URLForApplicationWithBundleIdentifier:bundleId];
    
    if (url.path == nil) return nil;
    
    NSImage* icon = [ws iconForFile:url.path];
    
    if (icon)
        _iconCache[bundleId] = icon;
    
    return icon;
}

- (void)clickHandler:(NSControl*)sender {
    NSSegmentedControl* segControl = (NSSegmentedControl*)sender;
    NSString* bundleId = [_cachedAppPrefs[sender.tag] bundleId];
    
    AppPref* pref = _prefs[bundleId];
    pref.mode = segControl.selectedSegment;
    _prefs[bundleId] = pref;
}

#pragma mark - AppPrefsDelegate
- (void)appPrefsChangedTo:(NSArray*)prefs {
    _cachedAppPrefs = prefs;
    [self.tableView reloadData];
}



#pragma mark - NSTableViewDelegate and NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [_cachedAppPrefs count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    PrefsCellView* v = [tableView makeViewWithIdentifier:@"appCell" owner:self];
    AppPref* app = _cachedAppPrefs[row];
    
    v.imageView.image = [self getIconForBundleId:app.bundleId];
    v.textField.stringValue = app.bundleId;
    v.segmentedControl.selectedSegment = app.mode;
       
    [v.segmentedControl setTarget:self];
    [v.segmentedControl setAction:@selector(clickHandler:)];
    [v.segmentedControl setTag:row];
    return v;
}


@end
