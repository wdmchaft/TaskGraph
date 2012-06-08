//
//  NameOfWhateverViewController.m
//  GraphTasks
//
//  Created by Тимур Юсипов on 03.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TextViewViewController.h"
#import "AddPropertiesViewController.h"
#import <QuartzCore/QuartzCore.h>

/*
// 
//Данный контроллер вызывается для определения имени нового проекта или задания, а также для ввода комментария к заданию
//
*/



@implementation TextViewViewController


@synthesize isAddingTaskName,
            isAddingTaskComment,
            isAddingProjectName,
            isAddingContextName,
            isRenamingProject,
            isRenamingTask,
            isAddingJobPositionName,

            parentProject = _parentProject,
            textViewNameOrComment = _textViewForEVERYTHING,
            delegateContextAdd,
            delegateTaskProperties,
            delegateProjectProperties,
            delegateJobPositions; 

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _textViewForEVERYTHING = [[UITextView alloc]initWithFrame:CGRectMake(5, 10, 310, 180)];
        _textViewForEVERYTHING.returnKeyType =  UIReturnKeyDefault;
        _textViewForEVERYTHING.delegate = self;
        _textViewForEVERYTHING.font = [UIFont systemFontOfSize:20.0];
        _textViewForEVERYTHING.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_textViewForEVERYTHING becomeFirstResponder];
        _textViewForEVERYTHING.layer.cornerRadius = 15.0;
        _textViewForEVERYTHING.clipsToBounds = YES;
        [self.view addSubview:_textViewForEVERYTHING];
        
        _namesDataSource = [NSMutableDictionary new];
    }
    return self;
}

//замена переводов строки пробелами
-(void)modifyTextViewsText
{
    NSMutableString* string = [NSMutableString stringWithString:_textViewForEVERYTHING.text];
    NSRegularExpression* reg_expr = [NSRegularExpression regularExpressionWithPattern:@"\n" options:NSRegularExpressionCaseInsensitive error:nil];
    [reg_expr replaceMatchesInString:string options:NSMatchingCompleted range:NSMakeRange(0, string.length) withTemplate:@" "];
    _textViewForEVERYTHING.text = string;
}

-(void)textViewDidChange:(UITextView *)textView
{
    if(textView == _textViewForEVERYTHING){
        [self.navigationItem.rightBarButtonItem setEnabled:([textView.text length] > 0) ? (YES) : (NO)];
        [_placeholderLabel setHidden:([textView.text length] > 0) ? (YES) : (NO)];
    }
}
-(void)alertShow
{
    NSString* str;
    if (self.isRenamingTask || self.isAddingTaskName) {
        str = @"В данной папке уже есть задание с таким именем";
    }
    if (self.isRenamingProject || self.isAddingProjectName) {
        str = @"В данной папке уже есть проект с таким именем";
    }
    if (self.isAddingJobPositionName) {
        str = @"Такая должность уже существует";
    }
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:str message:@"Введите другое имя" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

-(void)addingTaskName
{
    [self modifyTextViewsText];
    
//    for (NSString* taskName in [_namesDataSource objectForKey:TITLE_SUBTASK_NAMES]){
//        if ([_textViewNameOrCommentOrContextText.text isEqualToString:taskName]) {
//            [self alertShow];
//            return;
//        }
//    }
    
    AddPropertiesViewController* addPropertiesVC = [[AddPropertiesViewController alloc]initWithStyle:UITableViewStyleGrouped];
    [addPropertiesVC setTasksName:_textViewForEVERYTHING.text];
    addPropertiesVC.parentProject = self.parentProject;
    [self.navigationController pushViewController:addPropertiesVC animated:YES];


}

-(void)addingProjectName
{
    //надо сохранить проект и отправить уведомление о закрытии модального контроллера
    
    [self modifyTextViewsText];
    
    for (NSString* projectName in [_namesDataSource objectForKey:TITLE_SUBPROJECT_NAMES]){
        if ([_textViewForEVERYTHING.text isEqualToString:projectName]) {
            [self alertShow];
            return;
        }
    }
    
    NSManagedObjectContext* _context = [[NMTaskGraphManager sharedManager]managedContext];
    NMTGProject* _newProject = [[NMTGProject alloc]initWithEntity:[NSEntityDescription entityForName:@"NMTGProject" inManagedObjectContext:_context] insertIntoManagedObjectContext:_context];
    [_context insertObject:_newProject];
    _newProject.title =  _textViewForEVERYTHING.text;
    _newProject.alertDate_first = [NSDate dateWithTimeIntervalSinceNow:5*86400];
    _newProject.alertDate_second = [NSDate dateWithTimeIntervalSinceNow:7*86400];
    _newProject.done = [NSNumber numberWithBool:YES];
    _newProject.created = [NSDate date];
    
    if(self.parentProject == nil) NSLog(@"ДОБАВЛЯЕМ ПРОЕКТ НА ВЕРХНИЙ УРОВЕНЬ");
    if(self.parentProject != nil){
        NSLog(@"ДОБАВЛЯЕМ ПРОЕКТ НЕ НА ВЕРХНИЙ УРОВЕНЬ");
        [_parentProject addSubProjectObject:_newProject];
        _newProject.parentProject = _parentProject;
    }
    NSError* error = nil;
    if(! ([_context save:&error ]) ){
        NSLog(@"Failed to save context in TextViewVC in 'save'");
        NSLog(@"error: %@",error);
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"projectOrTaskAddVCDidFinishWorkingWithNewProjectOrTask" 
                                                       object:nil];
}


-(void)addingTaskComment
{
    [self modifyTextViewsText];
    [self.delegateTaskProperties setTasksComment:_textViewForEVERYTHING.text];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) addingContextName
{
    [self modifyTextViewsText];

    for (NSString *contextName in [_namesDataSource objectForKey:TITLE_CONTEXT_NAMES]) {
        if ([contextName isEqualToString:_textViewForEVERYTHING.text]) {
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Такой контекст уже существует" message:@"Введите другое имя контекста" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
    }
    
    [self.delegateContextAdd createNewContextWithName:_textViewForEVERYTHING.text];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)renamingProject
{
    [self modifyTextViewsText]; // удаление переводов строки
    
    for (NSString* projectName in [_namesDataSource objectForKey:TITLE_SUBPROJECT_NAMES]){
        if ( [_textViewForEVERYTHING.text isEqualToString:projectName ] &&
            ![_textViewForEVERYTHING.text isEqualToString:_placeHolderText]) {
            [self alertShow];
            return;
        }
    }
    
    [self.delegateProjectProperties setProjectsName:_textViewForEVERYTHING.text];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)renamingTask
{
    [self modifyTextViewsText];
    
//    for (NSString* taskName in [_namesDataSource objectForKey:TITLE_SUBTASK_NAMES]){
//        if ([_textViewNameOrCommentOrContextText.text isEqualToString:taskName]) {
//            [self alertShow];
//            return;
//        }
//    }
    
    [self.delegateTaskProperties setTasksName:_textViewForEVERYTHING.text];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) addingJobPositionName
{
    [self modifyTextViewsText];
    for (NSString* jobPositionName in [_namesDataSource objectForKey:TITLE_JOB_POSITIONS_NAMES]){
        if ([_textViewForEVERYTHING.text isEqualToString:jobPositionName]) {
            [self alertShow];
            return;
        }
    }
    [self.delegateJobPositions createNewJobPositionWithName:_textViewForEVERYTHING.text];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)cancel
{
    if (self.isAddingTaskName || self.isAddingProjectName) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"DismissModalController" 
                                                           object:nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"projectOrTaskAddVCDidFinishWorkingWithNewProjectOrTask" 
                                                           object:nil];
    } else if (self.isAddingContextName || self.isAddingTaskComment || self.isRenamingProject || self.isRenamingTask || self.isAddingJobPositionName) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _placeHolderText = _textViewForEVERYTHING.text;

    _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, _textViewForEVERYTHING.frame.size.width - 20.0, 34.0)];
    [_placeholderLabel setText:_placeHolderText];
    [_placeholderLabel setBackgroundColor:[UIColor clearColor]];
    [_placeholderLabel setTextColor:[UIColor lightGrayColor]];
    [_placeholderLabel setFont:_textViewForEVERYTHING.font];
    [_placeholderLabel setHidden:YES];
    [_textViewForEVERYTHING addSubview:_placeholderLabel];
    
    if(self.isAddingTaskName){
        //значит добавляем задание. нужно ввести имя
        self.navigationItem.title = @"Имя задания";
        _buttonItem = [[UIBarButtonItem alloc]initWithTitle:@"Далее" style:UIBarButtonItemStyleDone target:self action:@selector(addingTaskName)];
    }
    
     else if (self.isAddingProjectName){
        //значит добавляем проект. нужно ввести имя     
        self.navigationItem.title = @"Имя проекта";
        _buttonItem = [[UIBarButtonItem alloc]initWithTitle:@"Сохранить" style:UIBarButtonItemStyleDone target:self action:@selector(addingProjectName)];
    }
    else if (self.isAddingTaskComment) {
        //комментарий к заданию
        self.navigationItem.title = @"Комментарий";
        _buttonItem = [[UIBarButtonItem alloc]initWithTitle:@"Сохранить" style:UIBarButtonItemStyleDone target:self action:@selector(addingTaskComment)];
    }
    else if (self.isAddingContextName) {
        //значит вводим имя контекста
        self.navigationItem.title = @"Имя контекста";
        _buttonItem = [[UIBarButtonItem alloc]initWithTitle:@"Сохранить" style:UIBarButtonItemStyleDone target:self action:@selector(addingContextName)];
    } else if (self.isRenamingProject) {
        self.navigationItem.title = @"Имя проекта";
        _buttonItem = [[UIBarButtonItem alloc]initWithTitle:@"Сохранить" style:UIBarButtonItemStyleDone target:self action:@selector(renamingProject)];
    } else if (self.isRenamingTask) {
        self.navigationItem.title = @"Имя задания";
        _buttonItem = [[UIBarButtonItem alloc]initWithTitle:@"Сохранить" style:UIBarButtonItemStyleDone target:self action:@selector(renamingTask)];
    } else if (self.isAddingJobPositionName) {
        self.navigationItem.title = @"Имя должности";
        _buttonItem = [[UIBarButtonItem alloc]initWithTitle:@"Сохранить" style:UIBarButtonItemStyleDone target:self action:@selector(addingJobPositionName)];
    }
    self.navigationItem.rightBarButtonItem = _buttonItem;
    
    UIBarButtonItem* cancel = [[UIBarButtonItem alloc]initWithTitle:@"Отмена" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    if (self.isAddingTaskName || self.isAddingProjectName || self.isAddingJobPositionName) {    
        self.navigationItem.leftBarButtonItem = nil; //на самом деле не nil. там будет backButtonItem
    } else {
        self.navigationItem.leftBarButtonItem = cancel;
    }
    self.navigationItem.rightBarButtonItem.enabled = (self.isRenamingTask || self.isRenamingProject) ? YES : NO; //сначала нужно будет ввести имя
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];

    
    if (self.isAddingProjectName || self.isAddingTaskName || self.isRenamingTask || self.isRenamingProject) {
        
// формирование списков имен проектов (и задач - закоментировано), находящихся в текущей папке.
        
        NSMutableArray *projectNames = [NSMutableArray new];
        NSMutableArray *taskNames = [NSMutableArray new];
        if (_parentProject != nil) {
            for (NMTGProject* proj in _parentProject.subProject) {
                [projectNames addObject:proj.title];
            }
            for (NMTGTask* task in _parentProject.subTasks) {
                [taskNames addObject:task.title];
            }
        } else { //если мы в корневой папке, то ищем проекты с нулевой родительской связью
            NSManagedObjectContext* context = [[NMTaskGraphManager sharedManager] managedContext];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"NMTGProject" inManagedObjectContext:context];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"parentProject == %@", nil];
            
            NSFetchRequest* request = [NSFetchRequest new];
            [request setEntity:entity];
            [request setPredicate:predicate];
            
            for (NMTGProject* object in [context executeFetchRequest:request error:nil] ) {
                [projectNames addObject:object.title];
            }
        }
//        [_namesDataSource setObject:taskNames forKey:TITLE_SUBTASK_NAMES];
        [_namesDataSource setObject:projectNames forKey:TITLE_SUBPROJECT_NAMES];
        
    } else if (self.isAddingContextName) {
        NSManagedObjectContext* context = [[NMTaskGraphManager sharedManager] managedContext];
        NSEntityDescription* entity = [NSEntityDescription entityForName:@"NMTGContext" inManagedObjectContext:context];
        
        NSFetchRequest* request = [NSFetchRequest new];
        [request setEntity:entity];
    
        NSMutableArray *contextNames = [NSMutableArray new];
        for (NMTGContext *nmtgcontext in [context executeFetchRequest:request error:nil] ) {
            [contextNames addObject:nmtgcontext.name];
        }
        [_namesDataSource setObject:contextNames forKey:TITLE_CONTEXT_NAMES];
        
    } else if (self.isAddingJobPositionName) {
        NSManagedObjectContext* context = [[NMTaskGraphManager sharedManager] managedContext];
        NSEntityDescription* entity = [NSEntityDescription entityForName:@"NMTGJobPosition" inManagedObjectContext:context];
        
        NSFetchRequest* request = [NSFetchRequest new];
        [request setEntity:entity];
        
        NSMutableArray *jobNames = [NSMutableArray new];
        for (NMTGJobPosition *job in [context executeFetchRequest:request error:nil]) {
            [jobNames addObject:job.title];
        }
        [_namesDataSource setObject:jobNames forKey:TITLE_JOB_POSITIONS_NAMES];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];            
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
