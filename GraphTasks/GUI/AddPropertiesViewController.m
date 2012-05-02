//
//  AddPropertiesViewController.m
//  GraphTasks
//
//  Created by Тимур Юсипов on 03.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AddPropertiesViewController.h"
#import "AlertDateViewController.h"
#import "TextViewViewController.h"
#import "ContextsViewController.h"

#import "NMTaskGraphManager.h"
#import "NMTGTask.h"
#import "NMTGProject.h"

#define TITLE_COMMENT_AND_CONTEXT @"Пометки"
#define TITLE_ALERT_DATES @"Напоминания"
#define TITLE_NAME @"Имя"
/*
//
// Данный контроллер вызывается для задания аттрибутов задания. Дат напоминаний, комментария, смены имени и контекста
//
*/ 
@implementation AddPropertiesViewController

@synthesize parentProject = _parentProject,
            taskToEdit = _taskToEdit;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _context = [[NMTaskGraphManager sharedManager]managedContext];
        
        NSArray* arrayCommentAndContext = [NSArray arrayWithObjects:@"Комментарий",@"Контекст", nil];
        NSArray* arrayAlertDates = [NSArray arrayWithObjects:@"Первое",@"Второе", nil];
        NSArray* arrayName = [NSArray arrayWithObjects:@"Имя", nil];
        
        _tableDataSourse = [NSDictionary dictionaryWithObjectsAndKeys: arrayName, TITLE_NAME, arrayCommentAndContext,TITLE_COMMENT_AND_CONTEXT,arrayAlertDates,TITLE_ALERT_DATES,nil];
    }
    return self;
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.taskToEdit == nil && self->_beganEditting == NO){
        _taskAlertDateFirst = [NSDate dateWithTimeIntervalSinceNow:0];
        _taskAlertDateSecond = [NSDate dateWithTimeIntervalSinceNow:3*86400];
        _taskComment = @"";
        _taskContext = @"";
    } 
    if(self.taskToEdit != nil && self->_beganEditting == NO){
        _taskAlertDateFirst = self.taskToEdit.alertDate_first;
        _taskAlertDateSecond = self.taskToEdit.alertDate_second;
        _taskComment = self.taskToEdit.comment;
        _taskContext = self.taskToEdit.context;
        _taskName = self.taskToEdit.title;
    }
    self->_beganEditting = YES;

//                NSDateFormatter* df = ...; [df setDateStyle:]
//                    NSDateFormatterNoStyle   ==   
//                    NSDateFormatterShortStyle  ==  4/3/12
//                    NSDateFormatterMediumStyle  ==  Apr 3, 2012
//                    NSDateFormatterLongStyle  ==  April 3, 2012
//                    NSDateFormatterFullStyle  ==  Tuesday, April 3, 2012
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Свойства";

    UIBarButtonItem* save = [[UIBarButtonItem alloc]initWithTitle:@"Сохранить" style:UIBarButtonItemStyleDone target:self action:@selector(save)];
    UIBarButtonItem* cancel = [[UIBarButtonItem alloc]initWithTitle:@"Отмена" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    
    self.navigationItem.rightBarButtonItem = save;
    self.navigationItem.leftBarButtonItem = cancel;
}


-(void)save
{    
    if (_taskToEdit==nil) {
        //значит создаем новое задание
        NMTGTask* _newTask = [[NMTGTask alloc]initWithEntity:[NSEntityDescription entityForName:@"NMTGTask" inManagedObjectContext:_context] insertIntoManagedObjectContext:_context];
        [_context insertObject:_newTask];
        
        _newTask.title = _taskName;
        _newTask.alertDate_first = _taskAlertDateFirst;
        _newTask.alertDate_second = _taskAlertDateSecond;
        _newTask.comment = _taskComment;
        _newTask.context = _taskContext;
        _newTask.done = [NSNumber numberWithBool:NO];
        _newTask.created = [NSDate date];

        if(_parentProject == nil){NSLog(@"NILL PARENT PROJ IN ADDPROPERTIES vc");}
        [_parentProject addSubTasksObject:_newTask];
        [_newTask setParentProject:_parentProject];
    } else {
        //значит редактируем существующее задание
        _taskToEdit.title = _taskName;
        _taskToEdit.alertDate_first = _taskAlertDateFirst;
        _taskToEdit.alertDate_second = _taskAlertDateSecond;
        _taskToEdit.comment = _taskComment;
        _taskToEdit.context = _taskContext;
    }
    
    NSError* error = nil;
    if(! ([_context save:&error ]) ){
        NSLog(@"%@",error);
        NSLog(@"Failed to save context in AddPropertiesVC in 'save'");
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"DismissModalController" 
                                                       object:nil];
}

-(void) cancel
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"DismissModalController" 
                                                        object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_tableDataSourse count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray* allKeys = [_tableDataSourse allKeys];
    NSString* particularKey = [allKeys objectAtIndex:section];
    return [[_tableDataSourse objectForKey:particularKey]count];
}


//TODO спросить почему не работает
//TODO спросить касательно клеточки имени проекта
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    (cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier]);
    
    NSArray* allKeys = [_tableDataSourse allKeys];
    NSString* particularKey = [allKeys objectAtIndex:indexPath.section];  
    NSArray* cellDataSourse = [_tableDataSourse objectForKey:particularKey];
    cell.textLabel.text = [cellDataSourse objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    switch (indexPath.section) {
        case 0: //имя задания
        {
            cell.detailTextLabel.text = _taskName;
            
            cell.accessoryType = UITableViewCellAccessoryNone;
//            _textFieldName = [[UITextField alloc]init];
//            _textFieldName.frame = CGRectMake(70, 10, 150, 40);
//            _textFieldName.returnKeyType = UIReturnKeyDone;
//            _textFieldName.delegate = self;
//            _textFieldName.clearButtonMode = UITextFieldViewModeNever;
//            [cell.contentView addSubview:_textFieldName];
            break;
        }
        case 1: //даты напоминаний
        {
            NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
            formatter.dateStyle = NSDateFormatterFullStyle;
            cell.detailTextLabel.text = (indexPath.row == 0) 
                        ? ([formatter stringFromDate: _taskAlertDateFirst]) 
                        : ([formatter stringFromDate: _taskAlertDateSecond]);
            
//            ? [NSString stringWithFormat:@"%@",_taskAlertDateFirst]
//            : [NSString stringWithFormat:@"%@",_taskAlertDateSecond];
            break;
        }
        case 2: //комментарий и контекст
        {
            cell.detailTextLabel.text = (indexPath.row == 0) 
                            ? (_taskComment) 
                            : ([_taskContext isEqualToString:@""]) ? ( @"(Без контекста)")
                                                                   : (_taskContext);
            break;
        }
        default:
            break;
    }
    return cell;
}


-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return TITLE_NAME;
            break;
        case 1:
            return TITLE_ALERT_DATES;
            break;
        case 2:
            return TITLE_COMMENT_AND_CONTEXT;
            break;
        default:
            return nil;
            break;
    }
}




/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self->_beganEditting = YES;
    switch (indexPath.section){
        case 0: //появляется клавиатура для ввода имени задания
        {
            TextViewViewController* textViewVC = [TextViewViewController new];
            textViewVC.delegateTaskProperties = self;
            textViewVC.isRenamingTask = YES;
            textViewVC.textViewNameOrComment.text = _taskName;
            [self.navigationController pushViewController:textViewVC animated:YES];
            
            break;
        }
        case 1: //добавляется дата напоминания
        {
            AlertDateViewController* alertDateVC = [[AlertDateViewController alloc]init];
            if (indexPath.row == 0) {
                NSDate* now =  [NSDate dateWithTimeIntervalSinceNow:0];
                (_taskAlertDateFirst == nil) ? (alertDateVC.defaultDate = now)
                                             : (alertDateVC.defaultDate = _taskAlertDateFirst);

                alertDateVC.isLaunchedForAlertDateFirst = YES;
            } else if (indexPath.row == 1) {
                NSDate* threeDaysAfterNow = [NSDate dateWithTimeIntervalSinceNow:3*86400];
                (_taskAlertDateSecond == nil) ? (alertDateVC.defaultDate = threeDaysAfterNow) 
                                              : (alertDateVC.defaultDate = _taskAlertDateSecond);
                alertDateVC.isLaunchedForAlertDateFirst = NO;
            }
            alertDateVC.delegate = self;
            [self.navigationController pushViewController:alertDateVC animated:YES];
            break;
        }
        case 2: //добавляется комментарий и контекст
        {
            switch (indexPath.row) {
                case 0:
                {
                    TextViewViewController* commentVC = [[TextViewViewController alloc]init];
                    commentVC.delegateTaskProperties = self;
                    commentVC.isAddingTaskComment = YES;
                    commentVC.textViewNameOrComment.text = _taskComment;
                    [self.navigationController pushViewController:commentVC animated:YES];
                    break;
                }   
                case 1:
                {
                    ContextsViewController* contextVC = [[ContextsViewController alloc]initWithStyle: UITableViewStyleGrouped];
                    contextVC.defaultContextName = _taskContext;
                    contextVC.delegate = self;
                    [self.navigationController pushViewController:contextVC animated:YES];
                    break;
                }
                default:
                    break;
            }
            break;
        }
    }
}


#pragma mark - SetNewTasksProperties protocol implementation
-(void) setTasksName: (NSString*)name
{
    _taskName = name;
    [self.tableView reloadData];
}

-(void) setTasksAlertDateFirst: (NSDate*)date
{
    _taskAlertDateFirst = date;
    if([_taskAlertDateFirst compare:_taskAlertDateSecond] == NSOrderedDescending){ 
        //значит 1ое напоминание позже 2ого. смещаем 2ое на два дня вперед с момента нового 1ого 
        _taskAlertDateSecond = [NSDate dateWithTimeInterval:2*86400 sinceDate:_taskAlertDateFirst];
    }
    [self.tableView reloadData];
}

-(void) setTasksAlertDateSecond: (NSDate*)date
{
    _taskAlertDateSecond = date;
    if([_taskAlertDateFirst compare:_taskAlertDateSecond] == NSOrderedDescending){ 
        //значит 1ое напоминание позже 2ого. смещаем 1ое на два дня назад с момента нового 2ого 
        _taskAlertDateFirst = [NSDate dateWithTimeInterval:-2*86400 sinceDate:_taskAlertDateSecond]; 
    }
    [self.tableView reloadData];
}

-(void) setTasksComment: (NSString*)comment
{
    _taskComment= comment;
    [self.tableView reloadData];
}
-(void) setTasksContext: (NSString*)context
{
    _taskContext = context;
    [self.tableView reloadData];
}


@end
