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

#import "NMTGProject.h"
#import "NMTGTask.h"
#import "NMTGTaskLocation.h"
#import "NMTGTaskMail.h"
#import "NMTGTaskPhone.h"
#import "NMTGTaskSMS.h"

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
            taskToEdit = _taskToEdit, 
            taskMail = _taskMail, 
            taskSMS = _taskSMS, 
            taskPhone = _taskPhone;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _context = [[NMTaskGraphManager sharedManager] managedContext];
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
        _taskDeferred = [NSNumber numberWithBool:NO];
    } 
    if(self.taskToEdit != nil && self->_beganEditting == NO){
        _taskAlertDateFirst = self.taskToEdit.alertDate_first;
        _taskAlertDateSecond = self.taskToEdit.alertDate_second;
        _taskComment = self.taskToEdit.comment;
        _taskContext = self.taskToEdit.context;
        _taskName = self.taskToEdit.title;
        _taskKeyDescribingType = self.taskToEdit.keyDescribingTaskType;
        _taskValueForKeyDescribingType = self.taskToEdit.valueForKeyDescribingTaskType;
    }
    self->_beganEditting = YES; //в дальнейшем поля, только что проинициализированные, будут заполняться значенями, вводимыми пользователем
    
    
    NSMutableArray* arrayCommentAndContext = [NSMutableArray arrayWithObjects:@"Комментарий",@"Контекст", @"Отложенное", nil];
    NSArray* arrayAlertDates = [NSArray arrayWithObjects:@"Первое", @"Второе", nil];
    NSMutableArray* arrayName = [NSMutableArray arrayWithObjects:@"Имя", nil];
    if (_taskKeyDescribingType) {
        [arrayName addObject:_taskKeyDescribingType];
    }
    _tableDataSourse = [NSDictionary dictionaryWithObjectsAndKeys: arrayName, TITLE_NAME, arrayCommentAndContext,TITLE_COMMENT_AND_CONTEXT,arrayAlertDates,TITLE_ALERT_DATES,nil];
    
    
    _switch = [[UISwitch alloc]initWithFrame:CGRectMake(200, 10, 40, 30)];
    [_switch setOn:[_taskDeferred boolValue]];
    [_switch addTarget:self action:@selector(switchChanged) forControlEvents:UIControlEventTouchUpInside];
    [self.tableView reloadData];
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
        NMTGTask *_newTask;
        if (self.isTaskMail) {
            _newTask = [[NMTGTaskMail alloc]initWithEntity:[NSEntityDescription entityForName:@"NMTGTaskMail" inManagedObjectContext:_context] insertIntoManagedObjectContext:_context];
            [_context insertObject:_newTask];
        } else if (self.isTaskSMS) {
            _newTask = [[NMTGTaskSMS alloc]initWithEntity:[NSEntityDescription entityForName:@"NMTGTaskSMS" inManagedObjectContext:_context] insertIntoManagedObjectContext:_context];
            [_context insertObject:_newTask];
        } else if (self.isTaskPhone) {
            _newTask = [[NMTGTaskPhone alloc]initWithEntity:[NSEntityDescription entityForName:@"NMTGTaskPhone" inManagedObjectContext:_context] insertIntoManagedObjectContext:_context];
            [_context insertObject:_newTask];
        } else {
            _newTask = [[NMTGTask alloc]initWithEntity:[NSEntityDescription entityForName:@"NMTGTask" inManagedObjectContext:_context] insertIntoManagedObjectContext:_context];
            [_context insertObject:_newTask];
        }
        _newTask.title = _taskName;
        _newTask.alertDate_first = _taskAlertDateFirst;
        _newTask.alertDate_second = _taskAlertDateSecond;
        _newTask.comment = _taskComment;
        _newTask.context = _taskContext;
        _newTask.done = [NSNumber numberWithBool:NO];
        _newTask.created = [NSDate date];
        _newTask.deferred = _taskDeferred;
        _newTask.keyDescribingTaskType = _taskKeyDescribingType;
        _newTask.valueForKeyDescribingTaskType = _taskValueForKeyDescribingType;

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
        _taskToEdit.deferred = _taskDeferred;
    }
    
    NSError* error = nil;
    if(! ([_context save:&error ]) ){
        NSLog(@"%@",error);
        NSLog(@"Failed to save context in AddPropertiesVC in 'save'");
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"projectOrTaskAddVCDidFinishWorkingWithNewProjectOrTask" 
                                                       object:nil];
}

-(void) cancel
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"projectOrTaskAddVCDidFinishWorkingWithNewProjectOrTask" 
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
            cell.detailTextLabel.text = (indexPath.row == 0) ? _taskName : _taskValueForKeyDescribingType;
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
        }
        case 1: //даты напоминаний
        {
            NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
            formatter.dateStyle = NSDateFormatterFullStyle;
            cell.detailTextLabel.text = (indexPath.row == 0) 
                        ? ([formatter stringFromDate: _taskAlertDateFirst]) 
                        : ([formatter stringFromDate: _taskAlertDateSecond]);
            break;
        }
        case 2: //комментарий и контекст
        {
            cell.detailTextLabel.text = (indexPath.row == 0) 
                            ? /*([_taskComment isEqualToString:@""]) ? ( @"(Без комментария)")
                                                                   :*/ (_taskComment)
                            : ([_taskContext isEqualToString:@""]) ? ( @"(Без контекста)")
                                                                   : (_taskContext);
            if (indexPath.row == 2) {
                [cell.contentView addSubview:_switch];
                cell.detailTextLabel.text = @"";
            }
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
        case 0: //редактирование имени задания
        {
            if (indexPath.row == 0) {
                TextViewViewController* textViewVC = [TextViewViewController new];
                textViewVC.delegateTaskProperties = self;
                textViewVC.isRenamingTask = YES;
                textViewVC.textViewNameOrComment.text = _taskName;
                [self.navigationController pushViewController:textViewVC animated:YES];
            } else {
                [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
            break;
        }
        case 1: //добавляется дата напоминания
        {
            AlertDateViewController* alertDateVC = [[AlertDateViewController alloc]init];
            if (indexPath.row == 0) {
                NSDate* now =  [NSDate dateWithTimeIntervalSinceNow:0];
                (_taskAlertDateFirst == nil) ? (alertDateVC.defaultDatePickerDate = now)
                                             : (alertDateVC.defaultDatePickerDate = _taskAlertDateFirst);

                alertDateVC.isLaunchedForAlertDateFirst = YES;
            } else if (indexPath.row == 1) {
                NSDate* threeDaysAfterNow = [NSDate dateWithTimeIntervalSinceNow:3*86400];
                (_taskAlertDateSecond == nil) ? (alertDateVC.defaultDatePickerDate = threeDaysAfterNow) 
                                              : (alertDateVC.defaultDatePickerDate = _taskAlertDateSecond);
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

-(void)switchChanged
{
    _taskDeferred = [NSNumber numberWithBool:_switch.on];
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
    
    NSDate* modified_alert_First = [NSDate dateWithTimeIntervalSince1970:((int)([_taskAlertDateFirst timeIntervalSince1970]/86400)) * (86400.0) + 1];
    NSDate* modified_alert_Second = [NSDate dateWithTimeIntervalSince1970:((int)([_taskAlertDateSecond timeIntervalSince1970]/86400)) * (86400.0) + 1];
    if([modified_alert_First compare:modified_alert_Second] == NSOrderedDescending){ 
        //значит 1ое напоминание позже 2ого. смещаем 2ое на два дня вперед с момента нового 1ого 
        _taskAlertDateSecond = [NSDate dateWithTimeInterval:2*86400 sinceDate:_taskAlertDateFirst];
    }
    [self.tableView reloadData];
}

-(void) setTasksAlertDateSecond: (NSDate*)date
{
    _taskAlertDateSecond = date;
    
    NSDate* modified_alert_First = [NSDate dateWithTimeIntervalSince1970:((int)([_taskAlertDateFirst timeIntervalSince1970]/86400)) * (86400.0)];
    NSDate* modified_alert_Second = [NSDate dateWithTimeIntervalSince1970:((int)([_taskAlertDateSecond timeIntervalSince1970]/86400)) * (86400.0)];
    if([modified_alert_First compare:modified_alert_Second] == NSOrderedDescending){ 
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

-(void)setTasksDeferred:(NSNumber *)isDeferred
{
    _taskDeferred = isDeferred;
}

-(void) setTasksKeyDescribingType:(NSString *)key AndItsValue:(NSString *)value
{
    _taskKeyDescribingType = key;
    _taskValueForKeyDescribingType = value;
}
@end
