//
//  Notification.h
//  
//
//  Created by Thomas Gamble on 8/11/12.
//
//


@interface Notification : NSManagedObject

@property (nonatomic, retain) NSString * fromAddress;
@property (nonatomic, retain) NSString * userEmail;
@property (nonatomic, retain) NSString * messageBody;
@property (nonatomic, retain) NSDate * sentDate;
@property (nonatomic, retain) NSNumber * notifyId;
@property (nonatomic, retain) NSString * subject;
@property (nonatomic) BOOL read;
@property (nonatomic) BOOL highImportance;

-(BOOL) isRead;
-(void) setRead:(BOOL)read;


@end
