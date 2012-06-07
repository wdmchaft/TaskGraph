//
//  AddPropertiesViewController.h
//  GraphTasks
//
//  Created by Тимур Юсипов on 03.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SetTasksProperties <NSObject>
-(void) setTasksName: (NSString*)name;
-(void) setTasksAlertDateFirst: (NSDate*)date;
-(void) setTasksAlertDateSecond: (NSDate*)date;
-(void) setTasksComment: (NSString*)comment;
-(void) setTasksContext: (NSString*)context;
-(void) setTasksDeferred: (NSNumber*)isDeferred;
-(void) setTasksKeyDescribingType: (NSString *)typeInfo AndItsValue: (NSString *)attributeValue;
@end



@interface AddPropertiesViewController : UITableViewController<SetTasksProperties>{
    NSDictionary* _tableDataSourse;
    NSManagedObjectContext* _context;
    NMTGProject* _parentProject;
    NMTGTask* _taskToEdit; 
    BOOL _beganEditting;
    
    //будущие параметры нового задания
    NSString*   _taskName;
    NSDate*     _taskAlertDateFirst;
    NSDate*     _taskAlertDateSecond;
    NSString*   _taskComment;
    NSString*   _taskContext;
    NSDate*     _creationOrRenamingDate;
    NSNumber*   _taskDeferred;
    NSString*   _taskKeyDescribingType; //строка типа "Позвонить" или "SMS" или "e-Mail"
    NSString*   _taskValueForKeyDescribingType; //первым двум типам будет соответствовать номер телефона. Третьему - адрес почты
    
    UISwitch* _switch;
}
@property(nonatomic,retain) NMTGProject* parentProject;
@property(nonatomic,retain) NMTGTask* taskToEdit;
@property(nonatomic, getter = isTaskSMS) BOOL taskSMS;
@property(nonatomic, getter = isTaskMail) BOOL taskMail;
@property(nonatomic, getter = isTaskPhone) BOOL taskPhone;
@property(nonatomic, getter = isTaskMap) BOOL taskMap;

- (void) switchChanged;

@end
