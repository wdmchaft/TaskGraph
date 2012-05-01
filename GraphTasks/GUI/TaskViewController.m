//
//  TaskViewController.m
//  GraphTasks
//
//  Created by Тимур Юсипов on 25.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TaskViewController.h"
#import "TextViewViewController.h"
#import "NMTGAbstract.h"
#import "NMTGTask.h"
#import "AddWhateverViewController.h"
#import "AddPropertiesViewController.h"

@implementation TaskViewController

@synthesize parentProject = _parentProject;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _plusOrSettingsButtonItem = [ [UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewProjectOrTask)];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.editButtonItem, _plusOrSettingsButtonItem, nil];
        
        _context = [[NMTaskGraphManager sharedManager]managedContext];
        
        [[NSNotificationCenter defaultCenter]
                         addObserver:self 
                            selector:@selector(projectOrTaskAddViewControllerDidAddProjectOrTask) 
                                name:@"projectOrTaskAddVCDidFinishWorkingWithNewProjectOrTask" 
                              object:nil];
        
        _fetchedProjectsOrTasks =[NSMutableArray arrayWithArray:[self.parentProject.subTasks allObjects]];
        [_fetchedProjectsOrTasks addObjectsFromArray:[self.parentProject.subProject allObjects]];
        
        self.tableView.allowsSelectionDuringEditing = YES;
    }
    return self;
}


-(void)reloadData{
    NSEntityDescription* entity1 = [NSEntityDescription entityForName:@"NMTGProject" inManagedObjectContext:_context]; 
    
    NSEntityDescription* entity2 = [NSEntityDescription entityForName:@"NMTGTask" inManagedObjectContext:_context];
    
    NSFetchRequest* request = [[NSFetchRequest alloc]init];
    [request setEntity:entity1];
    
//    NMTaskGraphManager* dataManager = [NMTaskGraphManager sharedManager];
//    
//    NSPredicate* pred = [NSPredicate predicateWithFormat:@"parentProject == %@",dataManager.projectFantom];
    
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"parentProject == %@",self.parentProject];
    [request setPredicate:pred];
    
    NSError* error = nil;
    _fetchedProjectsOrTasks = [NSMutableArray arrayWithArray:[_context executeFetchRequest:request error:&error]];
    
    [request setEntity:entity2];
    error=nil;
    [_fetchedProjectsOrTasks addObjectsFromArray:[_context executeFetchRequest:request error:&error]];
    
    [self.tableView reloadData];

}


-(BOOL) checkProjectIsDone:(NMTGProject *)aProject
{
    NSSet* subProjects = aProject.subProject;
    NSSet* subTasks = aProject.subTasks;
    
    for(NMTGProject* proj in subProjects) {
        if ([self checkProjectIsDone:proj] == NO) {
            NSLog(@"'if1' returned NO");
            return NO;
        }    
    }
    
    NSArray* subTasksIndexed = [subTasks allObjects];
    for(int i=0; i<subTasksIndexed.count; i++){
        NMTGTask* task = [subTasksIndexed objectAtIndex:i];
        if([task.done isEqualToNumber:[NSNumber numberWithBool:NO]]){
            NSLog(@"'if2' returned NO");
            return NO;
        } 
    }
    NSLog(@"returned YES");
    return YES;
}


-(void)addNewProjectOrTask{
    AddWhateverViewController* vc = [[AddWhateverViewController alloc]initWithStyle:UITableViewStyleGrouped];
    vc.parentProject = self.parentProject;
    
    UINavigationController* nvc = [[UINavigationController alloc]initWithRootViewController:vc];
    [self presentModalViewController:nvc animated:YES];
}

-(void)changeCurrentProjectsSettings
{
    TextViewViewController* textVC = [[TextViewViewController alloc]init];
    textVC.delegateProjectProperties = self;
    textVC.isRenamingProject = YES;
    textVC.textViewNameOrComment.text = self.parentProject.title;
    [self.navigationController pushViewController:textVC animated:YES];
}

-(void) projectOrTaskAddViewControllerDidAddProjectOrTask{
    [self reloadData];
    [self dismissModalViewControllerAnimated:YES];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationItem setTitle:self.parentProject.title];
    [self reloadData];
}

#pragma mark - Table view data source

-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    if (editing == YES) {
        _plusOrSettingsButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"settings_25x25.png"] style:UIBarStyleDefault target:self action:@selector(changeCurrentProjectsSettings)];
    } else {
        _plusOrSettingsButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewProjectOrTask)];
    } 
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.editButtonItem, _plusOrSettingsButtonItem, nil];
}

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
    NMTGAbstract* object = (NMTGAbstract*)[_fetchedProjectsOrTasks objectAtIndex:indexPath.row];
    if([object isKindOfClass:[NMTGProject class]]) {
        cell.imageView.image = ([object.done isEqualToNumber:[NSNumber numberWithBool:NO]]) 
        ? ([UIImage imageNamed:@"case_30x30.png"])
        : ([UIImage imageNamed:@"case_30x30_checked.png"]);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if([object isKindOfClass:[NMTGTask class]]) {
//        NSLog(@"OBJECT DONE : %@", object.done);
        if ([object.done isEqualToNumber:[NSNumber numberWithBool:NO]]){
            cell.imageView.image = [UIImage imageNamed:@"task_30x30.png"];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"task_30x30_checked.png"];
        }
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    [[cell textLabel] setText:object.title];  
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:3*86400]];
    
    [formatter setDateStyle:NSDateFormatterLongStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    
     cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ =-= %@",[formatter stringFromDate:object.alertDate_first],[formatter stringFromDate:object.alertDate_second]];
    return cell;
}

//NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
//[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
//
//NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:118800];
//
//NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
//[dateFormatter setLocale:usLocale];
//
//NSLog(@"Date for locale %@: %@",
//      [[dateFormatter locale] localeIdentifier], [dateFormatter stringFromDate:date]);
//// Output:
//// Date for locale en_US: Jan 2, 2001







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
    NMTGAbstract* selectedObject = [_fetchedProjectsOrTasks objectAtIndex:indexPath.row];
    
    if([selectedObject isKindOfClass:[NMTGProject class]]){
        TaskViewController* vc = [[TaskViewController alloc]initWithStyle:UITableViewStylePlain];
        vc.parentProject = [_fetchedProjectsOrTasks objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    if([selectedObject isKindOfClass:[NMTGTask class]]){
        if ([selectedObject.done isEqualToNumber:[NSNumber numberWithBool:YES]]) {
            selectedObject.done = [NSNumber numberWithBool:NO];
        } else {
            selectedObject.done = [NSNumber numberWithBool:YES];
        }
        
        NSError* error = nil;
        if(!([_context save:&error])){
            NSLog(@"FAILED TO SAVE CONTEXT IN TASK VC IN 'didSelectRowAtIndexPath'");
            NSLog(@"%@",error);
        }
        
        //блок проверки заверешен ли проект
        NMTGProject* parent_project = [[_fetchedProjectsOrTasks objectAtIndex:indexPath.row] parentProject];
        parent_project.done = [NSNumber numberWithBool: [self checkProjectIsDone:parent_project]];

        error = nil;
        if(!([_context save:&error])){
            NSLog(@"FAILED TO SAVE CONTEXT IN TASK VC IN 'didSelectRowAtIndexPath'");
            NSLog(@"%@",error);
        }
        [self reloadData];
    }
}



-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NMTGAbstract* selectedObject = [_fetchedProjectsOrTasks objectAtIndex:indexPath.row];
    if([selectedObject isKindOfClass:[NMTGTask class]]){
        AddPropertiesViewController* vc = [[AddPropertiesViewController alloc]initWithStyle:UITableViewStyleGrouped];
        vc.taskToEdit = [_fetchedProjectsOrTasks objectAtIndex:indexPath.row];
        UINavigationController* nvc = [[UINavigationController alloc]initWithRootViewController:vc];
        [self presentModalViewController:nvc animated:YES];
    }
}
  





#pragma mark - Rubbish
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

#pragma mark - SetNewTasksProperties protocol implementation
-(void)setProjectsName:(NSString *)name
{
    _parentProject.title = name;
    NSError* error = nil;
    if (![_context save:&error]) {
        NSLog(@"FAILED TO SAVE CONTEXT in TaskVC in setProjectsName:");
        NSLog(@"%@",error);
    }
    [self reloadData];
}


@end
