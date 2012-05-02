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
    NSPredicate* predicate;
    
    if (_shouldShowOnlyUnDone == YES) {
        predicate = [NSPredicate predicateWithFormat:@"done == FALSE"];  
        if (self.contextToFilterTasks != nil) {
            predicate = [NSPredicate predicateWithFormat:@"(done == FALSE) && (context == %@)", self.contextToFilterTasks];
        }
    } else {
        predicate = nil; 
        if (self.contextToFilterTasks != nil) {
            predicate = [NSPredicate predicateWithFormat:@"context == %@", self.contextToFilterTasks];
        }
    }
    if (predicate != nil) {
        [request setPredicate:predicate];       
    }
    NSArray* allTasks = [context executeFetchRequest:request error:nil];
    
    
    
    
    NSDate* now = [[NSDate alloc]initWithTimeInterval:86400 sinceDate: [NSDate date]];
    
    NSTimeInterval secondssTilNow= [now timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:0]];
    int daysTilNow = (int)secondssTilNow/86400;
    
    NSDate* startDate = [NSDate dateWithTimeIntervalSince1970:daysTilNow*86400.0];                                                                   
    NSDate* endDateToday = [[NSDate alloc]initWithTimeInterval:1*86400 sinceDate:startDate];
    NSDate* endDateThisWeek = [[NSDate alloc]initWithTimeInterval:7*86400 sinceDate:startDate];
    NSDate* endDateThisMonth = [[NSDate alloc]initWithTimeInterval:30*86400 sinceDate:startDate];
    
    
    NSMutableArray* todayTasks = [NSMutableArray new];
    NSMutableArray* weekTasks = [NSMutableArray new];
    NSMutableArray* monthTasks = [NSMutableArray new];
    NSMutableArray* overdueTasks = [NSMutableArray new];
    
    NSMutableArray* todayTasksColors = [NSMutableArray new];
    NSMutableArray* weekTasksColors = [NSMutableArray new];
    NSMutableArray* monthTasksColors = [NSMutableArray new];
    NSMutableArray* overdueTasksColors = [NSMutableArray new];    
    
    NSMutableArray* todayFormattedTaskDates = [NSMutableArray new];
    NSMutableArray* weekFormattedTaskDates = [NSMutableArray new];
    NSMutableArray* monthFormattedTaskDates = [NSMutableArray new];
    NSMutableArray* overdueFormattedTaskDates = [NSMutableArray new]; 
    
    for (NMTGTask* task in allTasks) {
        bool closestIsAlertFirst = NO;
        bool closestIsAlertSecond = NO;
        float ratio;
        NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:3*86400]];
        [formatter setDateStyle:NSDateFormatterLongStyle];
        [formatter setTimeStyle:NSDateFormatterNoStyle];
        
        if ((closestIsAlertFirst  = ([task.alertDate_first compare:startDate] == NSOrderedDescending && 
                                     [task.alertDate_first compare:endDateToday] == NSOrderedAscending )) || 
            (closestIsAlertSecond = ([task.alertDate_second compare:startDate] == NSOrderedDescending && 
                                     [task.alertDate_second compare:endDateToday] == NSOrderedAscending ))) 
        {
            [todayTasks addObject:task]; //сегодняшние
            if (closestIsAlertFirst == YES) {
                ratio = [task.alertDate_first timeIntervalSinceNow] / [task.alertDate_first timeIntervalSinceDate:task.created];
                [todayTasksColors addObject:[UIColor colorWithRed:1-ratio green:ratio blue:0.0 alpha:1.0]];
//                NSLog(@"ratio: %f",ratio);
//                NSLog(@"added color: %@", [todayTasksColors lastObject]);
                
                NSString* formattedDate = [NSString stringWithFormat:@"Первое: %@",[formatter stringFromDate:task.alertDate_first]];
                [todayFormattedTaskDates addObject:formattedDate];
            } else {
                ratio = [task.alertDate_second timeIntervalSinceNow] / [task.alertDate_second timeIntervalSinceDate:task.created];
                [todayTasksColors addObject:[UIColor colorWithRed:1-ratio green:0 blue:ratio alpha:1.0]];
//                NSLog(@"ratio: %f",ratio);
//                NSLog(@"added color: %@", [todayTasksColors lastObject]);
                
                NSString* formattedDate = [NSString stringWithFormat:@"Второе: %@",[formatter stringFromDate:task.alertDate_second]];
                [todayFormattedTaskDates addObject:formattedDate];
            }
        } else 
        if ((closestIsAlertFirst  = ([task.alertDate_first compare:startDate] == NSOrderedDescending && 
                                     [task.alertDate_first compare:endDateThisWeek] == NSOrderedAscending )) || 
            (closestIsAlertSecond = ([task.alertDate_second compare:startDate] == NSOrderedDescending && 
                                     [task.alertDate_second compare:endDateThisWeek] == NSOrderedAscending ))) {
            [weekTasks addObject:task]; //недельные
            if (closestIsAlertFirst == YES) {

                ratio = [task.alertDate_first timeIntervalSinceNow] / [task.alertDate_first timeIntervalSinceDate:task.created];
                [weekTasksColors addObject:[UIColor colorWithRed:1-ratio green:ratio blue:0.0 alpha:1.0]];
//                NSLog(@"ratio: %f",ratio);
//                NSLog(@"added color: %@", [weekTasksColors lastObject]);
                
                NSString* formattedDate = [NSString stringWithFormat:@"Первое: %@",[formatter stringFromDate:task.alertDate_first]];
                [weekFormattedTaskDates addObject:formattedDate];
            } else {
                ratio = [task.alertDate_second timeIntervalSinceNow] / [task.alertDate_second timeIntervalSinceDate:task.created];
                [weekTasksColors addObject:[UIColor colorWithRed:1-ratio green:0 blue:ratio alpha:1.0]];
//                NSLog(@"ratio: %f",ratio);
//                NSLog(@"added color: %@", [weekTasksColors lastObject]);
                
                NSString* formattedDate = [NSString stringWithFormat:@"Второе: %@",[formatter stringFromDate:task.alertDate_second]];
                [weekFormattedTaskDates addObject:formattedDate];
            }
        } else 
        if ((closestIsAlertFirst  = ([task.alertDate_first compare:startDate] == NSOrderedDescending && 
                                     [task.alertDate_first compare:endDateThisMonth] == NSOrderedAscending )) || 
            (closestIsAlertSecond = ([task.alertDate_second compare:startDate] == NSOrderedDescending && 
                                     [task.alertDate_second compare:endDateThisMonth] == NSOrderedAscending ))) {
            [monthTasks addObject:task]; //месячные
            if (closestIsAlertFirst == YES) {
                ratio = [task.alertDate_first timeIntervalSinceNow] / [task.alertDate_first timeIntervalSinceDate:task.created];
                [monthTasksColors addObject:[UIColor colorWithRed:1-ratio green:ratio blue:0.0 alpha:1.0]];
//                NSLog(@"ratio: %f",ratio);
//                NSLog(@"added color: %@", [monthTasksColors lastObject]);
                
                NSString* formattedDate = [NSString stringWithFormat:@"Первое: %@",[formatter stringFromDate:task.alertDate_first]];
                [monthFormattedTaskDates addObject:formattedDate];
            } else {
                ratio = [task.alertDate_second timeIntervalSinceNow] / [task.alertDate_second timeIntervalSinceDate:task.created];
                [monthTasksColors addObject:[UIColor colorWithRed:1-ratio green:0 blue:ratio alpha:1.0]];
//                NSLog(@"ratio: %f",ratio);
//                NSLog(@"added color: %@", [monthTasksColors lastObject]);
                NSString* formattedDate = [NSString stringWithFormat:@"Второе: %@",[formatter stringFromDate:task.alertDate_second]];
                [monthFormattedTaskDates addObject:formattedDate];
            }
        } else 
        if ( [task.alertDate_first compare:startDate] == NSOrderedAscending && 
             [task.alertDate_second compare:startDate] == NSOrderedAscending ) {
            [overdueTasks addObject:task]; //просроченные
            [overdueTasksColors addObject:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]];
            NSString* formattedDate = [NSString stringWithFormat:@"Просроченное: %@",[formatter stringFromDate:task.alertDate_second]];
            [overdueFormattedTaskDates addObject:formattedDate];
        } 

    }
    
    
    [_tableDataSource setObject:[NSArray arrayWithObjects:todayTasks, todayTasksColors, todayFormattedTaskDates,nil] forKey:TITLE_TODAY];
    [_tableDataSource setObject:[NSArray arrayWithObjects:weekTasks, weekTasksColors, weekFormattedTaskDates, nil] forKey:TITLE_THIS_WEEK ];
    [_tableDataSource setObject:[NSArray arrayWithObjects:monthTasks, monthTasksColors, monthFormattedTaskDates, nil] forKey:TITLE_THIS_MONTH];
    [_tableDataSource setObject:[NSArray arrayWithObjects:overdueTasks, overdueTasksColors, overdueFormattedTaskDates, nil] forKey:TITLE_OVERDUE];
    [self.tableView reloadData];
    
    NSString* title = (_shouldShowOnlyUnDone == YES) ? @"Все" : @"Без готовых";
    _showAllOrShowUnDoneOnly = [[UIBarButtonItem alloc]initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(showAllOrShowUnDoneOnlyClicked)];
    self.navigationItem.rightBarButtonItem = _showAllOrShowUnDoneOnly;
}



- (void)viewDidUnload
{
    [super viewDidUnload];
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

-(void) showAllOrShowUnDoneOnlyClicked
{
    _shouldShowOnlyUnDone = !_shouldShowOnlyUnDone;
    [self reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //запись по ключу имеет вид "МассивОбъектов, МассивЦветовСтрокДляТаблицы, МассивФорматированныхДатНапоминаний", поэтому " objectAtIndex:0]"
    switch (section) {
        case 0:
            return [[[_tableDataSource objectForKey:TITLE_TODAY] objectAtIndex:0] count];
            break;
        case 1:
            return [[[_tableDataSource objectForKey:TITLE_THIS_WEEK] objectAtIndex:0] count];
            break;            
        case 2:
            return [[[_tableDataSource objectForKey:TITLE_THIS_MONTH] objectAtIndex:0] count];
            break;
        case 3:
            return [[[_tableDataSource objectForKey:TITLE_OVERDUE] objectAtIndex:0] count];
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
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    NMTGTask* aTask;
    UIColor* aColor;
    NSString* formatedDate;
    //запись по ключу имеет вид "МассивОбъектов, МассивЦветовСтрокДляТаблицы", поэтому " objectAtIndex:0]"
    switch (indexPath.section) {
        case 0:
            aTask = [[[_tableDataSource objectForKey:TITLE_TODAY] objectAtIndex:0] objectAtIndex:indexPath.row];
            aColor = [[[_tableDataSource objectForKey:TITLE_TODAY] objectAtIndex:1] objectAtIndex:indexPath.row];
            formatedDate = [[[_tableDataSource objectForKey:TITLE_TODAY] objectAtIndex:2] objectAtIndex:indexPath.row];
            cell.textLabel.text = [aTask title];
            break;
        case 1:
            aTask = [[[_tableDataSource objectForKey:TITLE_THIS_WEEK] objectAtIndex:0] objectAtIndex:indexPath.row];
            cell.textLabel.text = [aTask title];
            aColor = [[[_tableDataSource objectForKey:TITLE_THIS_WEEK] objectAtIndex:1] objectAtIndex:indexPath.row];   
            formatedDate = [[[_tableDataSource objectForKey:TITLE_THIS_WEEK] objectAtIndex:2] objectAtIndex:indexPath.row];
            break;
        case 2:
            aTask = [[[_tableDataSource objectForKey:TITLE_THIS_MONTH] objectAtIndex:0] objectAtIndex:indexPath.row];
            cell.textLabel.text = [aTask title];
            aColor = [[[_tableDataSource objectForKey:TITLE_THIS_MONTH] objectAtIndex:1] objectAtIndex:indexPath.row];   
            formatedDate = [[[_tableDataSource objectForKey:TITLE_THIS_MONTH] objectAtIndex:2] objectAtIndex:indexPath.row];
            break;
        case 3:
            aTask = [[[_tableDataSource objectForKey:TITLE_OVERDUE] objectAtIndex:0] objectAtIndex:indexPath.row];
            cell.textLabel.text = [aTask title];
            aColor = [[[_tableDataSource objectForKey:TITLE_OVERDUE] objectAtIndex:1] objectAtIndex:indexPath.row];  
            formatedDate = [[[_tableDataSource objectForKey:TITLE_OVERDUE] objectAtIndex:2] objectAtIndex:indexPath.row];
            break;            
        default:
            break;
    }
    

//    [cell setBackgroundColor: aColor];

    cell.detailTextLabel.textColor = aColor;/* ( (indexPath.section + indexPath.row) % 2 ) ? ([UIColor blueColor])
                                                                          : ([UIColor whiteColor])*/
    cell.detailTextLabel.text = formatedDate;

    if ([[aTask done] isEqualToNumber:[NSNumber numberWithBool:NO]]){
        cell.imageView.image = [UIImage imageNamed:@"task_30x30.png"];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"task_30x30_checked.png"];
    }
    
//    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
//    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:3*86400]];
//    [formatter setDateStyle:NSDateFormatterLongStyle];
//    [formatter setTimeStyle:NSDateFormatterNoStyle];
//    UILabel* subTitleAlertFirst = [[UILabel alloc]initWithFrame:CGRectMake(40, 80, 240, 10)];
//    UILabel* subTitleAlertSecond = [[UILabel alloc]initWithFrame:CGRectMake(40, 100, 240, 10)];
//    subTitleAlertFirst.text = [formatter stringFromDate:aTask.alertDate_first];
//    subTitleAlertSecond.text = [formatter stringFromDate:aTask.alertDate_second];
//    [cell.contentView addSubview:subTitleAlertFirst];
//    [cell.contentView addSubview:subTitleAlertSecond];
    
    return cell;
}


//-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 70.0;
//}


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
    
//    NMTGTask* selectedTask = [[_tableDataSource objectForKey:[_titles objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row]; 
//    NMTGProject* project = selectedTask.parentProject;
//    for(;;){
//        if (project.parentProject != nil) {
//            project = project.parentProject;
//        } else {
//            break;
//        }
//    }
//    NSLog(@"project: %@",project);
//    ProjectsViewController* projectsVC = [[ProjectsViewController alloc]initWithStyle:UITableViewStylePlain];
//    
//    //    NSLog(@"projectsVC.selectedProject DO    :%@",projectsVC.selectedProject);    
//    projectsVC.selectedProject = project;
//    //    NSLog(@"projectsVC.selectedProject posle :%@",projectsVC.selectedProject);
//    
//    projectsVC.shouldPushEmidiately = YES;
//    [self.navigationController pushViewController:projectsVC animated:YES];
    
    
    NMTGAbstract* selectedObject = [[[_tableDataSource objectForKey:[_titles objectAtIndex:indexPath.section]] objectAtIndex:0] objectAtIndex:indexPath.row];
    
//    if([selectedObject isKindOfClass:[NMTGProject class]]){
//        TaskViewController* vc = [[TaskViewController alloc]initWithStyle:UITableViewStylePlain];
//        vc.parentProject = [_fetchedProjectsOrTasks objectAtIndex:indexPath.row];
//        [self.navigationController pushViewController:vc animated:YES];
//    }
    
    if([selectedObject isKindOfClass:[NMTGTask class]]){
        if ([selectedObject.done isEqualToNumber:[NSNumber numberWithBool:YES]]) {
            selectedObject.done = [NSNumber numberWithBool:NO];
        } else {
            selectedObject.done = [NSNumber numberWithBool:YES];
        }
        
        NSError* error = nil;
        NSManagedObjectContext* _context = [[NMTaskGraphManager sharedManager]managedContext];
        if(!([_context save:&error])){
            NSLog(@"FAILED TO SAVE CONTEXT IN FocusedAndContextedVC IN 'didSelectRowAtIndexPath'");
            NSLog(@"%@",error);
        }
        
        //блок проверки заверешен ли проект
        NMTGProject* parent_project = [(NMTGTask*)selectedObject parentProject];
        parent_project.done = [NSNumber numberWithBool: [self checkProjectIsDone:parent_project]];
        
        error = nil;
        if(!([_context save:&error])){
            NSLog(@"FAILED TO SAVE CONTEXT IN FocusedAndContextedVC IN 'didSelectRowAtIndexPath'");
            NSLog(@"%@",error);
        }
        [self reloadData];
    }
}

-(BOOL) checkProjectIsDone:(NMTGProject *)aProject
{
    NSSet* subProjects = aProject.subProject;
    NSSet* subTasks = aProject.subTasks;
    
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

-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    //запись по ключу имеет вид "МассивОбъектов, МассивЦветовСтрокДляТаблицы, МассивФорматированныхДатНапоминаний", поэтому " objectAtIndex:0]"
    NSString* additionalComment = (_shouldShowOnlyUnDone == YES) ? @"незавршенные" : @"все";
    switch (section) {
        case 0:
            if ([[[_tableDataSource objectForKey:TITLE_TODAY]objectAtIndex:0] count] > 0) {
                return [NSString stringWithFormat:@"%@ (%@)", TITLE_TODAY, additionalComment];
            } else return @"";
            break;
        case 1:
            if ([[[_tableDataSource objectForKey:TITLE_THIS_WEEK]objectAtIndex:0] count] > 0) {            
                return [NSString stringWithFormat:@"%@ (%@)", TITLE_THIS_WEEK, additionalComment];
            } else return @"";
            break;
        case 2:
            if ([[[_tableDataSource objectForKey:TITLE_THIS_MONTH]objectAtIndex:0] count] > 0) {            
                return [NSString stringWithFormat:@"%@ (%@)", TITLE_THIS_MONTH, additionalComment];
            } else return @"";
            break;
        case 3:
            if ([[[_tableDataSource objectForKey:TITLE_OVERDUE]objectAtIndex:0] count] > 0) {            
                return [NSString stringWithFormat:@"%@ (%@)", TITLE_OVERDUE, additionalComment];
            } else return @"";
            break;
        default:
            return @"";
            break;
    }
}

@end
