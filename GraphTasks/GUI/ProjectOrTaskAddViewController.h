//
//  ProjectOrTaskAddViewController.h
//  GraphTasks
//
//  Created by Тимур Юсипов on 25.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class  NMTGProject;
@interface ProjectOrTaskAddViewController : UIViewController{
    //GUI
    UISegmentedControl* _segmentedControlProjectOrTask;
    UISegmentedControl* _segmentedControlTaskType;
    UIScrollView* _scrollView;
    UISwitch* _switchIsSpecialTask;
    UIDatePicker* datePickerAlert1;
    UIDatePicker* datePickerAlert2;
    
    //CoreData
    NSManagedObjectContext* _context;
    NMTGProject* _parentProject; //этому проекту будут добавлены подпроект или задание
    NMTGAbstract* _projectOrTask; //пользователь выберет создает он задание или проект, которое будете добавлено в качестве дочернего к _currentProject
}

@property (nonatomic,strong) NMTGProject* parentProject;


-(void)save;
-(void)cancel;
-(void)switchValueChanged:(id)object;

@end

