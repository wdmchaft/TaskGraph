//
//  NameOfWhateverViewController.m
//  GraphTasks
//
//  Created by Тимур Юсипов on 03.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TextViewViewController.h"
#import "AddPropertiesViewController.h"
#import "NMTGTask.h"
#import "NMTGContext.h"
#import <QuartzCore/QuartzCore.h>

/*
// 
//Данный контроллер вызывается для определения имени нового проекта или задания, а также для ввода комментария к заданию
//
*/



@implementation TextViewViewController


@synthesize isAddingTaskName = _isAddingTaskName,
            isAddingTaskComment = _isAddingTaskComment,
            isAddingProjectName = _isAddingProjectName,
            isAddingContextName = _isAddingContextName,
            isRenamingProject = _isRenamingProject,
            isRenamingTask = _isRenamingTask,

            parentProject = _parentProject,
            textViewNameOrComment = _textViewNameOrCommentOrContextText,
            delegateContextAdd = _delegateContextAdd,
            delegateTaskProperties = _delegateTaskProperties,
            delegateProjectProperties = _delegateProjectProperties;
                    

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _textViewNameOrCommentOrContextText = [[UITextView alloc]initWithFrame:CGRectMake(5, 10, 310, 180)];
        _textViewNameOrCommentOrContextText.returnKeyType =  UIReturnKeyDefault;
        _textViewNameOrCommentOrContextText.delegate = self;
        _textViewNameOrCommentOrContextText.font = [UIFont systemFontOfSize:20.0];
        _textViewNameOrCommentOrContextText.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_textViewNameOrCommentOrContextText becomeFirstResponder];
        _textViewNameOrCommentOrContextText.layer.cornerRadius = 15.0;
        _textViewNameOrCommentOrContextText.clipsToBounds = YES;
        [self.view addSubview:_textViewNameOrCommentOrContextText];
        
        _namesDataSource = [NSMutableDictionary new];
    }
    return self;
}

//устранение косяка связанного с появлением "..." при вводе \n в имя проекта или задания
-(void)modifyTextViewsText
{
    NSMutableString* string = [NSMutableString stringWithString:_textViewNameOrCommentOrContextText.text];
    NSRegularExpression* reg_expr = [NSRegularExpression regularExpressionWithPattern:@"\n" options:NSRegularExpressionCaseInsensitive error:nil];
    [reg_expr replaceMatchesInString:string options:NSMatchingCompleted range:NSMakeRange(0, string.length) withTemplate:@" "];
    _textViewNameOrCommentOrContextText.text = string;
}

-(void)textViewDidChange:(UITextView *)textView
{
    if(textView == _textViewNameOrCommentOrContextText){
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
    
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:str message:@"Введите другое имя" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

-(void)addingTaskName
{
    [self modifyTextViewsText];
    
    for (NSString* taskName in [_namesDataSource objectForKey:TITLE_SUBTASK_NAMES]){
        if ([_textViewNameOrCommentOrContextText.text isEqualToString:taskName]) {
            [self alertShow];
            return;
        }
    }
    
    AddPropertiesViewController* addPropertiesVC = [[AddPropertiesViewController alloc]initWithStyle:UITableViewStyleGrouped];
    [addPropertiesVC setTasksName:_textViewNameOrCommentOrContextText.text];
    addPropertiesVC.parentProject = self.parentProject;
    [self.navigationController pushViewController:addPropertiesVC animated:YES];


}

-(void)addingProjectName
{
    //надо сохранить проект и отправить уведомление о закрытии модального контроллера
    
    [self modifyTextViewsText];
    
    for (NSString* projectName in [_namesDataSource objectForKey:TITLE_SUBPROJECT_NAMES]){
        if ([_textViewNameOrCommentOrContextText.text isEqualToString:projectName]) {
            [self alertShow];
            return;
        }
    }
    
    NSManagedObjectContext* _context = [[NMTaskGraphManager sharedManager]managedContext];
    NMTGProject* _newProject = [[NMTGProject alloc]initWithEntity:[NSEntityDescription entityForName:@"NMTGProject" inManagedObjectContext:_context] insertIntoManagedObjectContext:_context];
    [_context insertObject:_newProject];
    _newProject.title =  _textViewNameOrCommentOrContextText.text;
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
    [self.delegateTaskProperties setTasksComment:_textViewNameOrCommentOrContextText.text];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) addingContextName
{
    [self modifyTextViewsText];
    
    NSManagedObjectContext* context = [[NMTaskGraphManager sharedManager] managedContext];
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"NMTGContext" inManagedObjectContext:context];
    
    NSFetchRequest* request = [NSFetchRequest new];
    [request setEntity:entity];
    
    NSArray* contextsThatAlreadyExist = [context executeFetchRequest:request error:nil];
    for (NMTGContext *nmtgcontext in contextsThatAlreadyExist) {
        if ([nmtgcontext.name isEqualToString:_textViewNameOrCommentOrContextText.text]) {
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Такой контекст уже существует" message:@"Введите другое имя контекста" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
    }
    
    [self.delegateContextAdd setContextName:_textViewNameOrCommentOrContextText.text];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)renamingProject
{
    [self modifyTextViewsText]; // удаление переводов строки
    
    for (NSString* projectName in [_namesDataSource objectForKey:TITLE_SUBPROJECT_NAMES]){
        if ([_textViewNameOrCommentOrContextText.text isEqualToString:projectName]) {
            [self alertShow];
            return;
        }
    }
    
    [self.delegateProjectProperties setProjectsName:_textViewNameOrCommentOrContextText.text];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)renamingTask
{
    [self modifyTextViewsText];
    
    for (NSString* taskName in [_namesDataSource objectForKey:TITLE_SUBTASK_NAMES]){
        if ([_textViewNameOrCommentOrContextText.text isEqualToString:taskName]) {
            [self alertShow];
            return;
        }
    }
    
    [self.delegateTaskProperties setTasksName:_textViewNameOrCommentOrContextText.text];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)cancel
{
    if (self.isAddingTaskName || self.isAddingProjectName) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"DismissModalController" 
                                                           object:nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"projectOrTaskAddVCDidFinishWorkingWithNewProjectOrTask" 
                                                           object:nil];
    } else if (self.isAddingContextName || self.isAddingTaskComment || self.isRenamingProject || self.isRenamingTask) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _placeHolderText = _textViewNameOrCommentOrContextText.text;

    _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, _textViewNameOrCommentOrContextText.frame.size.width - 20.0, 34.0)];
    [_placeholderLabel setText:_placeHolderText];
    [_placeholderLabel setBackgroundColor:[UIColor clearColor]];
    [_placeholderLabel setTextColor:[UIColor lightGrayColor]];
    [_placeholderLabel setFont:_textViewNameOrCommentOrContextText.font];
    [_placeholderLabel setHidden:YES];
    [_textViewNameOrCommentOrContextText addSubview:_placeholderLabel];
    
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
    }
    self.navigationItem.rightBarButtonItem = _buttonItem;
    
    UIBarButtonItem* cancel = [[UIBarButtonItem alloc]initWithTitle:@"Отмена" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    if (self.isAddingTaskName || self.isAddingProjectName) {    
        self.navigationItem.leftBarButtonItem = nil;
    } else {
        self.navigationItem.leftBarButtonItem = cancel;
    }
    self.navigationItem.rightBarButtonItem.enabled = (self.isRenamingTask || self.isRenamingProject) ? YES : NO; //сначала нужно будет ввести имя
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    NSMutableArray* projectNames = [NSMutableArray new];
    for (NMTGProject* proj in _parentProject.subProject) {
        [projectNames addObject:proj.title];
    }
    NSMutableArray* taskNames = [NSMutableArray new];
    for (NMTGTask* task in _parentProject.subTasks) {
        [taskNames addObject:task.title];
    }
    [_namesDataSource setObject:taskNames forKey:TITLE_SUBTASK_NAMES];
    [_namesDataSource setObject:projectNames forKey:TITLE_SUBPROJECT_NAMES];
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
