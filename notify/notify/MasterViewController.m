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

@interface MasterViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation MasterViewController

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@synthesize objectManager;

@synthesize userEmail;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.userEmail = @"thomas_gamble@homedepot.com";
    [self getNotifications];

    [self performFetch];
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
//    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/*
- (void)insertNewObject:(id)sender
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
//    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
         // Replace this implementation with code to handle the error appropriately.
         // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}
*/

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
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
    [self.tableView reloadData];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    DDLogVerbose(@"Getting fetched results controller");
    if (_fetchedResultsController == nil) {
        
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
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userEmail == %@", self.userEmail];
    return predicate;
    
}

-(void)getNotifications
{
    DDLogVerbose(@"Getting notifications");
    DDLogInfo(@"Host name is %@", HOST);
    if(userEmail!=nil)
    {
        NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:self.userEmail, @"user", nil];
        NSString *resourcePath = [NOTIFICATION_PATH stringByAppendingQueryParameters:queryParams];
        DDLogVerbose(@"%@", resourcePath);
        [objectManager loadObjectsAtResourcePath:resourcePath delegate:self];
    }
}

-(void)performFetch
{
    DDLogVerbose(@"Performing fetch");
    NSError *error;
    if(![self.fetchedResultsController performFetch:&error])
    {
        FATAL_CORE_DATA_ERROR(error);
        return;
    }
    else{
#if DEBUG
        DDLogVerbose(@"Fetch succesful");
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
        DDLogInfo(@"Number objects fetched: %d", [sectionInfo numberOfObjects]);
#endif
    }
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    DDLogError(@"Error: %@", [error localizedDescription]);
    [self performFetch];
}

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    DDLogVerbose(@"response code: %d", [response statusCode]);
    DDLogVerbose(@"response is: %@", [response bodyAsString]);
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    DDLogInfo(@"Objectloader loaded objects[%d]", [objects count]);
    [self performFetch];
}

-(void)deleteRemote:(Notification *)notification {
    DDLogVerbose(@"Notification for delete is %d", [notification.notifyId intValue]);
    DDLogVerbose(@"Contacting server to delete %@", notification.subject);
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                 notification.notifyId, @"id",
                                 nil];
    NSString *resourcePath = [NOTIFICATION_PATH stringByAppendingQueryParameters:queryParams];
    DDLogInfo(@"Resource path for delete is %@", resourcePath);
    [objectManager loadObjectsAtResourcePath:resourcePath usingBlock:^(RKObjectLoader *loader) {
        loader.delegate = self;
        loader.method = RKRequestMethodDELETE;
    }];
}

@end
