//
//  AppDelegate.m
//  notify
//
//  Created by Thomas Gamble on 8/11/12.
//  Copyright (c) 2012 Thomas Gamble. All rights reserved.
//

#import "AppDelegate.h"
#import "UAirship.h"
#import "UAPush.h"
#import "MappingProvider.h"

@implementation AppDelegate

static const int ddLogLevel = LOG_LEVEL_INFO;

@synthesize objectManager, objectStore, objectContext, urbanToken, controller;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self testFlightSetup];
    [self restKitSetup];
    [self setupLogging];
    [self airShipSetup:launchOptions];
    
    application.applicationSupportsShakeToEdit = YES;
    
    NSDictionary* userInfo = [launchOptions valueForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
    NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
    
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    controller = (MasterViewController *)navigationController.topViewController;
    controller.managedObjectContext = self.objectContext;
    controller.objectManager = self.objectManager;
    controller.urbanToken = self.urbanToken;
    
    if( [apsInfo objectForKey:@"alert"] != NULL)
    {
        // REACT TO PN IF APP WAS CLOSED
        [controller updateBadge];
    }

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
    [TestFlight passCheckpoint:@"APPLICATION WENT BECOME ACTIVE"];
    [controller refreshScreen];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [TestFlight passCheckpoint:@"CLOSED APPLICATION"];
    [UAirship land];
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

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{

    if (application.applicationState == UIApplicationStateActive)
    {
        [self.controller refreshScreen];
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
//    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    [TestFlight passCheckpoint:@"SET DEVICE IDENTIFIER"];
#endif
    [TestFlight takeOff:TF_ID];
    [TestFlight passCheckpoint:@"LAUNCHED APPLICATION"];
}

-(void)airShipSetup:(NSDictionary *)launchOptions
{
    //Init Airship launch options
    
    [UAirship setLogging:YES];
    
    NSMutableDictionary *takeOffOptions = [[NSMutableDictionary alloc] init];
    [takeOffOptions setValue:launchOptions forKey:UAirshipTakeOffOptionsLaunchOptionsKey];
    
    // Create Airship singleton that's used to talk to Urban Airship servers.
    // Please populate AirshipConfig.plist with your info from http://go.urbanairship.com
    [UAirship takeOff:takeOffOptions];
    
    [[UAPush shared]
     registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                         UIRemoteNotificationTypeSound |
                                         UIRemoteNotificationTypeAlert)];
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    UALOG(@"APN device token: %@", deviceToken);
    
    // Sets the alias. It will be sent to the server on registration.
    
    NSString *yourAlias = [[NSUserDefaults standardUserDefaults] stringForKey:USERNAME];
    
    urbanToken = deviceToken;
   
    if(yourAlias!=nil)
    {
        UALOG(@"user alias set to: %@", yourAlias);
        [UAPush shared].alias = yourAlias;
    }
    
    // Updates the device token and registers the token with UA
    [[UAPush shared] registerDeviceToken:deviceToken];
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
