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
#import "AddWhateverViewController.h"


@implementation TaskViewController

@synthesize parentProject = _parentProject;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        UIBarButtonItem* addbutton = [ [UIBarButtonItem alloc]
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
    
    _fetchedProjectsOrTasks =[NSMutableArray arrayWithArray:[self.parentProject.subTasks allObjects]];
    [_fetchedProjectsOrTasks addObjectsFromArray:[self.parentProject.subProject allObjects]];
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


-(void)addNewProjectOrTask{
//    ProjectOrTaskAddViewController* vc = [[ProjectOrTaskAddViewController alloc]init];
//    
//    NMTaskGraphManager* dataManager = [NMTaskGraphManager sharedManager];
//    vc.parentProject = dataManager.projectFantom;
    AddWhateverViewController* vc = [[AddWhateverViewController alloc]initWithStyle:UITableViewStyleGrouped];
    vc.parentProject = self.parentProject;
    
    UINavigationController* nvc = [[UINavigationController alloc]initWithRootViewController:vc];
    [self presentModalViewController:nvc animated:YES];
}


-(void) projectOrTaskAddViewControllerDidAddProjectOrTask{
    [self reloadData];
    [self dismissModalViewControllerAnimated:YES];
    //and push?
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self reloadData];
    NSLog(@"TASK VC~~~~~~~~~~~~~ %@",self.parentProject);
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
    if([object isKindOfClass:[NMTGProject class]]) {
        cell.imageView.image = [UIImage imageNamed:@"galochka_30x30.png"];
    }
    if([object isKindOfClass:[NMTGTask class]]) {
        cell.imageView.image = [UIImage imageNamed:@"case_30x30.png"];
    }
    [[cell textLabel] setText:object.title];  
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:3*86400]];
    [formatter setShortStandaloneWeekdaySymbols:[NSArray arrayWithObjects:@"ПН", @"ВТ", @"СР", @"ЧТ", @"ПТ", @"СБ", @"ВС", nil]];
//    [formatter setShortMonthSymbols:[NSArray arrayWithObjects: @"Янв", @"Фев", @"Март", @"Апр", @"Май", @"Июнь", @"Июль", @"Авг", @"Сент", @"Окт", @"Ноя", @"Дек" nil]
    [formatter setStandaloneMonthSymbols:[NSArray arrayWithObjects: @"Январь", @"Февраль", @"Март", @"Апрель", @"Май", @"Июнь", @"Июль", @"Август", @"Сентябрь", @"Октябрь", @"Ноябрь", @"Декабрь", nil]];
    
    [formatter setDateStyle:NSDateFormatterLongStyle];
    [formatter setTimeStyle:NSDateFormatterLongStyle];
    
    [[cell  detailTextLabel] setText:[NSString stringWithFormat:@"%@",[formatter stringFromDate:object.alertDate_first]]];
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
    NMTGProject* selectedObject = [_fetchedProjectsOrTasks objectAtIndex:indexPath.row];
    //    NSLog(@"selectedProject: %@",selectedProject);
    
//    NMTaskGraphManager* dataManager = [NMTaskGraphManager sharedManager];
//    dataManager.projectFantom = selectedProject;
    //    NSLog(@"Project Fantom: %@",dataManager.projectFantom);
    
    if([selectedProject isKindOfClass:[NMTGProject class]]){
        TaskViewController* vc = [[TaskViewController alloc]initWithStyle:UITableViewStylePlain];
        vc.parentProject = selectedObject;
        [self.navigationController pushViewController:vc animated:YES];
    }
    if([selectedObject isKindOfClass:[NMTGTask class]]){
        //Переход в меню настройки параметров задания
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
@end
