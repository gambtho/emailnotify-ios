//
//  DetailViewController.m
//  notify
//
//  Created by Thomas Gamble on 8/11/12.
//  Copyright (c) 2012 Thomas Gamble. All rights reserved.
//

#import "DetailViewController.h"
#import "UIViewController+DateString.h"

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *fromAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *sendDateLabel;
@property (weak, nonatomic) IBOutlet UITextView *messageBodyText;

- (void)configureView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item
static const int ddLogLevel = LOG_LEVEL_VERBOSE;

- (void)setNotification:(Notification *)newNotifyItem
{
    if (_notifyItem != newNotifyItem) {
        _notifyItem = newNotifyItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.notifyItem) {

        self.messageBodyText.text = self.notifyItem.messageBody;
        self.sendDateLabel.text = [self getDateString:self.notifyItem.sentDate];
        self.fromAddressLabel.text = self.notifyItem.fromAddress;
        self.subjectLabel.text = self.notifyItem.subject;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    DDLogVerbose(@"Received low memory warning");
    [super didReceiveMemoryWarning];
    
    if ([self isViewLoaded] && self.view.window == nil) {
        DDLogVerbose(@"will unload view");
        self.view = nil;
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
