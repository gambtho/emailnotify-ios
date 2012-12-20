//
//  User.h
//  notify
//
//  Created by Thomas Gamble on 8/23/12.
//  Copyright (c) 2012 Thomas Gamble. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic, retain) NSString * userAddress;

-(NSString *)getUserAddress;
-(void)setUserAddress:(NSString *)userAddress;

@end
