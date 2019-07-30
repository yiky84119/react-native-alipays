//
//  RNAlipay.m
//  RNAlipay
//
//  Created by nevo
//

#import "RNAlipay.h"
#import <AlipaySDK/AlipaySDK.h>

@implementation RNAlipay
static NSString *const kOpenURLNotification = @"RCTOpenURLNotification";
RCT_EXPORT_MODULE();
RCT_EXPORT_METHOD(pay:(NSString*)payInfo withCallback:(RCTResponseSenderBlock)callback)
{
    NSArray *urls = [[NSBundle mainBundle] infoDictionary][@"CFBundleURLTypes"];
    NSMutableString *appScheme = [NSMutableString string];
    BOOL multiUrls = [urls count] > 1;
    for (NSDictionary *url in urls) {
        NSArray *schemes = url[@"CFBundleURLSchemes"];
        if (!multiUrls ||
            (multiUrls && [@"alipay" isEqualToString:url[@"CFBundleURLName"]])) {
            [appScheme appendString:schemes[0]];
            break;
        }
    }

    if ([appScheme isEqualToString:@""]) {
        NSString *error = @"scheme cannot be empty";
        NSMutableDictionary *data = [NSMutableDictionary new];
        [data setValue:error forKey:@"errStr"];
        [data setValue:@(10000) forKey:@"type"];
        [data setValue:@(10000) forKey:@"errCode"];
        callback([[NSArray alloc] initWithObjects:data, nil]);
        return;
    }

    self->mRCTResponseSenderBlock = callback;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[AlipaySDK defaultService] payOrder:payInfo fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            self->mRCTResponseSenderBlock([[NSArray alloc] initWithObjects:resultDic, nil]);
        }];
    });
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOpenURL:) name:kOpenURLNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleOpenURL:(NSNotification *)notification {
    NSString *urlString = notification.userInfo[@"url"];
    NSURL *url = [NSURL URLWithString:urlString];
    if ([url.host isEqualToString:@"safepay"]) {
        [AlipaySDK.defaultService processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            if (self->mRCTResponseSenderBlock)
            self->mRCTResponseSenderBlock([[NSArray alloc] initWithObjects:resultDic, nil]);
        }];
    }
}

@end
