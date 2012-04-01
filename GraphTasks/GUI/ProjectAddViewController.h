//
//  ProjectAddViewController.h
//  GraphTasks
//
//  Created by Тимур Юсипов on 24.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMTGProject.h"


typedef enum{
    ProjectAddViewControllerSenderProjectsVC = 0,
    ProjectAddViewControllerSenderProjectOrTaskAddVC = 1
}ProjectAddViewControllerSenderType;


@interface ProjectAddViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate,UITableViewDelegate,UITableViewDataSource>{
//   CoreData 
    @public NMTGProject* _newProject;
    NMTGProject* _parentProject; //пользователь создающий этот контроллер представления должен сам задать значение этой переменной. либо nil либо родительский проект
    NSManagedObjectContext* _context;

//   GUI
    UITextField* _textFieldNameOfProject;
    UIDatePicker* _datePicker;
    UIScrollView* _scrollView;
    
    UIDatePicker* _datePickerAlert1;
    
    UITableView* _tableViewExtraSettings;
    
    @public
    ProjectAddViewControllerSenderType _senderType;
    //тип объекта который вызвал этот контроллер.
    //в зависимости от этого типа, он будет постить разные уведомления
    @public BOOL senderIsProjectsVC;
}

@property(nonatomic,strong) NMTGProject* parentProject;

-(void)save;
-(void)cancel;
//-(void)datePickerChanged:(id)sender;

@end
