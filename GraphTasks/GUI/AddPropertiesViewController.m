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

@synthesize projectName = _projectName,
            projectAlertDateFirst = _projectAlertDateFirst,
            projectAlertDateSecond = _projectAlertDateSecond,
            projectComment = _projectComment,
            projectContext = _projectContext,
            isAddingProject = _isAddingProject,
            parentProject = _parentProject;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _context = [[NMTaskGraphManager sharedManager]managedContext];
        
        NSArray* arrayCommentAndContext = [NSArray arrayWithObjects:@"Комментарий",@"Контекст", nil];
        NSArray* arrayAlertDates = [NSArray arrayWithObjects:@"Первое",@"Второе", nil];
        NSArray* arrayName = [NSArray arrayWithObjects:@"Имя", nil];
        
        _tableDataSourse = [NSDictionary dictionaryWithObjectsAndKeys: arrayName, TITLE_NAME, arrayCommentAndContext,TITLE_COMMENT_AND_CONTEXT,arrayAlertDates,TITLE_ALERT_DATES,nil];
        
        self.projectAlertDateFirst = [NSDate dateWithTimeIntervalSinceNow:86400];
        self.projectAlertDateSecond = [NSDate dateWithTimeIntervalSinceNow:3*86400];
        self.projectComment = @"";
        self.projectContext = @"";
    }
    return self;
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    NSLog(@"AddPropsVC: name: %@",self.projectName);
//    NSLog(@"AddPropsVC: alertDate1: %@",self.projectAlertDateFirst);
//    NSLog(@"AddPropsVC: alertDate2: %@",self.projectAlertDateSecond);
//    NSLog(@"AddPropsVC: comment: %@",self.projectComment);

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


-(void) save
{    
    NMTGTask* _newTask = [[NMTGTask alloc]initWithEntity:[NSEntityDescription entityForName:@"NMTGTask" inManagedObjectContext:_context] insertIntoManagedObjectContext:_context];
    [_context insertObject:_newTask];
    
    
    _newTask.title = self.projectName;
    _newTask.alertDate_first = self.projectAlertDateFirst;
    _newTask.alertDate_second = self.projectAlertDateSecond;
    _newTask.comment = self.projectComment;
    _newTask.done = [NSNumber numberWithBool:NO];

    
    if(_parentProject == nil){NSLog(@"NILL PARENT PROJ IN ADDPROPERTIES vc");}
    [_parentProject addSubTasksObject:_newTask];
    [_newTask setParentProject:_parentProject];
    
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
//    if(!cell){
        (cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier]);
        
        NSArray* allKeys = [_tableDataSourse allKeys];
        NSString* particularKey = [allKeys objectAtIndex:indexPath.section];  
        NSArray* cellDataSourse = [_tableDataSourse objectForKey:particularKey];
        cell.textLabel.text = [cellDataSourse objectAtIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        switch (indexPath.section) {
            case 0:
            {
                cell.detailTextLabel.text = self.projectName;
                
                cell.accessoryType = UITableViewCellAccessoryNone;
                _textFieldName = [[UITextField alloc]init];
                _textFieldName.frame = CGRectMake(70, 10, 150, 40);
                _textFieldName.returnKeyType = UIReturnKeyDone;
                _textFieldName.delegate = self;
                _textFieldName.clearButtonMode = UITextFieldViewModeNever;
                [cell.contentView addSubview:_textFieldName];
                break;
            }
            case 1:
            {
                NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
                formatter.dateStyle = NSDateFormatterLongStyle;
                cell.detailTextLabel.text = (indexPath.row == 0) 
                                ? ([formatter stringFromDate: self.projectAlertDateFirst]) 
                                : ([formatter stringFromDate: self.projectAlertDateSecond]);
                break;
            }
            case 2:
            {
                cell.detailTextLabel.text = (indexPath.row == 0) 
                                ? (self.projectComment) 
                                : (self.projectContext);
                break;
            }
            default:
                break;
        }
//    }
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


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"%@",textField.text);
    if([textField.text length]>0) {
        self.projectName = textField.text;   
    } 
    [textField resignFirstResponder];
    [self.tableView reloadData];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.text = self.projectName;
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
    switch (indexPath.section){
        case 0:
        {
            [_textFieldName becomeFirstResponder];
            [[tableView cellForRowAtIndexPath:indexPath] setHighlighted:NO];
            break;
        }
        case 1:
        {
            AlertDateViewController* alertDateVC = [[AlertDateViewController alloc]init];
            alertDateVC.superVC = self;
            
            (indexPath.row == 0) ? (alertDateVC.isLaunchedForAlertDateFirst = YES) : (alertDateVC.isLaunchedForAlertDateFirst = NO);
            [self.navigationController pushViewController:alertDateVC animated:YES];
            break;
        }
        case 2:
        {
            switch (indexPath.row) {
                case 0:
                {
                    TextViewViewController* commentVC = [[TextViewViewController alloc]init];
                    commentVC.superVC = self;
                    commentVC.isSentToEnterName = NO;
                    [self.navigationController pushViewController:commentVC animated:YES];
                    break;
                }   
                default:
                    break;
            }
            break;
        }
    }
}

@end
