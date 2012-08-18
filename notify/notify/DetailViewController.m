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
- (void)configureView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item
@synthesize subjectLabel;
@synthesize fromAddressLabel;
@synthesize sendDateLabel;

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

        self.messageBodyLabel.text = self.notifyItem.subject;
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

- (void)viewDidUnload
{
    [self setSubjectLabel:nil];
    [self setFromAddressLabel:nil];
    [self setSendDateLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
