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
NSString * const HOST = @"http://10.0.1.22:8888";
#else
NSString * const HOST = @"http://notifyweb.appspot.com";
#endif

NSString * const NOTIFICATION_PATH = @"/notifyweb/notification";
NSString * const USER_PATH = @"/notifyweb/user";
NSString * const DB_NAME = @"Notify.sqlite";
NSString * const TF_ID = @"846469c44299f82f9bf854c9258b1b6c_MTIwMzYyMjAxMi0wOC0xMSAyMTo1NTowMS44NTg2OTU";

@end
