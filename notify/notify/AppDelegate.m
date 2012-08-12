//
//  AppDelegate.m
//  notify
//
//  Created by Thomas Gamble on 8/11/12.
//  Copyright (c) 2012 Thomas Gamble. All rights reserved.
//

#import "AppDelegate.h"

#import "MasterViewController.h"
#import "MappingProvider.h"

@implementation AppDelegate

static const int ddLogLevel = LOG_LEVEL_INFO;

@synthesize objectManager, objectStore, objectContext;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self testFlightSetup];
    [self restKitSetup];
    [self setupLogging];
    
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    MasterViewController *controller = (MasterViewController *)navigationController.topViewController;
    controller.managedObjectContext = self.objectContext;
    controller.objectManager = self.objectManager;

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
       [TestFlight passCheckpoint:@"APPLICATION WENT TO BACKGROUND"];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     [TestFlight passCheckpoint:@"APPLICATION WENT TO FOREGROUND"];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [TestFlight passCheckpoint:@"CLOSED APPLICATION"];
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.objectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

-(void)fatalCoreDataError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"Internal Error", nil) message:@"There was a fatal error in the app and it cannot continue" delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [TestFlight passCheckpoint:@"CORE DATA ERROR"];
    [alertView show];
    
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark - TestFlight

-(void)testFlightSetup
{
#if DEBUG
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    [TestFlight passCheckpoint:@"SET DEVICE IDENTIFIER"];
#endif
    [TestFlight takeOff:TF_ID];
    [TestFlight passCheckpoint:@"LAUNCHED APPLICATION"];
}

#pragma mark - RestKit

-(void)restKitSetup
{
    
    //RKLogConfigureByName("RestKit/*", RKLogLevelTrace);
    
    self.objectManager = [RKObjectManager managerWithBaseURLString:HOST];
    self.objectManager.client.requestQueue.showsNetworkActivityIndicatorWhenBusy = YES;
    self.objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:DB_NAME];
    self.objectManager.objectStore = self.objectStore;
    self.objectManager.mappingProvider = [MappingProvider mappingProviderWithObjectStore:self.objectStore];
    self.objectContext = self.objectStore.managedObjectContextForCurrentThread;
    
}

#pragma mark - Cocoa Lumberjack

-(void)setupLogging
{
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
}

#pragma mark - AlertView Delegate

-(void)alertView:(UIAlertView *)theAlertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    abort();
}

@end
