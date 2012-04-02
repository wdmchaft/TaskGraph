//
//  TaskViewController.m
//  GraphTasks
//
//  Created by Тимур Юсипов on 25.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TaskViewController.h"
#import "NMTGAbstract.h"
#import "NMTGTask.h"
#import "ProjectOrTaskAddViewController.h"

@interface TaskViewController ()

@end

@implementation TaskViewController



- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        UIBarButtonItem* addbutton = [[UIBarButtonItem alloc]
                 initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                      target:self 
                                      action:@selector(addNewProjectOrTask)];
        
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.editButtonItem, addbutton, nil];
        
        [self.navigationItem setTitle:@"Tasks"];
    }
    
    
    _context = [[NMTaskGraphManager sharedManager]managedContext];
    
    [[NSNotificationCenter defaultCenter]
                     addObserver:self 
                        selector:@selector(projectOrTaskAddViewControllerDidAddProjectOrTask) 
                            name:@"projectOrTaskAddVCDidFinishWorkingWithNewProjectOrTask" 
                          object:nil];
    NMTaskGraphManager* dataManager = [NMTaskGraphManager sharedManager];
    
    
    _fetchedProjectsOrTasks =[NSMutableArray arrayWithArray:[ dataManager.projectFantom.subTasks allObjects]];
    [_fetchedProjectsOrTasks addObjectsFromArray:[dataManager.projectFantom.subProject allObjects]];
    
    [self reloadData];
    return self;
}


-(void)reloadData{
    NSEntityDescription* entity1 = [NSEntityDescription entityForName:@"NMTGProject" inManagedObjectContext:_context]; 
    
    NSEntityDescription* entity2 = [NSEntityDescription entityForName:@"NMTGTask" inManagedObjectContext:_context];
    
    NSFetchRequest* request = [[NSFetchRequest alloc]init];
    [request setEntity:entity1];
    
    NMTaskGraphManager* dataManager = [NMTaskGraphManager sharedManager];
    
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"parentProject == %@",dataManager.projectFantom];
    [request setPredicate:pred];
    
    NSError* error = nil;
    _fetchedProjectsOrTasks = [NSMutableArray arrayWithArray:[_context executeFetchRequest:request error:&error]];
    
    [request setEntity:entity2];
    error=nil;
    [_fetchedProjectsOrTasks addObjectsFromArray:[_context executeFetchRequest:request error:&error]];
    
    [self.tableView reloadData];

}


-(void)addNewProjectOrTask{
    ProjectOrTaskAddViewController* vc = [[ProjectOrTaskAddViewController alloc]init];
    
    NMTaskGraphManager* dataManager = [NMTaskGraphManager sharedManager];
    vc.parentProject = dataManager.projectFantom;
    
    UINavigationController* nvc = [[UINavigationController alloc]initWithRootViewController:vc];
    [self presentModalViewController:nvc animated:YES];
}


-(void) projectOrTaskAddViewControllerDidAddProjectOrTask{
    [self reloadData];
    [self dismissModalViewControllerAnimated:YES];
    //and push?
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [_fetchedProjectsOrTasks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = @"ProjectsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NMTGAbstract* object = (NMTGAbstract*)[_fetchedProjectsOrTasks objectAtIndex:indexPath.row];

    [[cell textLabel] setText:object.title];  
//    [[cell detailTextLabel] setText:[object.alertDate_first description]];
    
    NSString *str = [object.comment description];
//    NSString *str = [object.alertDate_second description];
//    [[cell  detailTextLabel]    setText:[NSString stringWithFormat:@"2d Alert Date: %@",str]];
    [[cell  detailTextLabel]    setText:[NSString stringWithFormat:@"comment: %@",str]];
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NMTGAbstract* object = [_fetchedProjectsOrTasks objectAtIndex:indexPath.row];
        [_context deleteObject:object];
        
        NSError* error = nil;
        if(!([_context save:&error])){
            NSLog(@"Failed to save context in TaskViewController in 'commit editting style' ");
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NMTGProject* selectedProject = [_fetchedProjectsOrTasks objectAtIndex:indexPath.row];
    //    NSLog(@"selectedProject: %@",selectedProject);
    
    NMTaskGraphManager* dataManager = [NMTaskGraphManager sharedManager];
    dataManager.projectFantom = selectedProject;
    //    NSLog(@"Project Fantom: %@",dataManager.projectFantom);
    
    TaskViewController* vc = [[TaskViewController alloc]initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:vc animated:YES];
    
}









- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}
@end
