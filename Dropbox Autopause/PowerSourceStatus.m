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
- (void)chargerStatusNotification:(BOOL)connected;
@end

void onPowerSourceChanged(void* context) {
    
    PowerSourceStatus* self = (__bridge PowerSourceStatus*)context;
    
    NSDictionary* chargerDetails = CFBridgingRelease(IOPSCopyExternalPowerAdapterDetails());
    
    if (chargerDetails) {
        [self chargerStatusNotification:YES];
    } else {
        [self chargerStatusNotification:NO];
    }
}


@implementation PowerSourceStatus

CFRunLoopSourceRef _runLoopSrc;
bool _previouslyConnected;
bool _previouslyConnectedValid;

- (id)init {
    self = [super init];
    if (self) {
        _runLoopSrc = IOPSNotificationCreateRunLoopSource(onPowerSourceChanged, (__bridge void*)self);
        CFRunLoopAddSource(CFRunLoopGetMain(), _runLoopSrc, kCFRunLoopDefaultMode);
        
        // after the current runloop iteration, send initial state to delegate
        dispatch_async(dispatch_get_main_queue(), ^{
            onPowerSourceChanged((__bridge void*)self);
        });
    }
        
    return self;
}
- (void)chargerStatusNotification:(BOOL)connected {
    if (!_previouslyConnectedValid || _previouslyConnected != connected) {
        [self sendToDelegate:connected];
    }
    
    _previouslyConnected = connected;
    _previouslyConnectedValid = YES;
}

- (void)sendToDelegate:(BOOL)connected {
    if (connected && [self.delegate conformsToProtocol:@protocol(PowerSourceStatusDelegate)])
        [self.delegate connectedToCharger];
    else
        [self.delegate disconnectedFromCharger];
    
}

- (void)dealloc {
    CFRunLoopRemoveSource(CFRunLoopGetMain(), _runLoopSrc, kCFRunLoopDefaultMode);
    CFRelease(_runLoopSrc);
}
@end
