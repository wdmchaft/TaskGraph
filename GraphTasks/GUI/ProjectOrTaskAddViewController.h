//
//  ProjectOrTaskAddViewController.h
//  GraphTasks
//
//  Created by Тимур Юсипов on 25.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class  NMTGProject;
@interface ProjectOrTaskAddViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate,UITableViewDelegate,UITableViewDataSource>{
    //GUI
    UISegmentedControl* _segmentedControlProjectOrTask;
    UILabel* _labelTaskType;
    UISegmentedControl* _segmentedControlTaskType;
    UIScrollView* _scrollView;
    UISwitch* _switchIsSpecialTask;
    UIDatePicker* _datePickerAlert1;
    UITextField* _textFieldNameOfTask;
    UITableView* _tableViewExtraSettings;
    UILabel* labelExtraSettings;
    UILabel* labelDatePicker1;
    UILabel* labelName;
    
    
    //CoreData
    NSManagedObjectContext* _context;
    NMTGProject* _parentProject; //этому проекту будут добавлены подпроект или задание
    NMTGAbstract* _projectOrTask; //пользователь выберет создает он задание или проект, которое будете добавлено в качестве дочернего к _currentProject
}

@property (nonatomic,strong) NMTGProject* parentProject;


-(void)save;
-(void)cancel;
-(void)switchValueChanged:(id)object;
-(void)setUpMovableGUI:(int)offset;

@end

