//
//  FocusedAndContextedViewController.m
//  GraphTasks
//
//  Created by Тимур Юсипов on 02.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FocusedAndContextedViewController.h"
#import "NMTGTask.h"
#import "ProjectsViewController.h"

/*
 //
 // Данный контроллер вызывается для отображения заданий, разбитых на группы по временному критеию
 // "Просроченные", "Сегодня", "В течение недели" "В этом месяце", при этом фильтруя задания по контексту
 //
 */

#define TITLE_OVERDUE @"Просроченные"
#define TITLE_TODAY @"Сегодня"
#define TITLE_THIS_WEEK @"На этой неделе"
#define TITLE_THIS_MONTH @"В этом месяце"


@implementation FocusedAndContextedViewController

@synthesize contextToFilterTasks = _contextToFilterTasks;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _tableDataSource = [NSMutableDictionary new];
        _titles = [NSArray arrayWithObjects:TITLE_TODAY, TITLE_THIS_WEEK, TITLE_THIS_MONTH, TITLE_OVERDUE, nil];
        _contextToFilterTasks = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}


-(void)reloadData{
    NSManagedObjectContext* context = [[NMTaskGraphManager sharedManager]managedContext];
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"NMTGTask" inManagedObjectContext:context];
    
    NSFetchRequest* request = [[NSFetchRequest alloc]init];   
    [request setEntity:entity];
    
    NSPredicate* predicate = nil;
    if (self.contextToFilterTasks != nil) {
        predicate = [NSPredicate predicateWithFormat:@"context == %@", self.contextToFilterTasks];
    }
    if (predicate != nil) {
        [request setPredicate:predicate];
    }
    
    NSArray* allTasks = [context executeFetchRequest:request error:nil];
    for (NMTGTask* task in allTasks) {
        NSLog(@"%@ /*%@  %@",task.title, task.alertDate_first, task.alertDate_second);
    }
    
    
    NSDate* now = [[NSDate alloc]initWithTimeInterval:86400 sinceDate: [NSDate date]];
    
    NSTimeInterval secondssTilNow= [now timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:0]];
    int daysTilNow = (int)secondssTilNow/86400;
    
    NSDate* startDate = [NSDate dateWithTimeIntervalSince1970:(daysTilNow-1)*86400.0 + 86399.0];                                                                   
    NSDate* endDateToday = [[NSDate alloc]initWithTimeInterval:1*86400+1 sinceDate:startDate];
    NSDate* endDateThisWeek = [[NSDate alloc]initWithTimeInterval:6*86400+1 sinceDate:startDate];
    NSDate* endDateThisMonth = [[NSDate alloc]initWithTimeInterval:29*86400+1 sinceDate:startDate];
    
    
    NSMutableArray* todayTasks = [NSMutableArray new];
    NSMutableArray* weekTasks = [NSMutableArray new];
    NSMutableArray* monthTasks = [NSMutableArray new];
    
    for (NMTGTask* task in allTasks) {
        if ( ([task.alertDate_first compare:startDate] == NSOrderedDescending && 
              [task.alertDate_first compare:endDateToday] == NSOrderedAscending ) || 
            ([task.alertDate_second compare:startDate] == NSOrderedDescending && 
             [task.alertDate_second compare:endDateToday] == NSOrderedAscending )) {
                [todayTasks addObject:task];
            } else 
                if ( ([task.alertDate_first compare:startDate] == NSOrderedDescending && 
                      [task.alertDate_first compare:endDateThisWeek] == NSOrderedAscending ) || 
                    ([task.alertDate_second compare:startDate] == NSOrderedDescending && 
                     [task.alertDate_second compare:endDateThisWeek] == NSOrderedAscending )) {
                        [weekTasks addObject:task];
                    } else 
                        if ( ([task.alertDate_first compare:startDate] == NSOrderedDescending && 
                              [task.alertDate_first compare:endDateThisMonth] == NSOrderedAscending ) || 
                            ([task.alertDate_second compare:startDate] == NSOrderedDescending && 
                             [task.alertDate_second compare:endDateThisMonth] == NSOrderedAscending )) {
                                [monthTasks addObject:task];
                            }
        
    }
    [_tableDataSource setObject:todayTasks forKey:TITLE_TODAY];
    [_tableDataSource setObject:/*weekTasksWithoutTodayTasks*/weekTasks forKey:TITLE_THIS_WEEK ];
    [_tableDataSource setObject:/*monthTasksWithoutTodayAndWeekTasks*/monthTasks forKey:TITLE_THIS_MONTH];
    [self.tableView reloadData];
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.contextToFilterTasks != nil) {
        
        NSManagedObjectContext* context = [[NMTaskGraphManager sharedManager]managedContext];
        NSEntityDescription* entity = [NSEntityDescription entityForName:@"NMTGContext" inManagedObjectContext:context];
        NSFetchRequest* request = [NSFetchRequest new];
        [request setEntity:entity];
        NSArray* contextsUserMade = [context executeFetchRequest:request error:nil];
        
        NSMutableArray* allContexts = [NSMutableArray arrayWithObjects:@"Дом", @"Работа", @"Семья", @"", nil]; //пустая строка - для пустого контекста. В tableViewCell будет написано (без контекста)
        [allContexts addObjectsFromArray:contextsUserMade];
        if ([allContexts containsObject:self.contextToFilterTasks]) {
            self.navigationItem.title = ([self.contextToFilterTasks isEqualToString:@""]) 
                            ? (@"(Без контекста)") 
                            : (self.contextToFilterTasks);
        }
    } else {
          self.navigationItem.title = @"Текущие";     
    }
    [self reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [[_tableDataSource objectForKey:TITLE_TODAY] count];
            break;
        case 1:
            return [[_tableDataSource objectForKey:TITLE_THIS_WEEK] count];
            break;            
        case 2:
            return [[_tableDataSource objectForKey:TITLE_THIS_MONTH] count];
            break;
        case 3:
            return [[_tableDataSource objectForKey:TITLE_OVERDUE] count];
            break;            
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    NMTGTask* aTask;
    switch (indexPath.section) {
        case 0:
            aTask = [[_tableDataSource objectForKey:TITLE_TODAY] objectAtIndex:indexPath.row];
            cell.textLabel.text = [aTask title];
            break;
        case 1:
            aTask = [[_tableDataSource objectForKey:TITLE_THIS_WEEK] objectAtIndex:indexPath.row];
            cell.textLabel.text = [aTask title];
            break;
        case 2:
            aTask = [[_tableDataSource objectForKey:TITLE_THIS_MONTH] objectAtIndex:indexPath.row];
            cell.textLabel.text = [aTask title];
            break;
        case 3:
            aTask = [[_tableDataSource objectForKey:TITLE_OVERDUE] objectAtIndex:indexPath.row];
            cell.textLabel.text = [aTask title];
            break;            
        default:
            break;
    }
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",aTask.alertDate_first];
    if ([[aTask done] isEqualToNumber:[NSNumber numberWithBool:NO]]){
        cell.imageView.image = [UIImage imageNamed:@"task_30x30.png"];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"task_30x30_checked.png"];
    }
    
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
    
    NMTGTask* selectedTask = [[_tableDataSource objectForKey:[_titles objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row]; 
    NMTGProject* project = selectedTask.parentProject;
    for(;;){
        if (project.parentProject != nil) {
            project = project.parentProject;
        } else {
            break;
        }
    }
    NSLog(@"project: %@",project);
    ProjectsViewController* projectsVC = [[ProjectsViewController alloc]initWithStyle:UITableViewStylePlain];
    
    //    NSLog(@"projectsVC.selectedProject DO    :%@",projectsVC.selectedProject);    
    projectsVC.selectedProject = project;
    //    NSLog(@"projectsVC.selectedProject posle :%@",projectsVC.selectedProject);
    
    projectsVC.shouldPushEmidiately = YES;
    [self.navigationController pushViewController:projectsVC animated:YES];
}

-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            if ([[_tableDataSource objectForKey:TITLE_TODAY] count] > 0) {
                return TITLE_TODAY;
            } else return @"";
            break;
        case 1:
            if ([[_tableDataSource objectForKey:TITLE_THIS_WEEK] count] > 0) {            
                return TITLE_THIS_WEEK;
            } else return @"";
            break;
        case 2:
            if ([[_tableDataSource objectForKey:TITLE_THIS_MONTH] count] > 0) {            
                return TITLE_THIS_MONTH;
            } else return @"";
            break;
        case 3:
            if ([[_tableDataSource objectForKey:TITLE_OVERDUE] count] > 0) {            
                return TITLE_OVERDUE;
            } else return @"";
            break;
        default:
            return @"";
            break;
    }
}

@end
