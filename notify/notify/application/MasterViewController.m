//
//  MasterViewController.m
//  notify
//
//  Created by Thomas Gamble on 8/11/12.
//  Copyright (c) 2012 Thomas Gamble. All rights reserved.
//

#import "MasterViewController.h"
#import "NotificationCell.h"
#import "DetailViewController.h"
#import "UIViewController+DateString.h"
#import "KeychainWrapper.h"
#import "UAirship.h"
#import "UAPush.h"

@interface MasterViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, weak) IBOutlet UIBarButtonItem *loginButton;
@property (nonatomic) BOOL pinValidated;
@property (nonatomic, strong) User *loggedInUser;
- (IBAction)login:(id)sender;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation MasterViewController 

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)refreshSetup
{
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refresh addTarget:self action:@selector(refreshView:)forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
}

- (void)loginButtonConfigure
{
    DDLogVerbose(@"Configuring login button");
    if(self.loggedInUser == nil)
    {
        DDLogVerbose(@"Logged in user is currently nil");
        if([[NSUserDefaults standardUserDefaults] boolForKey:PIN_SAVED])
        {
            _fetchedResultsController = nil;
            self.loggedInUser =  [User initWithName:[[NSUserDefaults standardUserDefaults] stringForKey:USERNAME]];
            self.loginButton.title = @"Logout";
        }
        else
        {
            DDLogVerbose(@"Did not find saved pin");
            self.loginButton.title = @"Login";
            self.pinValidated = NO;
        }
    }
    else
    {
        DDLogVerbose(@"Logged in user is already valid");
        self.loginButton.title = @"Logout";
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self refreshSetup];
    [self refreshScreen];
    [self updateUrbanAlias];
    
}

- (void)didReceiveMemoryWarning
{
    DDLogVerbose(@"Received low memory warning");
    [super didReceiveMemoryWarning];
    
    if ([self isViewLoaded] && self.view.window == nil) {
        DDLogVerbose(@"will unload view");
        self.view = nil;
        self.fetchedResultsController = nil;
        self.loggedInUser = nil;
    }
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Notification *notificationToDelete = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        
        [self deleteRemote:notificationToDelete];
        [context deleteObject:notificationToDelete];
        
        NSError *error = nil;
        if (![context save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Notification *notifyItem = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [notifyItem setRead:TRUE];
        [[segue destinationViewController] setNotifyItem:notifyItem];
    }
    [self refreshScreen];
}

#pragma mark - Refresh

-(void)refreshScreen
{
    [self loginButtonConfigure];
    [self getNotifications];
    [self performFetch];
    [self.tableView reloadData];
    [self updateBadge];
}

- (IBAction)help:(id)sender {
}

-(void)refreshView:(UIRefreshControl *)refresh {
         refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    
        [self refreshScreen];
    
         NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
         [formatter setDateFormat:@"MMM d, h:mm a"];
         NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",
                                                                    [formatter stringFromDate:[NSDate date]]];
         refresh.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
          
         [refresh endRefreshing];
     }

#pragma mark - Badge Fetch Request

- (void)updateBadge
{
    int badgeCount = 0;
    
    for (Notification *info in [[self fetchedResultsController] fetchedObjects]) {
        NSLog(@"Subject: %@", [info subject]);
        if(![info isRead])
        {
            badgeCount++;
        }
    }
    DDLogInfo(@"Badge count is %d", badgeCount);
    [UIApplication sharedApplication].applicationIconBadgeNumber = badgeCount;
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    
    if (_fetchedResultsController == nil) {
      
        DDLogVerbose(@"Getting fetched results controller");
        NSFetchRequest *fetchRequest = [[[RKObjectManager sharedManager]
                                         mappingProvider] fetchRequestForResourcePath:NOTIFICATION_PATH];
        
        [NSFetchedResultsController deleteCacheWithName:@"Master"];
        
        [fetchRequest setFetchBatchSize:20];
        
        [fetchRequest setPredicate:[self currentPredicate]];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc]
                                    initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
        
        _fetchedResultsController.delegate = self;
    }
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    else
    {
        DDLogInfo(@"Saved context");
    }
 
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    DDLogVerbose(@"Configuring cell");
    Notification *notification = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NotificationCell *notifyCell = (NotificationCell *)cell;
    notifyCell.subject.text = notification.subject;
    notifyCell.sentDate.text = [self getDateString:notification.sentDate];
    notifyCell.fromAddress.text = notification.fromAddress;
    if(![notification isRead])
       {
           notifyCell.read.hidden = YES;
       }
    else
       {
           notifyCell.read.hidden = NO;
       }
}

#pragma Data Access

-(NSPredicate *)currentPredicate
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userEmail == %@", [self.loggedInUser getUserAddress]];
    return predicate;
    
}

-(void)getNotifications
{

    if(self.loggedInUser!=nil)
    {
        DDLogVerbose(@"Getting notifications");
        DDLogInfo(@"Host name is %@", HOST);
        [NSFetchedResultsController deleteCacheWithName:@"Notifications"];
        [self.fetchedResultsController.fetchRequest setPredicate:[self currentPredicate]];
        
        NSString *fieldString = [KeychainWrapper keychainStringFromMatchingIdentifier:PIN_SAVED];
        DDLogInfo(@"Pin is %@", fieldString);
        DDLogInfo(@"User is %@", [self.loggedInUser getUserAddress]);
        NSDictionary *queryParams = @{@"user": [self.loggedInUser getUserAddress],
                                     @"token": fieldString};
        NSString *resourcePath = [NOTIFICATION_PATH stringByAppendingQueryParameters:queryParams];
        DDLogVerbose(@"%@", resourcePath);
        [self.objectManager loadObjectsAtResourcePath:resourcePath usingBlock:^(RKObjectLoader *loader) {
            loader.delegate = self;
            loader.method = RKRequestMethodGET;
            [loader setUserData:@"getNotifications"];
        }];
    }
}

-(void)performFetch
{
    DDLogVerbose(@"Performing fetch");
    DDLogInfo(@"User is now: %@", [self.loggedInUser getUserAddress]);
    NSError *error;
    if(![self.fetchedResultsController performFetch:&error])
    {
        FATAL_CORE_DATA_ERROR(error);
        return;
    }
    else{
#if DEBUG
        DDLogVerbose(@"Fetch succesful");
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][0];
        DDLogInfo(@"Number objects fetched: %d", [sectionInfo numberOfObjects]);
#endif
    }
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    DDLogError(@"Error: %@", [error localizedDescription]);
    if([objectLoader.userData isEqual: @"user"])
    {
        DDLogInfo(@"In object loader error");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Error" message:@"Unable to validate login!" delegate:Nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
        [alert show];
        _fetchedResultsController = nil;
        self.loggedInUser = nil;
        [self refreshScreen];
        
    }
    else if ([objectLoader.userData isEqual:@"deleteAll"])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Error" message:@"Error processing delete all request!" delegate:Nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
        [alert show];
    }

}

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    DDLogVerbose(@"response code: %d", [response statusCode]);
    DDLogVerbose(@"response is: %@", [response bodyAsString]);
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    DDLogInfo(@"Objectloader loaded objects[%d]", [objects count]);
    DDLogInfo(@"User Data is %@", objectLoader.userData);
    if([objectLoader.userData isEqual: @"user"])
    {
        self.loggedInUser = objects[0];
        _fetchedResultsController = nil;
        [self refreshScreen];
    }
    else if ([objectLoader.userData isEqual:@"deleteAll"])
    {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        for (Notification *info in [[self fetchedResultsController] fetchedObjects]) {
            NSLog(@"Subject: %@", [info subject]);
            [context deleteObject:info];
        }
        //_fetchedResultsController = nil;
        [self refreshScreen];
        //[self updateBadge];
    }
    else
    {
        [self updateBadge];
    }
}

-(void)objectLoaderDidFinishLoading:(RKObjectLoader *)objectLoader
{
    DDLogVerbose(@"Completed loading object");
    DDLogInfo(@"User is now: %@", [self.loggedInUser getUserAddress]);
}


-(void)deleteRemote:(Notification *)notification {
    DDLogVerbose(@"Notification for delete is %d", [notification.notifyId intValue]);
    DDLogVerbose(@"Contacting server to delete %@", notification.subject);
    NSDictionary *queryParams = @{@"id": notification.notifyId};
    NSString *resourcePath = [NOTIFICATION_PATH stringByAppendingQueryParameters:queryParams];
    DDLogInfo(@"Resource path for delete is %@", resourcePath);
    [self.objectManager loadObjectsAtResourcePath:resourcePath usingBlock:^(RKObjectLoader *loader) {
        loader.delegate = self;
        loader.method = RKRequestMethodDELETE;
        [loader setUserData:@"singleDelete"];
    }];
    
}

#pragma mark Login
- (void)presentAlertViewForLogin
{
    
    // 1
    BOOL hasPin = [[NSUserDefaults standardUserDefaults] boolForKey:PIN_SAVED];
    
    // 2
    if (hasPin) {
        // 3
        NSString *user = [[NSUserDefaults standardUserDefaults] stringForKey:USERNAME];
        //self.userEmail = user;
        NSString *message = [NSString stringWithFormat:@"Username is %@", user];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter Password"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Done", nil];
        // 4
        [alert setAlertViewStyle:UIAlertViewStyleSecureTextInput]; // Gives us the password field
        alert.tag = kAlertTypePIN;
        // 5
        UITextField *pinField = [alert textFieldAtIndex:0];
        pinField.delegate = self;
        pinField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        pinField.tag = kTextFieldPIN;
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Setup Account"
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Done", nil];
        // 6
        [alert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
        alert.tag = kAlertTypeSetup;
        UITextField *nameField = [alert textFieldAtIndex:0];
        nameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        nameField.keyboardType = UIKeyboardTypeEmailAddress;
        nameField.placeholder = @"Email Address"; // Replace the standard placeholder text with something more applicable
        nameField.delegate = self;
        nameField.tag = kTextFieldName;
        UITextField *passwordField = [alert textFieldAtIndex:1]; // Capture the Password text field since there are 2 fields
        passwordField.delegate = self;
        passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        passwordField.tag = kTextFieldPassword;
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kAlertTypePIN) {
        if (buttonIndex == 1 && self.pinValidated) { // User selected "Done"
            DDLogInfo(@"User logged into account: %@", [self.loggedInUser getUserAddress]);
            self.pinValidated = NO;
        } else { // User selected "Cancel"
            _fetchedResultsController = nil;
            self.loggedInUser = nil;
            [self refreshScreen];
        }
    } else if (alertView.tag == kAlertTypeSetup) {
        if (buttonIndex == 1 && [self credentialsValidated]) { // User selected "Done"
            DDLogInfo(@"User setup account: %@", [self.loggedInUser getUserAddress]);
        } else { // User selected "Cancel"
            _fetchedResultsController = nil;
            self.loggedInUser = nil;
            [self refreshScreen];
        }
    }  else if (alertView.tag == kAlertTypeDeleteAll) {
        if (buttonIndex == 1)
        {
            NSString *fieldString = [KeychainWrapper keychainStringFromMatchingIdentifier:PIN_SAVED];
        
            NSDictionary *queryParams = @{@"user": [[NSUserDefaults standardUserDefaults] stringForKey:USERNAME],
                                     @"token": fieldString, @"type": @"deleteAll"};
        
            NSString *resourcePath = [USER_PATH stringByAppendingQueryParameters:queryParams];
            DDLogInfo(@"User create resource path: %@", resourcePath);
        
            [self.objectManager loadObjectsAtResourcePath:resourcePath usingBlock:^(RKObjectLoader *loader) {
            loader.delegate = self;
            loader.method = RKRequestMethodPOST;
            [loader setUserData:@"deleteAll"];
            }];
        }
        
    }
    [self updateUrbanAlias];
}

// Helper method to congregate the Name and PIN fields for validation.
- (BOOL)credentialsValidated
{
    NSString *name = [[NSUserDefaults standardUserDefaults] stringForKey:USERNAME];
    BOOL pin = [[NSUserDefaults standardUserDefaults] boolForKey:PIN_SAVED];
    if (name && pin) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Text Field + Alert View Methods
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // 1
    switch (textField.tag) {
        case kTextFieldPIN: // We go here if this is the 2nd+ time used (we've already set a PIN at Setup).
            NSLog(@"User entered PIN to validate");
            if ([textField.text length] > 0) {
                // 2
                NSUInteger fieldHash = [textField.text hash]; // Get the hash of the entered PIN, minimize contact with the real password
                // 3
                if ([KeychainWrapper compareKeychainValueForMatchingPIN:fieldHash]) { // Compare them
                    NSLog(@"** User Authenticated!!");
                    NSString *fieldString = [KeychainWrapper keychainStringFromMatchingIdentifier:PIN_SAVED];
                    NSDictionary *queryParams = @{@"user": [[NSUserDefaults standardUserDefaults] stringForKey:USERNAME],
                                                 @"token": fieldString};
                    NSString *resourcePath = [USER_PATH stringByAppendingQueryParameters:queryParams];
                    DDLogInfo(@"User create resource path: %@", resourcePath);
                    
                    [self.objectManager loadObjectsAtResourcePath:resourcePath usingBlock:^(RKObjectLoader *loader) {
                        loader.delegate = self;
                        loader.method = RKRequestMethodPOST;
                        [loader setUserData:@"user"];
                    }];
                    
                    if ([KeychainWrapper createKeychainValue:fieldString forIdentifier:PIN_SAVED]) {
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PIN_SAVED];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        NSLog(@"** Key saved successfully to Keychain!!");
                    }
                    self.pinValidated = YES;
                    
                } else {
                    NSLog(@"** Wrong Password :(");
                    self.pinValidated = NO;
                }
            }
            break;
        case kTextFieldName: // 1st part of the Setup flow.
            NSLog(@"User entered name");
            if ([textField.text length] > 0) {
                [[NSUserDefaults standardUserDefaults] setValue:textField.text forKey:USERNAME];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            break;
        case kTextFieldPassword: // 2nd half of the Setup flow.
            NSLog(@"User entered PIN");
            if ([textField.text length] > 0) {
                NSUInteger fieldHash = [textField.text hash];
                // 4
                NSString *fieldString = [KeychainWrapper securedSHA256DigestHashForPIN:fieldHash];
                NSLog(@"** Password Hash - %@", fieldString);
                // Save PIN hash to the keychain (NEVER store the direct PIN)
                
                NSDictionary *queryParams = @{@"user": [[NSUserDefaults standardUserDefaults] stringForKey:USERNAME],
                                             @"token": fieldString};
                NSString *resourcePath = [USER_PATH stringByAppendingQueryParameters:queryParams];
                DDLogInfo(@"User create resource path: %@", resourcePath);
                
                [self.objectManager loadObjectsAtResourcePath:resourcePath usingBlock:^(RKObjectLoader *loader) {
                    loader.delegate = self;
                    loader.method = RKRequestMethodPOST;
                    [loader setUserData:@"user"];
                }];
                
                if ([KeychainWrapper createKeychainValue:fieldString forIdentifier:PIN_SAVED]) {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PIN_SAVED];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    NSLog(@"** Key saved successfully to Keychain!!");
                }
            }
            break;
        default:
            break;
    }
    
    
}
- (IBAction)login:(id)sender {
    if(self.loggedInUser == nil)
    {
        [self presentAlertViewForLogin];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERNAME];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:PIN_SAVED];
        [KeychainWrapper deleteItemFromKeychainWithIdentifier:PIN_SAVED];
        
        [self updateUrbanAlias];
        self.loggedInUser = nil;
        _fetchedResultsController = nil;
        [self refreshScreen];
    }
}

    
- (void)updateUrbanAlias
{
    
    NSString *yourAlias = [[NSUserDefaults standardUserDefaults] stringForKey:USERNAME];
    DDLogInfo(@"Updating urban airship token %@", yourAlias);
    
    if(yourAlias==nil)
    {
        yourAlias = @"logged_out";
    }
    else
    {
        [UAPush shared].alias = yourAlias;
    }
    
    // Updates the device token and registers the token with UA
    [[UAPush shared] registerDeviceToken:self.urbanToken];
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}



- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete All?"
                                                            message:@"Select ok to delete all notifications"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"OK", nil];
        alertView.tag = kAlertTypeDeleteAll;
        [alertView show];
    }
}

@end
