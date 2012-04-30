//
//  AddWhateverViewController.m
//  GraphTasks
//
//  Created by Тимур Юсипов on 03.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TextViewViewController.h"
#import "AddWhateverViewController.h"


#define TITLE_NORMAL @"Обычные задачи"
#define TITLE_SPECIAL @"Специальные задачи"
/*
// 
//Данный контроллер предлагает пользователю выбор того, что он хочет добавить: проект, обычное задание, или задание специального типа
//
*/
@interface AddWhateverViewController(internal)
    -(void)save;
    -(void)cancel;
@end



@implementation AddWhateverViewController

@synthesize  parentProject = _parentProject;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        NSArray* taskTypeNormal = [NSArray arrayWithObjects:@"Проект", @"Обычная", nil];
        NSArray* taskTypeSpecial = 
            [NSArray arrayWithObjects:@"Позвонить контакту", @"Отправить e-mail контакту", @"Отправить SMS контакту", @"Посетить место", nil];
        _tableData = [NSDictionary dictionaryWithObjectsAndKeys:
            taskTypeNormal,TITLE_NORMAL,taskTypeSpecial,TITLE_SPECIAL,nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Тип задачи";
    UIBarButtonItem* cancel = [[UIBarButtonItem alloc]initWithTitle:@"Отмена" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancel;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)cancel
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"DismissModalController" object:nil];
}

//###################################################################################################
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_tableData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray* allKeys = [_tableData allKeys];
    NSString* particularKey = [allKeys objectAtIndex:section];
    NSArray* arrayForKey = [_tableData objectForKey:particularKey];
    return [arrayForKey count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:CellIdentifier];
    }
    NSArray* allKeys = [_tableData allKeys];
    NSString* particularKey = [allKeys objectAtIndex:indexPath.section];
    NSArray* cellDataSourse = [_tableData objectForKey:particularKey];
    
    cell.textLabel.text = [cellDataSourse objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    cell.imageView.image = [UIImage imageNamed:@"case_30x30.png"];
                    break;
                }
                case 1:
                {
                    cell.imageView.image = [UIImage imageNamed:@"galochka_30x30.png"];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                {
                    cell.imageView.image = [UIImage imageNamed:@"call_30x30.png"];
                    break;
                }
                case 1:
                {
                    cell.imageView.image = [UIImage imageNamed:@"mail_30x30.png"];
                    break;
                }
                case 2:
                {
                    cell.imageView.image = [UIImage imageNamed:@"sms_30x30.png"];
                    break;
                }
                case 3:
                {
                    cell.imageView.image = [UIImage imageNamed:@"map_30x30.png"];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return TITLE_NORMAL;
            break;
        case 1:
            return TITLE_SPECIAL;
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
    if(indexPath.section==0){
        TextViewViewController* nameVC = [[TextViewViewController alloc]init]; 
        nameVC.parentProject = self.parentProject;
        nameVC.isAddingProjectName = (indexPath.row == 0);
        (indexPath.row == 0) ? (nameVC.isAddingProjectName = YES) : (nameVC.isAddingTaskName = YES);
        [self.navigationController pushViewController:nameVC animated:YES];
    }
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
