//
//  Constants.m
//  notify
//
//  Created by Thomas Gamble on 8/11/12.
//  Copyright (c) 2012 Thomas Gamble. All rights reserved.
//

#import "Constants.h"

@implementation Constants

#if DEBUG
NSString * const HOST = @"http://localhost:8888";
#else
NSString * const HOST = @"http://notifyweb.appspot.com";
#endif

NSString * const NOTIFICATION_PATH = @"/notifyweb/notification";
NSString * const USER_PATH = @"/notifyweb/user";
NSString * const DB_NAME = @"Notify.sqlite";
// NSString * const TF_ID = @"846469c44299f82f9bf854c9258b1b6c_MTIwMzYyMjAxMi0wOC0xMSAyMTo1NTowMS44NTg2OTU";
NSString * const TF_ID = @"f421c4d4-9008-46f5-a418-38dbf84878a8";
@end
