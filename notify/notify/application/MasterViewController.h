//
//  MasterViewController.h
//  notify
//
//  Created by Thomas Gamble on 8/11/12.
//  Copyright (c) 2012 Thomas Gamble. All rights reserved.
//

#import "User.h"

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate, RKObjectLoaderDelegate, UITextFieldDelegate, RKRequestDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSFetchRequest *badgeFetchRequest;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) RKObjectManager *objectManager;
@property (nonatomic, strong) NSData *urbanToken;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *loginButton;

- (IBAction)login:(id)sender;
-(void)refreshScreen;

@property (nonatomic) BOOL pinValidated;
@property (strong, nonatomic) User *loggedInUser;

@end
