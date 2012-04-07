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
    -(void)addingProject;
    -(void)addingTask;
    -(void)savingComment;
    -(void)cancel;
@end


@implementation TextViewViewController
@synthesize     isSentToEnterName = _isSentToEnterName,
                          superVC = _superVC,
                  isAddingProject = _isAddingProject,
                    parentProject = _parentProject,
            textViewNameOrComment = _textViewNameOrComment;
                    

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _textViewNameOrComment = [[UITextView alloc]initWithFrame:CGRectMake(5, 10, 310, 180)];
        _textViewNameOrComment.returnKeyType =  UIReturnKeyDefault;
        _textViewNameOrComment.delegate = self;
        _textViewNameOrComment.font = [UIFont systemFontOfSize:20.0];
        _textViewNameOrComment.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_textViewNameOrComment becomeFirstResponder];
        _textViewNameOrComment.layer.cornerRadius = 15.0;
        _textViewNameOrComment.clipsToBounds = YES;
        [self.view addSubview:_textViewNameOrComment];
    }
    return self;
}


-(void)textViewDidChange:(UITextView *)textView
{
    if(textView == _textViewNameOrComment){
        [self.navigationItem.rightBarButtonItem setEnabled:([textView.text length] > 0) ? (YES) :   (NO)];
    }
}


-(void)addingTask
{
    AddPropertiesViewController* addPropertiesVC = [[AddPropertiesViewController alloc]initWithStyle:UITableViewStyleGrouped];
    addPropertiesVC.projectName = _textViewNameOrComment.text;
    addPropertiesVC.isAddingProject = self.isAddingProject;
    addPropertiesVC.parentProject = self.parentProject;
    [self.navigationController pushViewController:addPropertiesVC animated:YES];
}

-(void)addingProject
{
    //надо просто сохранить проект и отправить уведомление о закрытии модального контроллера

    NSManagedObjectContext* _context = [[NMTaskGraphManager sharedManager]managedContext];
    NMTGProject* _newProject = [[NMTGProject alloc]initWithEntity:[NSEntityDescription entityForName:@"NMTGProject" inManagedObjectContext:_context] insertIntoManagedObjectContext:_context];
    [_context insertObject:_newProject];
    _newProject.title =  _textViewNameOrComment.text;
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


-(void)savingComment
{
    self.superVC.projectComment = _textViewNameOrComment.text;
    [self.superVC.tableView reloadData];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)cancel
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"DismissModalController" 
                                                       object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if((self.isAddingProject==NO)&&(self.isSentToEnterName)){
        //значит добавляем задание. нужно ввести имя
        self.navigationItem.title = @"Имя задания";
        UIBarButtonItem* next = [[UIBarButtonItem alloc]initWithTitle:@"Далее" style:UIBarButtonItemStyleDone target:self action:@selector(addingTask)];
        self.navigationItem.rightBarButtonItem = next;
    }
    
    if((self.isAddingProject==YES)&&(self.isSentToEnterName)){
        //значит добавляем проект. нужно ввести имя     
        self.navigationItem.title = @"Имя проекта";
        UIBarButtonItem* next = [[UIBarButtonItem alloc]initWithTitle:@"Сохранить" style:UIBarButtonItemStyleDone target:self action:@selector(addingProject)];
        self.navigationItem.rightBarButtonItem = next;
        
        UIBarButtonItem* cancel = [[UIBarButtonItem alloc]initWithTitle:@"Отмена" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
        self.navigationItem.leftBarButtonItem = cancel;
    }
    if(self.isSentToEnterName == NO) {
        //значит отправитель - AddPropertiesVC. С целью получить комментарий к заданию
        self.navigationItem.title = @"Комментарий";
        UIBarButtonItem* save = [[UIBarButtonItem alloc]initWithTitle:@"Сохранить" style:UIBarButtonItemStyleDone target:self action:@selector(savingComment)];
        save.enabled = YES;
        self.navigationItem.rightBarButtonItem = save;
    }
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
