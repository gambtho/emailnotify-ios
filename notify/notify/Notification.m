//
//  Notification.m
//  
//
//  Created by Thomas Gamble on 8/11/12.
//
//

#import "Notification.h"


@implementation Notification

@dynamic fromAddress;
@dynamic userEmail;
@dynamic messageBody;
@dynamic sentDate;
@dynamic notificationId;
@dynamic subject;
@dynamic read;
@dynamic highImportance;

-(BOOL)isRead
{
    return self.read;
}

-(void)setRead:(BOOL)read
{
    self.read = read;
}

@end
