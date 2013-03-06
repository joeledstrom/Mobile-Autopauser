//
//  ApplicationViewCell.h
//  Dropbox Autopause
//
//  Created by Joel Edström on 3/5/13.
//
//

#import <Cocoa/Cocoa.h>

@interface PrefsCellView : NSTableCellView
@property (nonatomic, weak) IBOutlet NSSegmentedControl* segmentedControl;
@end
