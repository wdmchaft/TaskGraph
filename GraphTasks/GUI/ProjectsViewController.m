//
//  ProjectsViewController.m
//  GraphTasks
//
//  Created by Тимур Юсипов on 24.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProjectsViewController.h"
#import "NMTGProject.h"
#import "NMTGAbstract.h"
#import "NMTGTask.h"
#import "TaskViewController.h"
#import "AddWhateverViewController.h"
#import "TextViewViewController.h"


@implementation ProjectsViewController

@synthesize selectedProject = _selectedProject;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [[[NMTaskGraphManager sharedManager]managedContext ]reset];
        _context = [[NMTaskGraphManager sharedManager] managedContext];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(ProjectAddViewControllerDidAddProject) name:@"DismissModalController" object:nil];
        
        self.tableView.allowsSelectionDuringEditing = YES;
    }
    return self;
}


-(void) addNewProject{
//    AddWhateverViewController* vc = [[AddWhateverViewController alloc]initWithStyle:UITableViewStyleGrouped];
//    vc.parentProject = nil; //из текущего контроллера мы создаем проекты для верхнего уровня иерархии
//    
//    UINavigationController* nvc = [[UINavigationController alloc]initWithRootViewController:vc];
//    [self presentModalViewController:nvc animated:YES];
    
    TextViewViewController* nameVC = [[TextViewViewController alloc]init]; 
    nameVC.parentProject = nil;
    nameVC.isAddingProjectName = YES;
    UINavigationController* nvc = [[UINavigationController alloc]initWithRootViewController:nameVC];
    [self presentModalViewController:nvc animated:YES];
}



-(void)ProjectAddViewControllerDidAddProject
{
    [self reloadData];
    [self dismissModalViewControllerAnimated:YES];
}

-(void) reloadData{
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"NMTGProject"inManagedObjectContext:_context];
    
    NSFetchRequest* request = [[NSFetchRequest alloc]init];
    [request setEntity:entity];
    
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"parentProject==nil"];
    [request setPredicate:pred];
    
    
    
    NSError* error = nil;
    _tableDataSource = [_context executeFetchRequest:request error:&error];
    for (NMTGProject* proj in _tableDataSource) {
        [self setProjectAlertDates:proj];
    }
    [self.tableView reloadData];
}

-(void)setProjectAlertDates:(NMTGProject *)proj{
    NSArray* subTasks = [proj.subTasks allObjects];
    NSArray* subProjs = [proj.subProject allObjects];
    NSDate* mindateTasks = [NSDate dateWithTimeIntervalSinceNow:10000*86400];
    NSDate* maxdateTasks = [NSDate dateWithTimeIntervalSince1970:0];
    for (NMTGTask* task in subTasks) {
        if ([mindateTasks timeIntervalSince1970] > [task.alertDate_first timeIntervalSince1970] ) {
            mindateTasks = task.alertDate_first;
        }
        if ([maxdateTasks timeIntervalSince1970] < [task.alertDate_second timeIntervalSince1970] ) {
            maxdateTasks = task.alertDate_second;
        }
    }
    
    NSDate* mindateProjs = [NSDate dateWithTimeIntervalSinceNow:10000*86400];
    NSDate* maxdateProjs = [NSDate dateWithTimeIntervalSince1970:0];
    for (NMTGProject* proj in subProjs) {
        if ([mindateProjs timeIntervalSince1970] > [proj.alertDate_first timeIntervalSince1970] ) {
            mindateProjs = proj.alertDate_first;
        }
        if ([maxdateProjs timeIntervalSince1970] < [proj.alertDate_second timeIntervalSince1970] ) {
            maxdateProjs = proj.alertDate_second;
        }
    }
    NSDate* mindate = ([mindateTasks timeIntervalSince1970] < [mindateProjs timeIntervalSince1970]) ? (mindateTasks) : (mindateProjs) ;
    NSDate* maxdate = ([maxdateTasks timeIntervalSince1970] > [maxdateProjs timeIntervalSince1970]) ? (maxdateTasks) : (maxdateProjs);
    
    
    proj.alertDate_first = mindate;
    proj.alertDate_second = maxdate;
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
    static NSString *CellIdentifier = @"ProjectsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NMTGProject* project = [_tableDataSource objectAtIndex:indexPath.row]; 
        
    [[cell textLabel] setText: project.title];
    
    NSString *str = [project.alertDate_first description];
    [[cell  detailTextLabel]    setText:[NSString stringWithFormat:@"1st Alert Date: %@",str]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.imageView.image = ([project.done isEqualToNumber:[NSNumber numberWithBool:NO]]) 
                                         ? ([UIImage imageNamed:@"case_30x30.png"])
                                         : ([UIImage imageNamed:@"case_30x30_checked.png"]);
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:3*86400]];
    
    [formatter setDateStyle:NSDateFormatterLongStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ =-= %@",[formatter stringFromDate:project.alertDate_first],[formatter stringFromDate:project.alertDate_second]];
    return cell;
}


 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
     return YES;
 }
 


 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
     if (editingStyle == UITableViewCellEditingStyleDelete) {
         // Delete the row from the data source
         NMTGProject* project = [_tableDataSource objectAtIndex:indexPath.row];
         [_context deleteObject:project];
         
         NSError* eror = nil;
         if(!([_context save:&eror])){
             NSLog(@"Failed to save context in ProjectsViewController. //in 'commitEdittingStyle' ");
         }
         else{
             [self reloadData];
         }
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.tableView.isEditing == YES){
        TextViewViewController* textVC = [TextViewViewController new];
        textVC.delegateProjectProperties = self;
        textVC.isRenamingProject = YES;
        textVC.textViewNameOrComment.text = _selectedProject.title;
        [self.navigationController pushViewController:textVC animated:YES];
    } else {
        _selectedProject = [_tableDataSource objectAtIndex:indexPath.row];
        TaskViewController* vc = [[TaskViewController alloc]initWithStyle:UITableViewStylePlain];
        vc.parentProject = _selectedProject;
        [self.navigationController pushViewController:vc animated:YES];
    }
}






-(void)viewWillAppear:(BOOL)animated{
    [super  viewWillAppear:animated];
    [self reloadData];
    
    BOOL shouldPushEmmediately = ([NMTaskGraphManager sharedManager].pathComponents.count != 0);
    if (shouldPushEmmediately == NO) { 
        [self reloadData];
    } else {
        UIBarButtonItem* hide = [[UIBarButtonItem alloc]initWithTitle:@"Скрыть" style:UIBarButtonItemStylePlain target:self action:@selector(hide)];
        self.navigationItem.leftBarButtonItem = hide;
        int row = 0;
        for (NMTGProject* proj in _tableDataSource) {
            if ([proj.title isEqualToString:[[NMTaskGraphManager sharedManager].pathComponents objectAtIndex:0]] == NO ){
                    row++;
            } else {
                    break;
            }
        }
        NSLog(@"row: %i",row);
        [[NMTaskGraphManager sharedManager].pathComponents removeObjectAtIndex:0];
        [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    }
    [self.tabBarController.navigationItem   setTitle:@"Проекты"];
    [self.navigationItem setTitle:@"Projects"];
    
    UIBarButtonItem* addbutton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewProject)];
    
    self.tabBarController.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.editButtonItem,addbutton, nil];
}

-(void) hide
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"HideModalControllerINFocusedVC" object:nil];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return (interfaceOrientation !=UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - SetNewTasksProperties protocol implementation
-(void)setProjectsName:(NSString *)name
{
    _selectedProject.title = name;
    NSError* error = nil;
    if (![_context save:&error]) {
        NSLog(@"FAILED TO SAVE CONTEXT in TaskVC in setProjectsName:");
        NSLog(@"%@",error);
    }
    [self reloadData];
}

@end