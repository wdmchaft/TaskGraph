//
//  AddPropertiesViewController.h
//  GraphTasks
//
//  Created by Тимур Юсипов on 03.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddPropertiesViewController : UITableViewController<UITextFieldDelegate>{
    NSDictionary* _tableDataSourse;
    UITextField* _textFieldName;
    NSManagedObjectContext* _context;
    NMTGProject* _parentProject;
    BOOL _isAddingProject;
    
    //будущие параметры нового задания
    NSString*   _projectName;
    NSDate*     _projectAlertDateFirst;
    NSDate*     _projectAlertDateSecond;
    NSString*   _projectComment;
    NSString*   _projectContext;
}
@property(nonatomic,retain)NSString* projectName;
@property(nonatomic,retain)NSDate* projectAlertDateFirst;
@property(nonatomic,retain)NSDate* projectAlertDateSecond;
@property(nonatomic,retain)NSString* projectComment;
@property(nonatomic,retain)NSString* projectContext;
@property(nonatomic) BOOL isAddingProject;
@property(nonatomic,retain) NMTGProject* parentProject;

@end
