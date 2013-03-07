//
//  PowerStatus.m
//  Dropbox Autopause
//
//  Created by Joel Edström on 3/5/13.
//
//

#import "PowerSourceStatus.h"
#import <IOKit/ps/IOPowerSources.h>


@interface PowerSourceStatus()
- (void)chargerStatusNotification:(PowerStatus)connected;
@end

void onPowerSourceChanged(void* context) {
    
    PowerSourceStatus* self = (__bridge PowerSourceStatus*)context;
    
    NSDictionary* chargerDetails = CFBridgingRelease(IOPSCopyExternalPowerAdapterDetails());
    
    if (chargerDetails) {
        [self chargerStatusNotification:POWER_STATUS_CONNECTED];
    } else {
        [self chargerStatusNotification:POWER_STATUS_DISCONNECTED];
    }
}


@implementation PowerSourceStatus

CFRunLoopSourceRef _runLoopSrc;

- (id)init {
    self = [super init];
    if (self) {
        _runLoopSrc = IOPSNotificationCreateRunLoopSource(onPowerSourceChanged, (__bridge void*)self);
        CFRunLoopAddSource(CFRunLoopGetMain(), _runLoopSrc, kCFRunLoopDefaultMode);
        
        onPowerSourceChanged((__bridge void*)self);
    }
        
    return self;
}

- (void)chargerStatusNotification:(PowerStatus)newStatus {
    PowerStatus oldStatus = self.powerStatus;
    
    self.powerStatus = newStatus;
    
    if (oldStatus != newStatus) {
        [self notifyDelegate];
    }
}

- (void)notifyDelegate {
    if ([self.delegate conformsToProtocol:@protocol(PowerSourceStatusDelegate)])
        [self.delegate powerStatusChanged];
}

- (void)dealloc {
    CFRunLoopRemoveSource(CFRunLoopGetMain(), _runLoopSrc, kCFRunLoopDefaultMode);
    CFRelease(_runLoopSrc);
}
@end
