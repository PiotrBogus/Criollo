//
//  CRConnection.m
//  Criollo
//
//  Created by Cătălin Stan on 10/23/15.
//  Copyright © 2015 Cătălin Stan. All rights reserved.
//

#import "CRConnection.h"
#import "CRServer.h"
#import "CRServerConfiguration.h"
#import "GCDAsyncSocket.h"
#import "CRRequest.h"
#import "CRResponse.h"

@interface CRConnection () <GCDAsyncSocketDelegate>

@end

@implementation CRConnection

+ (NSData *)CRLFCRLFData {
    static NSData* _CRLFCRLFData;
    static dispatch_once_t _CRLFCRLFDataToken;
    dispatch_once(&_CRLFCRLFDataToken, ^{
        _CRLFCRLFData = [NSData dataWithBytes:"\x0D\x0A\x0D\x0A" length:4];
    });
    return _CRLFCRLFData;
}

+ (NSData *)CRLFData {
    static NSData* _CRLFData;
    static dispatch_once_t _CRLFDataToken;
    dispatch_once(&_CRLFDataToken, ^{
        _CRLFData = [NSData dataWithBytes:"\x0D\x0A" length:2];
    });
    return _CRLFData;
}

#pragma mark - Initializers

- (instancetype)init {
    return [self initWithSocket:nil server:nil];
}

- (instancetype)initWithSocket:(GCDAsyncSocket *)socket server:(CRServer *)server {
    self = [super init];
    if (self != nil) {
        self.server = server;
        self.socket = socket;
        self.socket.delegate = self;
    }
    return self;
}

- (void)dealloc {
    [self.socket setDelegate:nil delegateQueue:NULL];
    [self.socket disconnect];
}

#pragma mark - Data

- (void)startReading {
}

- (void)didReceiveCompleteRequestHeaders {
    NSLog ( @"%s %@", __PRETTY_FUNCTION__, self.request.allHTTPHeaderFields );
    NSLog ( @"%s %@", __PRETTY_FUNCTION__, self.request.env );
}

- (void)didReceiveRequestBody {
}

- (void)didReceiveCompleteRequest {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, self.request.body);
}

#pragma mark - State
- (BOOL)shouldClose {

    if ( self.ignoreKeepAlive ) {
        return YES;
    }

    BOOL shouldClose = NO;

    NSString *connectionHeader = [self.request valueForHTTPHeaderField:@"Connection"];
    if ( connectionHeader != nil ) {
        shouldClose = [connectionHeader caseInsensitiveCompare:@"close"] == NSOrderedSame;
    } else {
        shouldClose = [self.request.version isEqualToString:CRHTTP10];
    }

    return shouldClose;
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData*)data withTag:(long)tag {
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    [self.server didCloseConnection:self];
}

@end
