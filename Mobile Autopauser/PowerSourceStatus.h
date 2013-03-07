//
//  PowerStatus.h
//  Dropbox Autopause
//
//  Created by Joel Edström on 3/5/13.
//
//

#import <Foundation/Foundation.h>


typedef enum {
    POWER_STATUS_CONNECTED,
    POWER_STATUS_DISCONNECTED
} PowerStatus;

@protocol PowerSourceStatusDelegate <NSObject>
- (void)powerStatusChanged;
@end

@interface PowerSourceStatus : NSObject
@property PowerStatus powerStatus;
@property (weak, nonatomic) id<PowerSourceStatusDelegate> delegate;
@end
