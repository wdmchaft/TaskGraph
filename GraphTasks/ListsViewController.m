//
//  ListsViewController.m
//  GraphTasks
//
//  Created by Тимур Юсипов on 03.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListsViewController.h"
#import "ProjectsViewController.h"

#define TITLE_REGULAR @"Обычные"
#define TITLE_CONTEXTED @"С контекстом"

/*
//
// Данный контроллер предлагает пользователю выбор типа списка проектов или заданий.
// "Все", "В фокусе" и различные контекстные списки
//
*/


@implementation ListsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        NSArray* regularTasks = [NSArray arrayWithObjects:@"Все", @"В фокусе", nil];
        NSArray* contextedTasks = [NSArray arrayWithObjects:@"Дом", @"Работа", @"Друзья", nil];
        _tableData = [NSDictionary dictionaryWithObjectsAndKeys:regularTasks,TITLE_REGULAR, contextedTasks, TITLE_CONTEXTED , nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_tableData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray* allKeys = [_tableData allKeys];
    NSString* particularKey = [allKeys objectAtIndex:section];
    return [[_tableData objectForKey:particularKey]count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        NSArray* allKeys = [_tableData allKeys];
        NSString* particularKey = [allKeys objectAtIndex:indexPath.section];
        NSArray* array = [_tableData objectForKey:particularKey];
        cell.textLabel.text = [array objectAtIndex:indexPath.row];
    }
    
    return cell;
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
    if((indexPath.section==0)&&(indexPath.row==0)){
        ProjectsViewController* pvc = [[ProjectsViewController alloc]init];
        [pvc setTabBarItem:[[UITabBarItem alloc]initWithTitle:@"Projects" image:nil tag:0]];
        
        UIViewController* VASILENKO_VIEW_CONTROLLER = [UIViewController new];
        [VASILENKO_VIEW_CONTROLLER setTabBarItem:[[UITabBarItem alloc]initWithTitle:@"VASILENKO" image:nil tag:0]];
        
        UITabBarController* tvc = [[UITabBarController alloc]init];
        [tvc setViewControllers:[NSArray arrayWithObjects:pvc, VASILENKO_VIEW_CONTROLLER, nil]];
        [self.navigationController pushViewController:tvc animated:YES];
    }
    if((indexPath.section==0)&&(indexPath.row==1)){
    
    }
}


@end
