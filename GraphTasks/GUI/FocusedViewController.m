//
//  FocusedViewController.m
//  GraphTasks
//
//  Created by Тимур Юсипов on 05.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FocusedViewController.h"

/*
//
// Данный контроллер вызывается для отображения заданий, разбитых на группы по временному критеию
// "Просроченные", "Сегодня", "В течение недели" "В этом месяце"
//
*/

#define TITLE_OVERDUE @"Просроченные"
#define TITLE_TODAY @"Сегодня"
#define TITLE_THIS_WEEK @"На этой неделе"
#define TITLE_THIS_MONTH @"В этом месяце"

@interface FocusedViewController (internal)
    -(void)reloadData;
@end

@implementation FocusedViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _tableDataSource = [NSMutableDictionary new];
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
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];
    
    [components setYear:0];
    [components setMonth:0];
    [components setDay:0];  
    [components setHour:-1*components.hour];
    [components setMinute:-1*components.minute];
    [components setSecond:-1*components.second];

    NSDate *startDate = [calendar dateByAddingComponents:components toDate:[NSDate date] options:0];
    //получили текущую дату с нулевым часом, минутой, секундой. Во всяком случае должны были. 
    //в консоль выводится дата вида 2012-04-05 20:00:00 +0000     20:00 наверно изза локализации
    
    [components setYear:0];
    [components setMonth:0];
    [components setDay:1];  
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    
    NSDate* endDate = [calendar dateByAddingComponents:components toDate:startDate options:0];
    //получили дату отличающуюся от предыдущей на 1 день
    
//NSLog(@"startdate: %@",startDate);
//NSLog(@"enddate: %@",endDate);
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:
      @"(((alertDate_first > %@) && (alertDate_first < %@)) || ((alertDate_second > %@) && (alertDate_second < %@)))",startDate,endDate,startDate,endDate];
    [request setPredicate:predicate];
    NSArray* todayTasks = [context executeFetchRequest:request error:nil];
    NSLog(@"today count:%i", todayTasks.count);
    [_tableDataSource setObject:todayTasks forKey:TITLE_TODAY];

    //_________________________________________________________________________________________
    
    [components setYear:0];
    [components setMonth:0];
    [components setDay:7];  
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    
    endDate = [calendar dateByAddingComponents:components toDate:startDate options:0];
    
    //получили дату "завтра" и через 7 дней после сегодня
//NSLog(@"startdate '7': %@",startDate);
//NSLog(@"enddate '7': %@",endDate);
    
    NSMutableArray* weekTasks = [NSMutableArray arrayWithArray: [context executeFetchRequest:request error:nil]];
    NSMutableArray* weekTasksWithoutTodayTasks = [NSMutableArray arrayWithArray:weekTasks];
    for(NMTGAbstract* task in weekTasks){
        if([todayTasks containsObject:task]){ [weekTasksWithoutTodayTasks removeObject:task]; }
    } 
    [_tableDataSource setObject:weekTasksWithoutTodayTasks forKey:TITLE_THIS_WEEK ];
    
    
    //________________________________________________________________________________________
    [components setYear:0];
    [components setMonth:0];
    [components setDay:30];  
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    
    endDate = [calendar dateByAddingComponents:components toDate:startDate options:0];
    NSMutableArray* monthTasks = [NSMutableArray arrayWithArray:[context executeFetchRequest:request error:nil]];
    NSMutableArray* monthTasksWithoutTodayAndWeekTasks = [NSMutableArray arrayWithArray: monthTasks];
    for(NMTGAbstract* task in monthTasks){
        if([todayTasks containsObject:task]){ 
            [monthTasksWithoutTodayAndWeekTasks removeObject:task]; 
            continue;
        }
        if([weekTasksWithoutTodayTasks containsObject:task]) {
            [monthTasksWithoutTodayAndWeekTasks removeObject:task]; 
        }
    } 
    [_tableDataSource setObject:monthTasksWithoutTodayAndWeekTasks forKey:TITLE_THIS_MONTH];
    [self.tableView reloadData];
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationItem.title = @"Текущие";
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
    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = [[[_tableDataSource objectForKey:TITLE_TODAY] objectAtIndex:indexPath.row] title];
            break;
        case 1:
            cell.textLabel.text = [[[_tableDataSource objectForKey:TITLE_THIS_WEEK] objectAtIndex:indexPath.row] title];
            break;
        case 2:
            cell.textLabel.text = [[[_tableDataSource objectForKey:TITLE_THIS_MONTH] objectAtIndex:indexPath.row] title];
            break;
        case 3:
            cell.textLabel.text = [[[_tableDataSource objectForKey:TITLE_OVERDUE] objectAtIndex:indexPath.row] title];
            break;            
        default:
            break;
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
