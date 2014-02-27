//
//  NetworkChecker.h
//  Scenery
//
//  Created by Nai Chng on 25/2/14.
//  Copyright (c) 2014 NYC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface NetworkChecker : NSObject

+ (BOOL)hasConnectivity;
+ (void)showNetworkMessage:(NSString *)message title:(NSString *)title delegate:(id)sender;

@end
