//
//  PrefsWindowController.h
//  Dropbox Autopause
//
//  Created by Joel Edström on 3/5/13.
//
//

#import <Cocoa/Cocoa.h>
#import "AppPrefs.h"


@interface PrefsWindowController : NSWindowController
    <NSTableViewDataSource, NSTableViewDelegate, AppPrefsDelegate>
@property (nonatomic, weak) IBOutlet NSTableView* tableView;
@end
