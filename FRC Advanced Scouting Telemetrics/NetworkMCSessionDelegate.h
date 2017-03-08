//
//  NSObject+ObjCMCSessionDelegate.h
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 3/7/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
@class NetworkMCSessionTranslator;

@interface NetworkMCSessionDelegate : NSObject <MCSessionDelegate>
-(instancetype)initWithTranslator:(NetworkMCSessionTranslator*) trans;
@end
