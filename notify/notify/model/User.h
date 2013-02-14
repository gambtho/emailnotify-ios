//
//  User.h
//  notify
//
//  Created by Thomas Gamble on 8/23/12.
//  Copyright (c) 2012 Thomas Gamble. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

-(NSString *)getUserAddress;
-(void)setUserAddress:(NSString *)userAddress;
- (id)initWithName:(NSString *)userAddress;
+ (id)initWithName:(NSString *)userAddress;

@end
