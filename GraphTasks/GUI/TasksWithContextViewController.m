//
//  TasksWithContextViewController.m
//  GraphTasks
//
//  Created by Тимур Юсипов on 30.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TasksWithContextViewController.h"
#import "NMTGTask.h"
#import "NMTGProject.h"

@implementation TasksWithContextViewController


@synthesize contextToFilterTasks = _contextToFilterTasks;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        //
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = ([self.contextToFilterTasks isEqualToString:@""]) ? (@"Без контекста") : (self.contextToFilterTasks);
    [self reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _tableDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    cell.textLabel.text = [[_tableDataSource objectAtIndex:indexPath.row] title];
    cell.detailTextLabel.text = [self fullPathToATask:[_tableDataSource objectAtIndex:indexPath.row]];
    if ([[[_tableDataSource objectAtIndex:indexPath.row] done] isEqualToNumber:[NSNumber numberWithBool:NO]]){
        cell.imageView.image = [UIImage imageNamed:@"task_30x30.png"];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"task_30x30_checked.png"];
    }
    
    return cell;
}

-(void) reloadData
{
    NSManagedObjectContext* managedContext = [[NMTaskGraphManager sharedManager] managedContext];
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"NMTGTask" inManagedObjectContext:managedContext];
    NSFetchRequest* request = [NSFetchRequest new];
    [request setEntity:entity];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"context == %@",self.contextToFilterTasks];
    [request setPredicate:predicate];
    
    _tableDataSource = [managedContext executeFetchRequest:request error:nil];
    [self.tableView reloadData];
    
}

-(NSString *)fullPathToATask:(NMTGTask *)aTask
{
    NSMutableString* res = [NSMutableString stringWithFormat:@"%@",aTask.title];
    NMTGProject* parent = aTask.parentProject;
    for(;;) {
        [res insertString:[NSString stringWithFormat:@"%@/",parent.title] atIndex:0];
        if (parent.parentProject == nil) {
            [res insertString:@"/" atIndex:0];
            break;
        } else {
            parent = parent.parentProject;
        }
    }
    return res;
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
