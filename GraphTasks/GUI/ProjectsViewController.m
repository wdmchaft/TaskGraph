//
//  ProjectsViewController.m
//  GraphTasks
//
//  Created by Тимур Юсипов on 24.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProjectsViewController.h"
#import "NMTGProject.h"
#import "ProjectAddViewController.h"
#import "TaskViewController.h"
#import "AddWhateverViewController.h"
#import "TextViewViewController.h"


@interface ProjectsViewController (internal)
    -(void)addNewProject:(NMTGProject*) newProject;
    -(void)reloadData;
    -(void)ProjectAddViewControllerDidAddProject;
@end

@implementation ProjectsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [[[NMTaskGraphManager sharedManager]managedContext ]reset];
        _context = [[NMTaskGraphManager sharedManager] managedContext];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(ProjectAddViewControllerDidAddProject) name:@"DismissModalController" object:nil];
        }
    return self;
}


-(void) addNewProject{
    AddWhateverViewController* vc = [[AddWhateverViewController alloc]initWithStyle:UITableViewStyleGrouped];
    vc.parentProject = nil; //из текущего контроллера мы создаем проекты для верхнего уровня иерархии
    
    UINavigationController* nvc = [[UINavigationController alloc]initWithRootViewController:vc];
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
    _fetchedProjects = [_context executeFetchRequest:request error:&error];
    [self.tableView reloadData];
}





#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_fetchedProjects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ProjectsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NMTGProject* project = [_fetchedProjects objectAtIndex:indexPath.row]; 
        
    [[cell textLabel] setText: project.title];
    
    NSString *str = [project.alertDate_first description];
    [[cell  detailTextLabel]    setText:[NSString stringWithFormat:@"1st Alert Date: %@",str]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
//    if(indexPath.row && 1){
//        UISwitch* sw = [[UISwitch alloc] initWithFrame:CGRectMake(220, 8, 94, 27)];
//        sw.backgroundColor = [UIColor clearColor];
//        [cell.contentView addSubview:sw];
//    }
    NSLog(@"%@", project.done);
//    cell.imageView.image = (project.done == [NSNumber numberWithBool: NO]) 
//                                         ? ([UIImage imageNamed:@"case_30x30.png"])
//                                         : ([UIImage imageNamed:@"case_30x30_checked.png"]);
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
         NMTGProject* project = [_fetchedProjects objectAtIndex:indexPath.row];
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
    NMTGProject* selectedProject = [_fetchedProjects objectAtIndex:indexPath.row];
//    NSLog(@"selectedProject: %@",selectedProject);
    
//    NMTaskGraphManager* dataManager = [NMTaskGraphManager sharedManager];
//    dataManager.projectFantom = selectedProject;
//    NSLog(@"Project Fantom: %@",dataManager.projectFantom);
    
    TaskViewController* vc = [[TaskViewController alloc]initWithStyle:UITableViewStylePlain];
    vc.parentProject = selectedProject;
    [self.navigationController pushViewController:vc animated:YES];
}






-(void)viewWillAppear:(BOOL)animated{
    [super  viewWillAppear:animated];
    [self.tabBarController.navigationItem   setTitle:@"Проекты"];
    [self.navigationItem setTitle:@"Projects"];
    
    UIBarButtonItem* addbutton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewProject)];
    
    self.tabBarController.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.editButtonItem,addbutton, nil];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self reloadData];
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


@end