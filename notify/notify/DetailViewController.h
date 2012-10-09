//
//  DetailViewController.h
//  notify
//
//  Created by Thomas Gamble on 8/11/12.
//  Copyright (c) 2012 Thomas Gamble. All rights reserved.
//

@interface DetailViewController : UIViewController

@property (strong, nonatomic) Notification *notifyItem;
@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *fromAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *sendDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageBodyLabel;
@end
