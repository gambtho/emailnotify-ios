//
//  MappingProvider.h
//  notify
//
//  Created by Thomas Gamble on 8/11/12.
//  Copyright (c) 2012 Thomas Gamble. All rights reserved.
//

#import "RKObjectMappingProvider.h"

@interface MappingProvider : RKObjectMappingProvider

@property (nonatomic, strong) RKManagedObjectStore *objectStore;

+ (id)mappingProviderWithObjectStore:(RKManagedObjectStore *)objectStore;
- (id)initWithObjectStore:(RKManagedObjectStore *)objectStore;
- (RKManagedObjectMapping *)notificationObjectMapping;
- (RKObjectMapping *)userObjectMapping;

@end
