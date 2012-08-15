//
//  NotificationCell.h
//  notify
//
//  Created by Thomas Gamble on 8/14/12.
//  Copyright (c) 2012 Thomas Gamble. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *subject;
@property (nonatomic, strong) IBOutlet UILabel *fromAddress;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel *sentDate;
@property (nonatomic, strong) IBOutlet UILabel *read;

@end
