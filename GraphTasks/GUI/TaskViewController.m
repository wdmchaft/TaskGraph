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
    
    for(NMTGAbstract* obj in _fetchedProjectsOrTasks) {
        if (obj.class == [NMTGProject class]) {
            NMTGProject* proj = (NMTGProject*)obj;
            [self setProjectAlertDates:proj];
        }
    }
    
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





-(void) hide
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"HideModalControllerINFocusedVC" object:nil];
}

-(void)setProjectAlertDates:(NMTGProject *)proj{
    NSArray* subTasks = [proj.subTasks allObjects];
    NSArray* subProjs = [proj.subProject allObjects];
    NSDate* mindateTasks = [NSDate date];
    NSDate* maxdateTasks = [NSDate date];
    for (NMTGTask* task in subTasks) {
        if ([mindateTasks timeIntervalSince1970] > [task.alertDate_first timeIntervalSince1970] ) {
            mindateTasks = task.alertDate_first;
        }
        if ([maxdateTasks timeIntervalSince1970] < [task.alertDate_second timeIntervalSince1970] ) {
            maxdateTasks = task.alertDate_second;
        }
    }
    
    NSDate* mindateProjs = [NSDate date];
    NSDate* maxdateProjs = [NSDate date];
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
    
    NMTGAbstract* object = (NMTGAbstract*)[_fetchedProjectsOrTasks objectAtIndex:indexPath.row];
    if([object isKindOfClass:[NMTGProject class]]) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.imageView.image = ([object.done isEqualToNumber:[NSNumber numberWithBool:NO]]) 
        ? ([UIImage imageNamed:@"case_30x30.png"])
        : ([UIImage imageNamed:@"case_30x30_checked.png"]);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        NSArray* arrayForCellDetailTextLabel = [self checkCompeletencyState:[_fetchedProjectsOrTasks objectAtIndex:indexPath.row]];
        cell.detailTextLabel.text = [NSString stringWithFormat: @"сделано %@(%@)", [arrayForCellDetailTextLabel objectAtIndex:0], [arrayForCellDetailTextLabel objectAtIndex:1]] ;
        
    }
    if([object isKindOfClass:[NMTGTask class]]) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        if ([object.done isEqualToNumber:[NSNumber numberWithBool:NO]]){
            cell.imageView.image = [UIImage imageNamed:@"task_30x30.png"];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"task_30x30_checked.png"];
        }
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        
        NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:3*86400]];
        
        [formatter setDateStyle:NSDateFormatterLongStyle];
        [formatter setTimeStyle:NSDateFormatterNoStyle];
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ =-= %@",[formatter stringFromDate:object.alertDate_first],[formatter stringFromDate:object.alertDate_second]];
    }
    [[cell textLabel] setText:object.title];  
    
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
  

-(NSArray*)checkCompeletencyState:(NMTGProject *)proj
{
    NSFetchRequest* request = [NSFetchRequest new];
    NSManagedObjectContext* context =  [[NMTaskGraphManager sharedManager]managedContext];
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"NMTGTask" inManagedObjectContext:context];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"parentProject == %@",proj];
    NSArray* resultsOfFetchExec;
    
    [request setEntity:entity];
    [request setPredicate:predicate];
    resultsOfFetchExec = [context executeFetchRequest:request error:nil];
    NSMutableArray* res = [[NSMutableArray alloc]initWithCapacity:2];
    [res addObject: [NSNumber numberWithInt:0]];
    [res addObject: [NSNumber numberWithInt:0]];      
    
    NSLog(@"proj,subp.count: %i",proj.subProject.count);
    if (proj.subProject.count != 0 ) {
        for (NMTGProject* _subproj in proj.subProject ) {
            NSArray* resReturnedBySubProjs = [self checkCompeletencyState:_subproj];
            NSLog(@"resBySubs: %@",resReturnedBySubProjs);
            [res replaceObjectAtIndex:0 withObject: [NSNumber numberWithInt: [[res objectAtIndex:0] intValue] + [[resReturnedBySubProjs objectAtIndex:0] intValue]]];
            [res replaceObjectAtIndex:1 withObject: [NSNumber numberWithInt: [[res objectAtIndex:1] intValue] + [[resReturnedBySubProjs objectAtIndex:1] intValue]]];
        }
    } 
    NSLog(@"res: %@",res);
    
    NSUInteger done = 0;
    for (NMTGTask* task in resultsOfFetchExec) {
        if ([task.done isEqualToNumber:[NSNumber numberWithBool:YES]]) {done++;}
    }
    
    [res replaceObjectAtIndex:0 withObject: [NSNumber numberWithInt: [[res objectAtIndex:0] intValue] + done]];
    [res replaceObjectAtIndex:1 withObject: [NSNumber numberWithInt: [[res objectAtIndex:1] intValue] + resultsOfFetchExec.count]];
    
    return res;
}





#pragma mark - Rubbish
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationItem setTitle:self.parentProject.title];
    UIBarButtonItem* hide = [[UIBarButtonItem alloc]initWithTitle:@"Скрыть" style:UIBarButtonSystemItemFastForward target:self action:@selector(hide)];    
    
//NSLog(@"pathComponents.count: %i",[NMTaskGraphManager sharedManager].pathComponents.count);
    if ([NMTaskGraphManager sharedManager].pathComponents.count == 0) {
        [self reloadData];
        return;
    } else if ([NMTaskGraphManager sharedManager].pathComponents.count == 1) {
//self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:self.navigationItem.backBarButtonItem, hide, nil];
        
        NSUInteger row = 0;
        for (NMTGTask* task in _fetchedProjectsOrTasks) {
            if ([task.title isEqualToString:[[NMTaskGraphManager sharedManager].pathComponents objectAtIndex:0]] ) {
                break;
            } else {
                row++;
            }
        }
        [[NMTaskGraphManager sharedManager].pathComponents removeObjectAtIndex:0];
        [self reloadData];
        [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]] setHighlighted:YES animated:YES];
    } else {
        NSUInteger row = 0;
        for (NMTGProject* proj in _fetchedProjectsOrTasks) {
            if ([proj.title isEqualToString:[[NMTaskGraphManager sharedManager].pathComponents objectAtIndex:0]] ) {
                break;
            } else {
                row++;
            }
        }
        [[NMTaskGraphManager sharedManager].pathComponents removeObjectAtIndex:0];
//        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:self.navigationItem.backBarButtonItem, hide, nil];
        [self reloadData];
        [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    }
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
