//
//  AppDelegate.h
//  notify
//
//  Created by Thomas Gamble on 8/11/12.
//  Copyright (c) 2012 Thomas Gamble. All rights reserved.
//
#import "MasterViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) RKObjectManager *objectManager;
@property (nonatomic, strong) RKManagedObjectStore *objectStore;
@property (nonatomic, strong) NSManagedObjectContext *objectContext;
@property (nonatomic, strong) NSData *urbanToken;
@property (nonatomic, retain) IBOutlet MasterViewController *controller;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
