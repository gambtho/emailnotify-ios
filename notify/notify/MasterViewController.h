//
//  MasterViewController.h
//  notify
//
//  Created by Thomas Gamble on 8/11/12.
//  Copyright (c) 2012 Thomas Gamble. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import <CoreData/CoreData.h>

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate, RKObjectLoaderDelegate, UITextFieldDelegate, RKRequestDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) RKObjectManager *objectManager;

@property (nonatomic) BOOL pinValidated;
@property (strong, nonatomic) User *loggedInUser;

@end
