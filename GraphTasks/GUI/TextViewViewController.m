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

@interface TextViewViewController(internal)
    -(void)addingProjectName;
    -(void)addingTaskName;
    -(void)addingTaskComment;
    -(void)addingContextName;
    -(void)cancel;
@end


@implementation TextViewViewController


@synthesize isAddingTaskName = _isAddingTaskName,
            isAddingTaskComment = _isAddingTaskComment,
            isAddingProjectName = _isAddingProjectName,
            isAddingContextName = _isAddingContextName,

            parentProject = _parentProject,
            textViewNameOrComment = _textViewNameOrCommentOrContextText,
            delegateContextAdd = _delegateContextAdd,
            delegateTaskProperties = _delegateTaskProperties;
                    

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
    }
    return self;
}


-(void)textViewDidChange:(UITextView *)textView
{
    if(textView == _textViewNameOrCommentOrContextText){
        [self.navigationItem.rightBarButtonItem setEnabled:([textView.text length] > 0) ? (YES) :   (NO)];
    }
}


-(void)addingTaskName
{
    AddPropertiesViewController* addPropertiesVC = [[AddPropertiesViewController alloc]initWithStyle:UITableViewStyleGrouped];
    [addPropertiesVC setTasksName:_textViewNameOrCommentOrContextText.text];
    addPropertiesVC.parentProject = self.parentProject;
    [self.navigationController pushViewController:addPropertiesVC animated:YES];
}

-(void)addingProjectName
{
    //надо просто сохранить проект и отправить уведомление о закрытии модального контроллера

    NSManagedObjectContext* _context = [[NMTaskGraphManager sharedManager]managedContext];
    NMTGProject* _newProject = [[NMTGProject alloc]initWithEntity:[NSEntityDescription entityForName:@"NMTGProject" inManagedObjectContext:_context] insertIntoManagedObjectContext:_context];
    [_context insertObject:_newProject];
    _newProject.title =  _textViewNameOrCommentOrContextText.text;
    _newProject.alertDate_first = [NSDate dateWithTimeIntervalSinceNow:7*86400];
    _newProject.done = [NSNumber numberWithBool:NO];
    
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
    [[NSNotificationCenter defaultCenter]postNotificationName:@"DismissModalController" 
                                                       object:nil];
}


-(void)addingTaskComment
{
    [self.delegateTaskProperties setTasksComment:_textViewNameOrCommentOrContextText.text];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) addingContextName
{
    NSArray* contextNamesThatAlreadyExist = [self.delegateContextAdd getData];
    if ([contextNamesThatAlreadyExist containsObject:_textViewNameOrCommentOrContextText.text]) {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Такой контекст уже существует" message:@"Введите другое имя контектса" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    } 
    [self.delegateContextAdd setContextName:_textViewNameOrCommentOrContextText.text];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)cancel
{
    if (self.isAddingTaskName || self.isAddingProjectName) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"DismissModalController" 
                                                           object:nil];
    } else if (self.isAddingContextName || self.isAddingTaskComment) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(self.isAddingTaskName){
        //значит добавляем задание. нужно ввести имя
        self.navigationItem.title = @"Имя задания";
        UIBarButtonItem* next = [[UIBarButtonItem alloc]initWithTitle:@"Далее" style:UIBarButtonItemStyleDone target:self action:@selector(addingTaskName)];
        self.navigationItem.rightBarButtonItem = next;
    }
    
     else if(self.isAddingProjectName){
        //значит добавляем проект. нужно ввести имя     
        self.navigationItem.title = @"Имя проекта";
        UIBarButtonItem* next = [[UIBarButtonItem alloc]initWithTitle:@"Сохранить" style:UIBarButtonItemStyleDone target:self action:@selector(addingProjectName)];
        self.navigationItem.rightBarButtonItem = next;
    }
    else if(self.isAddingTaskComment) {
        //комментарий к заданию
        self.navigationItem.title = @"Комментарий";
        UIBarButtonItem* save = [[UIBarButtonItem alloc]initWithTitle:@"Сохранить" style:UIBarButtonItemStyleDone target:self action:@selector(addingTaskComment)];
        self.navigationItem.rightBarButtonItem = save;
    }
    else if(self.isAddingContextName) {
        //значит вводим имя контекста
        self.navigationItem.title = @"Имя контекста";
        UIBarButtonItem* save = [[UIBarButtonItem alloc]initWithTitle:@"Сохранить" style:UIBarButtonItemStyleDone target:self action:@selector(addingContextName)];
        self.navigationItem.rightBarButtonItem = save;
    }
    
    
    UIBarButtonItem* cancel = [[UIBarButtonItem alloc]initWithTitle:@"Отмена" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancel;
    self.navigationItem.rightBarButtonItem.enabled = NO; //сначала нужно будет ввести имя
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
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
