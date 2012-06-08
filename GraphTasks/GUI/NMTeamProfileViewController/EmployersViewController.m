//
//  EmployersViewController.m
//  GraphTasks
//
//  Created by Тимур Юсипов on 07.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmployersViewController.h"
#import "NMTaskGraphManager.h"
#import "JobPositionsViewController.h"

@implementation EmployersViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _tableDataSource = [NSMutableDictionary new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addingEmployerFinished) name:@"addingEmplyerFinishedSuccessfully" object:nil];
    
    UIBarButtonItem *plusButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addEmployer)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: self.editButtonItem, plusButtonItem,nil];
    self.navigationItem.title = @"Команда";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadData];
}

#pragma mark - My Methods

-(void) reloadData
{
    NSManagedObjectContext* context = [[NMTaskGraphManager sharedManager] managedContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NMTGJobPosition" inManagedObjectContext:context];
    NSFetchRequest* request = [NSFetchRequest new];
    [request setEntity:entity];
    
    NSError *error = nil;
    NSArray *allJobPositions = [context executeFetchRequest:request error:&error];
    for (NMTGJobPosition *jobpos in allJobPositions) {
        [_tableDataSource setObject: jobpos.workersOnThisPosition.allObjects 
                             forKey: jobpos.title];
    }
    [self.tableView reloadData];
}

-(void) addEmployer
{
    JobPositionsViewController* vc = [[JobPositionsViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentModalViewController:nvc animated:YES];
}

-(void) addingEmployerFinished
{
    [self reloadData];
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[_tableDataSource allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *allKeys = [_tableDataSource allKeys];
    NSString *particularKey = [allKeys objectAtIndex:section];
    return [[_tableDataSource objectForKey:particularKey] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    NSArray *allKeys = [_tableDataSource allKeys];
    NSString *particularKey = [allKeys objectAtIndex:indexPath.section];
    
    NMTeamProfile *person = [[_tableDataSource objectForKey:particularKey] objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat: @"%@ %@" , person.firstName, person.lastName ];
    
    return cell;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = [[_tableDataSource allKeys] objectAtIndex:section];
    return ([title isEqualToString: @""]) ? @"Без должности" : title; //возвращаем именования должностей
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
