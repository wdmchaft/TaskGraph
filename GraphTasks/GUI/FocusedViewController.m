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
        // Custom initialization
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
    
    NSLog(@"startdate: %@",startDate);
    NSLog(@"enddate: %@",endDate);
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:
      @"(((alertDate_first > %@) && (alertDate_first < %@)) || ((alertDate_second > %@) && (alertDate_second < %@)))",startDate,endDate,startDate,endDate];
    [request setPredicate:predicate];
    NSArray* todayTasks = [context executeFetchRequest:request error:nil];
    for(NMTGAbstract* obj in todayTasks) NSLog(@"today : %@",obj.title);
    
    predicate = [NSPredicate predicateWithFormat:@"(alertDate_second < %@)",startDate];
    [request  setPredicate:predicate];
    NSArray* overdueTasks = [context executeFetchRequest:request error:nil];
    for(NMTGAbstract* obj in overdueTasks) NSLog(@"overdue  : %@",obj.title);
    
    [components setYear:0];
    [components setMonth:0];
    [components setDay:6];  
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    
    startDate = endDate;
    endDate = [calendar dateByAddingComponents:components toDate:startDate options:0];
    //получили дату "завтра" и через 7 дней после сегодня
    NSLog(@"startdate '7': %@",startDate);
    NSLog(@"enddate '7': %@",endDate);
    
    predicate = [NSPredicate predicateWithFormat:
                              @"(((alertDate_first > %@) && (alertDate_first < %@)) || ((alertDate_second > %@) && (alertDate_second < %@)))",startDate,endDate,startDate,endDate];
    [request setPredicate:predicate];
    NSMutableArray* weekTasks = [NSMutableArray arrayWithArray: [context executeFetchRequest:request error:nil]];
    NSLog(@"weekTasks count:%i",[weekTasks count]);
    for(NMTGAbstract* obj in weekTasks){
        if([todayTasks containsObject:obj]){
//            [weekTasks removeObject:obj];
        } else {
            NSLog(@"week: %@",obj.title);
        }
    } 
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
    [self reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
