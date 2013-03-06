//
//  PowerStatus.h
//  Dropbox Autopause
//
//  Created by Joel Edström on 3/5/13.
//
//

#import <Foundation/Foundation.h>

@protocol PowerSourceStatusDelegate <NSObject>
- (void)connectedToCharger;
- (void)disconnectedFromCharger;
@end

@interface PowerSourceStatus : NSObject
- (void)poll;
@property (weak, nonatomic) id<PowerSourceStatusDelegate> delegate;
@end
