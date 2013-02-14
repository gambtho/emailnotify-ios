//
//  User.m
//  notify
//
//  Created by Thomas Gamble on 8/23/12.
//  Copyright (c) 2012 Thomas Gamble. All rights reserved.
//

#import "User.h"

@interface User ()

@property (nonatomic, strong) NSString * userAddress;

@end

@implementation User

+(id)initWithName:(NSString *)userAddress
{
    return [[self alloc] initWithName:userAddress];
}

-(id)initWithName:(NSString *)userAddress
{
    if ((self = [super init]))
    {
        _userAddress = userAddress;
    }
    return self;
}

-(NSString *)getUserAddress;
{
    return self.userAddress;
}

-(void)setUserAddress:(NSString *)userAddress
{
    _userAddress = userAddress;
}

@end
