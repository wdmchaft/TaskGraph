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

@interface TextViewViewController : UIViewController<UITextViewDelegate, UIAlertViewDelegate>{
    UITextView* _textViewNameOrCommentOrContextText;
    BOOL _isAddingTaskName;
    BOOL _isAddingTaskComment;
    BOOL _isAddingProjectName;
    BOOL _isAddingContextName;
    BOOL _isRenamingProject;
    
    NMTGProject* _parentProject;
    id<ContextAddDelegate> _delegateContextAdd;
    id<SetNewTasksProperties> _delegateTaskProperties;
    id<SetProjectsProperties> _delegateProjectProperties;
    
    UIBarButtonItem* _buttonItem;
    
}
@property(nonatomic)        BOOL isAddingTaskName;
@property(nonatomic)        BOOL isAddingTaskComment;
@property(nonatomic)        BOOL isAddingProjectName;
@property(nonatomic)        BOOL isAddingContextName;
@property(nonatomic)        BOOL isRenamingProject;

@property(nonatomic,strong) NMTGProject* parentProject;
@property(nonatomic,retain) UITextView* textViewNameOrComment;
@property(nonatomic,retain) id<ContextAddDelegate> delegateContextAdd;
@property(nonatomic,retain) id<SetNewTasksProperties> delegateTaskProperties;
@property(nonatomic,retain) id<SetProjectsProperties> delegateProjectProperties;

-(void)addingProjectName;
-(void)addingTaskName;
-(void)addingTaskComment;
-(void)addingContextName;
-(void)cancel;
-(void)renamingProject;

-(void)modifyTextViewsText;
@end
