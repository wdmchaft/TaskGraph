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
#import "NMTGTaskLocation.h"
#import "NMTGTaskMail.h"
#import "NMTGTaskPhone.h"
#import "NMTGTaskSMS.h"
#import "AddWhateverViewController.h"
#import "AddPropertiesViewController.h"
#import "BadgedCell.h"

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
    _fetchedProjectsOrTasks = [NSMutableArray new];
    
    NSEntityDescription* entity1 = [NSEntityDescription entityForName:@"NMTGProject" inManagedObjectContext:_context]; 
    NSEntityDescription* entity6 = [NSEntityDescription entityForName:@"NMTGTask" inManagedObjectContext:_context];
    
    NSFetchRequest* request = [[NSFetchRequest alloc]init];
    [request setEntity:entity1];
    
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"parentProject == %@",self.parentProject];
    [request setPredicate:pred];
    
    NSSortDescriptor *sortdescriptor = [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:YES];
    NSArray *sortdescriptors = [NSArray arrayWithObject:sortdescriptor];
    [request setSortDescriptors:sortdescriptors];
    
    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:_context sectionNameKeyPath:nil cacheName:nil];
    
    //поиск проектов
    NSError* error = nil;
    if (! [controller performFetch: &error] ) {
        NSLog(@"Failed to perform fetch request in reloadData in TaskVC");
        NSLog(@"%@", error);
    }
    [_fetchedProjectsOrTasks addObjectsFromArray:controller.fetchedObjects];
    
    //поиск задач
    [request setEntity:entity6];
    error=nil;
    if (! [controller performFetch: &error] ) {
        NSLog(@"Failed to perform fetch request in reloadData in TaskVC");
        NSLog(@"%@", error);
    }
    [_fetchedProjectsOrTasks addObjectsFromArray: controller.fetchedObjects];
    
    
    self.parentProject.done = [NSNumber numberWithBool: [self checkProjectIsDone:self.parentProject]];
     error = nil;
    
    if (! [[[NMTaskGraphManager sharedManager] managedContext] save:&error ]) {
        NSLog(@"Failed to save context in 'reloadData' in TasksVC");
        NSLog(@"%@",error);
    }
    
    for(NMTGAbstract* obj in _fetchedProjectsOrTasks) {
        if (obj.class == [NMTGProject class]) {
            NMTGProject* proj = (NMTGProject*)obj;
            [self setProjectAlertDates:proj];
        }
    }
    [self.tableView reloadData];

}


-(BOOL) checkProjectIsDone:(NMTGProject *)aProject
{
    NSSet* subProjects = aProject.subProject;
    NSSet* subTasks = aProject.subTasks;
    
    if (subProjects.count + subTasks.count == 0) {
        return YES;
    }
    for(NMTGProject* proj in subProjects) {
        if ([self checkProjectIsDone:proj] == NO) {
            return NO;
        }    
    }
    
    NSArray* subTasksIndexed = [subTasks allObjects];
    for(int i=0; i<subTasksIndexed.count; i++){
        NMTGTask* task = [subTasksIndexed objectAtIndex:i];
        if([task.done isEqualToNumber:[NSNumber numberWithBool:NO]]){
            return NO;
        } 
    }
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HideModalControllerINFocusedVC" object:nil];
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

-(NSArray*)checkCompeletencyState:(NMTGProject *)proj
{
    NSMutableArray* res = [[NSMutableArray alloc]initWithCapacity:2];
    [res addObject: [NSNumber numberWithInt:0]];
    [res addObject: [NSNumber numberWithInt:0]];    
    
    
    if (proj.subProject.count != 0 ) {
        for (NMTGProject* _subproj in proj.subProject ) {
            NSArray* resReturnedBySubProjs = [self checkCompeletencyState:_subproj];
            [res replaceObjectAtIndex:0 withObject: [NSNumber numberWithInt: [[res objectAtIndex:0] intValue] + [[resReturnedBySubProjs objectAtIndex:0] intValue]]];
            [res replaceObjectAtIndex:1 withObject: [NSNumber numberWithInt: [[res objectAtIndex:1] intValue] + [[resReturnedBySubProjs objectAtIndex:1] intValue]]];
        }
    } 
    
    NSUInteger done = 0;
    NSUInteger undone = 0;
    for (NMTGTask* task in proj.subTasks) {
        if ([task.done isEqualToNumber:[NSNumber numberWithBool:YES]]) {done++;}
        else {undone++;}
    }
    
    [res replaceObjectAtIndex:0 withObject: [NSNumber numberWithInt: [[res objectAtIndex:0] intValue] + done]];
    [res replaceObjectAtIndex:1 withObject: [NSNumber numberWithInt: [[res objectAtIndex:1] intValue] + undone]];
    return res;
}

#pragma mark - Table view data source

-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
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
    BadgedCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NMTGAbstract* object = (NMTGAbstract*)[_fetchedProjectsOrTasks objectAtIndex:indexPath.row];
    if([object isKindOfClass:[NMTGProject class]]) {
        cell = [[BadgedCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell = (BadgedCell*) cell;
        cell.imageView.image = ([object.done isEqualToNumber:[NSNumber numberWithBool:NO]]) 
        ? ([UIImage imageNamed:@"case_30x30.png"])
        : ([UIImage imageNamed:@"case_30x30_checked.png"]);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        
        NSArray* arrayForCellDetailTextLabel = [self checkCompeletencyState:[_fetchedProjectsOrTasks objectAtIndex:indexPath.row]];
        cell.badgeString1 = [NSString stringWithFormat:@"%@", [arrayForCellDetailTextLabel objectAtIndex:1]];
        cell.badgeString3 = [NSString stringWithFormat:@"%@", [arrayForCellDetailTextLabel objectAtIndex:0]];
//        cell.badgeColor1 = [UIColor colorWithRed:0.712 green:0.712 blue:0.712 alpha:1.000];
//        cell.badgeColor3 = [UIColor colorWithRed:0.192 green:0.812 blue:0.100 alpha:1.000];

        cell.badgeColor1 = [UIColor colorWithRed:0.812 green:0.192 blue:0.100 alpha:1.000];
        cell.badgeColor3 = [UIColor colorWithRed:0.192 green:0.812 blue:0.100 alpha:1.000];

    } else {
        cell = [[BadgedCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        if([object isKindOfClass:[NMTGTaskMail class]]) {
            if ([object.done isEqualToNumber:[NSNumber numberWithBool:NO]]){
                cell.imageView.image = [UIImage imageNamed:@"mail_undone_30x30.png"];
            } else {
                cell.imageView.image = [UIImage imageNamed:@"mail_30x30.png"];
            }
        } else if([object isKindOfClass:[NMTGTaskSMS class]]) {
            if ([object.done isEqualToNumber:[NSNumber numberWithBool:NO]]){
                cell.imageView.image = [UIImage imageNamed:@"sms_undone_30x30.png"];
            } else {
                cell.imageView.image = [UIImage imageNamed:@"sms_30x30.png"];
            }
        } else if([object isKindOfClass:[NMTGTaskPhone class]]) {
            if ([object.done isEqualToNumber:[NSNumber numberWithBool:NO]]){
                cell.imageView.image = [UIImage imageNamed:@"call_undone_30x30.png"];
            } else {
                cell.imageView.image = [UIImage imageNamed:@"call_30x30.png"];
            }
        } else if([object isKindOfClass:[NMTGTask class]]) {
            if ([object.done isEqualToNumber:[NSNumber numberWithBool:NO]]){
                cell.imageView.image = [UIImage imageNamed:@"task_30x30.png"];
            } else {
                cell.imageView.image = [UIImage imageNamed:@"task_30x30_checked.png"];
            }
        } 
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
//        cell.editingAccessoryType = UITableViewCellAccessoryNone;
        
        NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:3*86400]];
        
        [formatter setDateStyle:NSDateFormatterLongStyle];
        [formatter setTimeStyle:NSDateFormatterNoStyle];
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ =-= %@",[formatter stringFromDate:object.alertDate_first],[formatter stringFromDate:object.alertDate_second]];
    }
    [[cell textLabel] setText:object.title];
    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.textLabel.numberOfLines = 0;
    cell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
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


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    
    NMTGAbstract* object = [_fetchedProjectsOrTasks objectAtIndex:indexPath.row]; 
    
    if ([object isKindOfClass:[NMTGProject class]]) {
        return 45.0f;
    }
    
    NSString *cellText = [object title];
    UIFont *cellTextFont = [UIFont fontWithName:@"Helvetica-Bold" size:22.0f];
    CGSize cellConstraintSize = CGSizeMake(320.0f, MAXFLOAT);
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:3*86400]];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    
    NSString *cellDetailText = [NSString stringWithFormat:@"%@ =-= %@", [formatter stringFromDate:object.alertDate_first], [formatter stringFromDate:object.alertDate_second]]; 
    UIFont *cellDetailTextFont = [UIFont fontWithName:@"Helvetica" size:15];
    
    CGSize labelSize = [cellText sizeWithFont:cellTextFont constrainedToSize:cellConstraintSize lineBreakMode:UILineBreakModeWordWrap];
    CGSize labelDetailSize = [cellDetailText sizeWithFont:cellDetailTextFont constrainedToSize:cellConstraintSize lineBreakMode:UILineBreakModeWordWrap];
    
    NSLog(@"%f", labelSize.height);
    NSLog(@"%f", labelDetailSize.height);
    
    if (labelSize.height + labelDetailSize.height < 45) { return 45.0;
    }
    return labelSize.height + labelDetailSize.height;
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
    if([selectedObject isKindOfClass:[NMTGProject class]]){
        _projectToRename = (NMTGProject*) selectedObject;
        TextViewViewController* textvc = [TextViewViewController new];
        textvc.isRenamingProject = YES;
        textvc.delegateProjectProperties = self;
        textvc.textViewNameOrComment.text = selectedObject.title;
        [self.navigationController pushViewController:textvc animated:YES];
    } else {
        AddPropertiesViewController* vc = [[AddPropertiesViewController alloc]initWithStyle:UITableViewStyleGrouped];
        NMTGTask* selectedTask = [_fetchedProjectsOrTasks objectAtIndex:indexPath.row];
        vc.taskToEdit = selectedTask;
        [vc setTasksKeyDescribingType:selectedTask.keyDescribingTaskType AndItsValue:selectedTask.valueForKeyDescribingTaskType];
        UINavigationController* nvc = [[UINavigationController alloc]initWithRootViewController:vc];
        [self presentModalViewController:nvc animated:YES];
    }
}
  







#pragma mark - Rubbish
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];    
    
    [self.navigationItem setTitle:(self.parentProject.title.length != 0) ? (self.parentProject.title) : (@"Корень")];
//    UIBarButtonItem* hide = [[UIBarButtonItem alloc]initWithTitle:@"Скрыть" style:UIBarButtonSystemItemFastForward target:self action:@selector(hide)];    
    
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
    _projectToRename.title = name;
    NSError* error = nil;
    if (![_context save:&error]) {
        NSLog(@"FAILED TO SAVE CONTEXT in TaskVC in setProjectsName:");
        NSLog(@"%@",error);
    }
    [self reloadData];
}


@end
