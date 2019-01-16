//
//  BFSPingAssistant.m
//  BFSDemoOfPing
//
//  Created by 刘玲 on 2019/1/16.
//  Copyright © 2019年 BFS. All rights reserved.
//

#import "BFSPingAssistant.h"
#import "SimplePing.h"

#include <netdb.h>
#include <arpa/inet.h>


#define kPingOvertime   2.f

@interface BFSPingAssistant () <SimplePingDelegate> {
    BOOL _isPingSuccess;
}
@property (nonatomic, copy) NSString *hostName;
@property (nonatomic, strong) SimplePing *simplePing;
@property (nonatomic, strong) id curTarget;
@property (nonatomic, assign) SEL curSelector;

@end

@implementation BFSPingAssistant

#pragma mark - Property

- (SimplePing *)simplePing {
    
    if (!_simplePing) {
        _simplePing = [[SimplePing alloc] initWithHostName:self.hostName];
        _simplePing.delegate = self;
    }
    
    return _simplePing;
}

#pragma mark - API

- (instancetype)initWithHostName:(NSString *)hostName forTarget:(id)target selector:(SEL)selector {
    
    if (self = [super init]) {
        
        if (hostName.length > 1) {
            
            self.curTarget = target;
            self.curSelector = selector;
            
            self.hostName = [hostName copy];
        }
    }
    
    return self;
}

- (void)startPing {
    
    struct addrinfo *hintsInfo;
    struct addrinfo *resultInfo;
    
    int result = getaddrinfo([self.hostName UTF8String], NULL, hintsInfo, &resultInfo);
    if (result != 0) {
        self.simplePing.addressStyle = SimplePingAddressStyleAny;
    } else {
        if (AF_INET == resultInfo->ai_family) { // IPv4
            self.simplePing.addressStyle = SimplePingAddressStyleAny;
        } else {    // IPv6
            self.simplePing.addressStyle = SimplePingAddressStyleAny;
        }
    }
    
    _isPingSuccess = NO;
    [self.simplePing start];
//    // 设置超时处理
//    [self performSelector:@selector(pingOvertime) withObject:nil afterDelay:kPingOvertime];
}

- (void)cancelPing {
    
    [self.simplePing stop];
}

- (void)finishPing {
    
    [self handlePingResult:false];
}

- (void)pingOvertime {
    
    if (_isPingSuccess) {
        return;
    }
    [self handlePingResult:false];
}

#pragma mark - Private

- (void)handlePingResult:(BOOL)success {
    
    [self cancelPing];
    [self.curTarget performSelector:self.curSelector withObject:@(success)];
}

#pragma mark -SimplePingDelegate

- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address {
    NSLog(@"【%@ %@】", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error {
    NSLog(@"【%@ %@】", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (void)simplePing:(SimplePing *)pinger didSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber {
    NSLog(@"【%@ %@】", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber error:(NSError *)error {
    NSLog(@"【%@ %@】", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber {
    NSLog(@"【%@ %@】", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (void)simplePing:(SimplePing *)pinger didReceiveUnexpectedPacket:(NSData *)packet {
    NSLog(@"【%@ %@】", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    _isPingSuccess = YES;
    [self handlePingResult:YES];
}

@end