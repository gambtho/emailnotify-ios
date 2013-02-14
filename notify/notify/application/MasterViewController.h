//
//  MasterViewController.h
//  notify
//
//  Created by Thomas Gamble on 8/11/12.
//  Copyright (c) 2012 Thomas Gamble. All rights reserved.
//

#import "User.h"

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate, RKObjectLoaderDelegate, UITextFieldDelegate, RKRequestDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) RKObjectManager *objectManager;
@property (nonatomic, strong) NSData *urbanToken;

-(void)refreshScreen;
-(void)updateBadge;

@end
