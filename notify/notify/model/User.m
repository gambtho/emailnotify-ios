//
//  User.m
//  notify
//
//  Created by Thomas Gamble on 8/23/12.
//  Copyright (c) 2012 Thomas Gamble. All rights reserved.
//

#import "User.h"

@implementation User

@synthesize userAddress;

//TODO: Add init with address

-(NSString *)getUserAddress;
{
    return self.userAddress;
}

-(void)setUserAddress:(NSString *)userAddress:(NSString *)address
{
    self.userAddress = address;
}

@end
