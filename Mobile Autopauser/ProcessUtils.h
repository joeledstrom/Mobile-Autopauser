//
//  ProcessUtils.h
//  Mobile Autopauser
//
//  Created by Joel Edström on 3/13/13.
//
//

#import <Foundation/Foundation.h>


void startProcess(NSString* bundleId);
void terminateProcess(NSString *bundleId);
void pauseProcess(NSString *bundleId);
void unpauseProcess(NSString* bundleId);