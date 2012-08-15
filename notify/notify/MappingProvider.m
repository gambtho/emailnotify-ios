//
//  MappingProvider.m
//  notify
//
//  Created by Thomas Gamble on 8/11/12.
//  Copyright (c) 2012 Thomas Gamble. All rights reserved.
//

#import "MappingProvider.h"

@implementation MappingProvider

@synthesize objectStore;

static const int ddLogLevel = LOG_LEVEL_INFO;

+ (id)mappingProviderWithObjectStore:(RKManagedObjectStore *)objectStore {
    return [[self alloc] initWithObjectStore:objectStore];
}

- (id)initWithObjectStore:(RKManagedObjectStore *)theObjectStore {
    self = [super init];
    if (self) {
        self.objectStore = theObjectStore;
        
        [self setObjectMapping:[self notificationObjectMapping] forResourcePathPattern:NOTIFICATION_PATH withFetchRequestBlock:^NSFetchRequest *(NSString *resourcePath) {
            NSFetchRequest *fetchRequest = [Notification fetchRequest];
            fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"sentDate" ascending:YES]];
            return fetchRequest;
        }];
        
    }
    
    return self;
}

- (RKManagedObjectMapping *)notificationObjectMapping
{
    DDLogVerbose(@"creating notificationMapping");
    RKManagedObjectMapping *mapping = [RKManagedObjectMapping mappingForClass:[Notification class]
                                                         inManagedObjectStore:self.objectStore];
    mapping.primaryKeyAttribute = @"notifcationId";
    [mapping mapKeyPath:@"fromAddress" toAttribute:@"fromAddress"];
    [mapping mapKeyPath:@"subject" toAttribute:@"subject"];
    [mapping mapKeyPath:@"userEmail" toAttribute:@"userEmail"];
    [mapping mapKeyPath:@"messageBody" toAttribute:@"messageBody"];
    [mapping mapKeyPath:@"sentDate" toAttribute:@"sentDate"];
    [mapping mapKeyPath:@"id" toAttribute:@"notificationId"];
    [mapping mapKeyPath:@"read" toAttribute:@"read"];
    [mapping mapKeyPath:@"highImportance" toAttribute:@"highImportance"];

    NSDateFormatter* dateFormatter = [NSDateFormatter new];
    [dateFormatter  setDateFormat:@"MM dd, yy HH:mm:ss a"];
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"EST"];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    
    mapping.dateFormatters = [NSArray arrayWithObject: dateFormatter];
    
    return mapping;
}


@end
