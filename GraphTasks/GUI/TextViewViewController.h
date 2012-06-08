//
//  NameOfWhateverViewController.h
//  GraphTasks
//
//  Created by Тимур Юсипов on 03.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskViewController.h"
#import "AddPropertiesViewController.h"
#import "ContextsViewController.h"
#import "JobPositionsViewController.h"

#define TITLE_SUBPROJECT_NAMES @"Имена подпроектов"
#define TITLE_SUBTASK_NAMES @"Имена подзадач"
#define TITLE_CONTEXT_NAMES @"Имена контекстов"
#define TITLE_JOB_POSITIONS_NAMES @"Имена должностей"

@interface TextViewViewController : UIViewController<UITextViewDelegate, UIAlertViewDelegate>{
    UITextView* _textViewForEVERYTHING;
    
    NMTGProject* _parentProject;
    NSMutableDictionary* _namesDataSource;
    
    UIBarButtonItem* _buttonItem;
    UILabel* _placeholderLabel;
    NSString* _placeHolderText;
    
}
//свойства для задач
@property(nonatomic)        BOOL isAddingTaskName;
@property(nonatomic)        BOOL isAddingTaskComment;
@property(nonatomic)        BOOL isAddingProjectName;
@property(nonatomic)        BOOL isAddingContextName;
@property(nonatomic)        BOOL isRenamingProject;
@property(nonatomic)        BOOL isRenamingTask;
//свойства для работников
@property(nonatomic)        BOOL isAddingJobPositionName;

@property(nonatomic,strong) NMTGProject* parentProject;
@property(nonatomic,retain) UITextView* textViewNameOrComment;
@property(nonatomic,retain) id<ContextAddDelegate> delegateContextAdd;
@property(nonatomic,retain) id<SetTasksProperties> delegateTaskProperties;
@property(nonatomic,retain) id<SetProjectsProperties> delegateProjectProperties;
@property(nonatomic,retain) id<JobPositionsDelegate> delegateJobPositions;

-(void)addingProjectName;
-(void)addingTaskName;
-(void)addingTaskComment;
-(void)addingContextName;
-(void)cancel;
-(void)renamingProject;
-(void)addingJobPositionName;

-(void)alertShow;

-(void)modifyTextViewsText;
@end
