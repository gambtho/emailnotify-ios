//
//  NotificationCell.m
//  notify
//
//  Created by Thomas Gamble on 8/14/12.
//  Copyright (c) 2012 Thomas Gamble. All rights reserved.
//

#import "NotificationCell.h"

@implementation NotificationCell

@synthesize subject;
@synthesize fromAddress;
@synthesize sentDate;
@synthesize imageView;
@synthesize read;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
