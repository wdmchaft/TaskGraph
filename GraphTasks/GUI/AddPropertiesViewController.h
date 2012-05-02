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
}
@property(nonatomic,retain) NMTGProject* parentProject;
@property(nonatomic,retain) NMTGTask* taskToEdit;
@end
