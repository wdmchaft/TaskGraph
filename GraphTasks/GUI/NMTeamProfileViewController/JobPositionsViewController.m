//
//  JobPositionsViewController.m
//  GraphTasks
//
//  Created by Тимур Юсипов on 07.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JobPositionsViewController.h"
#import "TextViewViewController.h"

@implementation JobPositionsViewController

@synthesize delegate = _delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _indexPathOfLastSelectedRow = [NSIndexPath indexPathForRow:-1 inSection:-1];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Должность";
    
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addJobPostion)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: self.editButtonItem, add,nil];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Отмена" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancel;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
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

#pragma mark - MyMethods

-(void) reloadData
{
    NSManagedObjectContext* context = [[NMTaskGraphManager sharedManager] managedContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NMTGJobPosition" inManagedObjectContext:context];
    NSFetchRequest* request = [NSFetchRequest new];
    [request setEntity:entity];
    
    NSError *error = nil;
    _tableDataSource = [context executeFetchRequest:request error:&error];
    
    [self.tableView reloadData];
}

-(void) addJobPostion
{
    TextViewViewController * textVC = [TextViewViewController new];
    textVC.delegateJobPositions = self;
    textVC.isAddingJobPositionName = YES;
    [self.navigationController pushViewController:textVC animated:YES];
}

-(void) cancel
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addingEmplyerFinishedSuccessfully" object:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_tableDataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSString *cellTitle = [[_tableDataSource objectAtIndex:indexPath.row] title];
    cell.textLabel.text = ([cellTitle isEqualToString:@""]) ? @"Без должности" : cellTitle;
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


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [[NMTaskGraphManager sharedManager] managedContext];
        NMTGJobPosition *job = [_tableDataSource objectAtIndex: indexPath.row];
        NSLog(@"%@", [job description]);
        [context deleteObject:job];
        
        NSError *error = nil;
        if (! [context save:&error] ) {
            NSLog(@"Failed to save context in JobPositionsVC in 'tableView:CommitEditingStyle:' ");
            NSLog(@"error: %@", error);
        }
        [self reloadData];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


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
    TextViewViewController *vc = [TextViewViewController new];
    
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Выберите должность";
}

#pragma maek - JobPositionsDelegate implementation
-(void) createNewJobPositionWithName:(NSString *)name
{
    NSManagedObjectContext* context = [[NMTaskGraphManager sharedManager] managedContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NMTGJobPosition" inManagedObjectContext:context];
    NMTGJobPosition *newJob = [[NMTGJobPosition alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
    [context insertObject:newJob];
    
    newJob.title = name;
    
    NSError *error = nil;
    if (! [context save:&error]) {
        NSLog(@"Failed to save context in JobPositionsVC in 'createNewJobPositionWithName:' ");
        NSLog(@"error: %@", error);
    }
    [self reloadData];
}

@end
