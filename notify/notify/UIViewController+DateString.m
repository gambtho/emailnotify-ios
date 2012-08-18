//
//  UITableViewController+DateString.m
//  tasker
//
//  Created by Thomas Gamble on 8/3/12.
//
//

#import "UIViewController+DateString.h"

@implementation UIViewController (DateString)

static const int ddLogLevel = LOG_LEVEL_INFO;

-(NSString *)getDateString:(NSDate *)date
{
    NSString *dateString = @" ";
    
    if(date!=nil)
    {
        dateString = [NSDateFormatter localizedStringFromDate:date
                                   dateStyle:NSDateFormatterShortStyle
                                   timeStyle:NSDateFormatterShortStyle];
        DDLogVerbose(@"Date passed to getDateString: %@", dateString);
    }
    else
    {
        DDLogVerbose(@"Null date passed to getDateString");
    }
   
    return dateString;
}

@end
