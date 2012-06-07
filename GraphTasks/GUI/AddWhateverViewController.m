//
//  AddWhateverViewController.m
//  GraphTasks
//
//  Created by Тимур Юсипов on 03.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TextViewViewController.h"
#import "AddWhateverViewController.h"
#import "AddSpecialTaskViewController.h"


#define TITLE_NORMAL @"Обычные задачи"
#define TITLE_SPECIAL @"Специальные задачи"

#define OPTION_FROM_CONTACT_LIST @"Выбрать из списка контактов"
#define OPTION_CREATE_NEW_CONTACT @"Создать новый контакт"
/*
 // 
 //Данный контроллер предлагает пользователю выбор того, что он хочет добавить: проект, обычное задание, или задание специального типа
 //
 */



@implementation AddWhateverViewController

@synthesize  parentProject = _parentProject,
            taskPhone , taskSMS, taskEmail, taskMap;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        NSArray* taskTypeNormal = [NSArray arrayWithObjects:@"Проект", @"Обычная", nil];
        NSArray* taskTypeSpecial = 
        [NSArray arrayWithObjects:@"Позвонить контакту", @"Отправить e-mail контакту", @"Отправить SMS контакту", @"Посетить место", nil];
        _tableData = [NSDictionary dictionaryWithObjectsAndKeys:
                      taskTypeNormal,TITLE_NORMAL,taskTypeSpecial,TITLE_SPECIAL,nil];
        _indexPathOfSelectedCell = [NSIndexPath indexPathForRow:-1 inSection:-1];
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

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

-(void)cancel
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"DismissModalController" object:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"projectOrTaskAddVCDidFinishWorkingWithNewProjectOrTask" object:nil];
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
    
    BOOL indexPathIsLastSelected = NO;
    indexPathIsLastSelected = (indexPath.row == _indexPathOfSelectedCell.row)&&
    (indexPath.section == _indexPathOfSelectedCell.section);
    //    cell.accessoryType = (indexPath==_indexPathOfSelectedCell) ? UITableViewCellAccessoryCheckmark 
    //    : UITableViewCellAccessoryDisclosureIndicator;
    cell.accessoryType = (indexPathIsLastSelected == YES) ? UITableViewCellAccessoryCheckmark 
    : UITableViewCellAccessoryNone; 
    
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
            
            cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
            cell.textLabel.numberOfLines = 0;
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
    _indexPathOfSelectedCell = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    if(indexPath.section==0){
        TextViewViewController* nameVC = [[TextViewViewController alloc]init]; 
        nameVC.parentProject = self.parentProject;
        nameVC.isAddingProjectName = (indexPath.row == 0);
        (indexPath.row == 0) ? (nameVC.isAddingProjectName = YES) : (nameVC.isAddingTaskName = YES);
        [self.navigationController pushViewController:nameVC animated:YES];
    } else {
        if (indexPath.row == 0) self.taskPhone = YES;
        else if (indexPath.row == 1) self.taskEmail = YES;
        else if (indexPath.row == 2) self.taskSMS = YES;
        else if (indexPath.row == 3) self.taskMap = YES;
        UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle: [[_tableData objectForKey: [[_tableData allKeys] objectAtIndex:indexPath.section]] objectAtIndex: indexPath.row] delegate:self cancelButtonTitle:@"Отмена" destructiveButtonTitle:nil otherButtonTitles: OPTION_FROM_CONTACT_LIST, OPTION_CREATE_NEW_CONTACT, nil];
        [actionSheet showInView:self.view];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    [self.tableView reloadData];
}




#pragma mark - ActionSheed Delegate methods

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0: //выбрать из списка контактов
            [self showPeoplePickerController];
            break;
        case 1: //создать новый контакт
            [self showNewPersonViewController];
            break;
        case 2: //отмена
            break;
        default:
            break;
    }
}

#pragma mark ABPeoplePickerNavigationControllerDelegate methods
// Displays the information of a selected person

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    
    //    код для редактирования записей. конфликт таков: если вернуть YES, то код до YES не имеет значения. В противном случае, код до YES выполнится, но метод 
    //    - (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
    //                       не вызовется совсем
    
    //    ABPersonViewController *picker = [[ABPersonViewController alloc] init];
    //    picker.personViewDelegate = self;
    //    picker.displayedPerson = person;
    //    
    //    picker.allowsEditing = YES;
    //    picker.navigationItem.rightBarButtonItem = picker.editButtonItem;
    //    [peoplePicker pushViewController:picker animated:YES];
	return YES;
}


// Does not allow users to perform default actions such as dialing a phone number, when they select a person property.
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    NSString *firstName = (__bridge NSString *)ABRecordCopyValue(person, 
                                                                 kABPersonFirstNameProperty);
    NSString *lastName = (__bridge NSString *)ABRecordCopyValue(person, 
                                                                kABPersonLastNameProperty);
    
    //формирование словаря доп информации
    NSString *key;
    NSMutableString *value;
    
    
    if (self.taskSMS) key = @"Отправить SMS";
    else if (self.taskPhone) key = @"Позвонить";
    else if (self.taskEmail) key = @"e-Mail";
    else if (self.taskMap) key = @"Место";
    
    if (self.taskSMS || self.taskPhone) {
        ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
        NSArray *phonenumbers = (__bridge NSArray* )ABMultiValueCopyArrayOfAllValues(phones);
        value = [NSString stringWithFormat:@"%@",[phonenumbers objectAtIndex:identifier]];
    } else if (self.taskEmail) {
        ABMultiValueRef mails = ABRecordCopyValue(person, kABPersonEmailProperty);
        NSArray *emails = (__bridge NSArray* )ABMultiValueCopyArrayOfAllValues(mails);
        value = [NSString stringWithFormat:@"%@",[emails objectAtIndex:identifier]];
    } else if (self.taskMap) {
        ABMultiValueRef adresses = ABRecordCopyValue(person, kABPersonAddressProperty);
        NSArray *adressesArray = (__bridge NSArray*)ABMultiValueCopyArrayOfAllValues(adresses);
        NSDictionary* choosenAdress = [adressesArray objectAtIndex:identifier];
        
        value = [NSMutableString new];
        for (NSString *key in choosenAdress.allKeys) {
            [value appendString:[choosenAdress objectForKey:key]];
            [value appendString:@", "];
        }
    }

    
    AddPropertiesViewController* addPropertiesVC = [[AddPropertiesViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    [addPropertiesVC setTasksName:[NSString stringWithFormat:@"%@ %@", firstName, lastName]];
    [addPropertiesVC setTasksKeyDescribingType:key AndItsValue:value];
    
    [addPropertiesVC setParentProject: self.parentProject];
    [addPropertiesVC setTaskSMS: self.taskSMS];
    [addPropertiesVC setTaskMail: self.taskEmail];
    [addPropertiesVC setTaskPhone:self.taskPhone];
    [addPropertiesVC setTaskMap:self.taskMap];
    
    [self dismissModalViewControllerAnimated:NO];
    [self.navigationController pushViewController:addPropertiesVC animated:YES];
	return NO;
}


// Dismisses the people picker and shows the application when users tap Cancel. 
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker;
{
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark ABPersonViewControllerDelegate methods
// Does not allow users to perform default actions such as dialing a phone number, when they select a contact property.
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person 
					property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue
{
	return NO;
}


#pragma mark ABNewPersonViewControllerDelegate methods
// Dismisses the new-person view controller. 
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person
{
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark - MyABMethos

-(void)showPeoplePickerController
{
	ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    
    NSMutableArray *displayedItems = [NSMutableArray new];
    if (self.taskPhone || self.taskSMS) {
        [displayedItems addObject:[NSNumber numberWithInt:kABPersonPhoneProperty]];
    } else if (self.taskEmail) {
        [displayedItems addObject:[NSNumber numberWithInt:kABPersonEmailProperty]];
    } else if (self.taskMap) {
        [displayedItems addObject:[NSNumber numberWithInt:kABPersonAddressProperty]];
    }
    
	picker.displayedProperties = displayedItems;
	[self presentModalViewController:picker animated:YES];
}

-(void)showNewPersonViewController
{
	ABNewPersonViewController *picker = [[ABNewPersonViewController alloc] init];
	picker.newPersonViewDelegate = self;
    
	UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:picker];
	[self presentModalViewController:navigation animated:YES];
}


@end