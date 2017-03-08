//
//  NSObject+ObjCMCSessionDelegate.m
//  FRC Advanced Scouting Touchstone
//
//  Created by Aaron Kampmeier on 3/7/17.
//  Copyright © 2017 Kampfire Technologies. All rights reserved.
//

#import "NetworkMCSessionDelegate.h"
#import "FRC_Advanced_Scouting_Touchstone-Swift.h"

@interface NetworkMCSessionDelegate()
@property (nonatomic) NetworkMCSessionTranslator *translator;
@end

@implementation NetworkMCSessionDelegate

/*
 create a NetworkMCSessionDelegate and pass in a swift translator
 */
-(instancetype)initWithTranslator:(NetworkMCSessionTranslator*) trans{
    if(self = [super init]){
        self.translator = trans;
    }
    return self;
}

/*
 Indicates that an NSData object has been received from a nearby peer.
 */
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    [self.translator networkSession:session didReceive:data fromPeer:peerID];
}

/*
 Indicates that the local peer began receiving a resource from a nearby peer.
 */
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progres{
    [self.translator networkSession:session didStartReceivingResourceWithName:resourceName fromPeer:peerID with:progres];
}

/*
 Indicates that the local peer finished receiving a resource from a nearby peer.
 */
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error{
    [self.translator networkSession:session didFinishReceivingResourceWithName:resourceName fromPeer:peerID at:localURL withError:error];
}

/*
 Called when the state of a nearby peer changes.
 */
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
    [self.translator networkSession:session peer:peerID didChange:state];
}

/*
 Called when a nearby peer opens a byte stream connection to the local peer.
 */
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID{
    // not expecting to see any of this
}

@end
