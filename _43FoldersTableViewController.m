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
#import "_43FoldersTableViewController.h"

/*
 //
 // Данный контроллер вызывается для отображения заданий, разбитых на группы по временному критеию
 // "Просроченные", "Сегодня", "В течение недели" "В этом месяце", при этом фильтруя задания по контексту
 //
 */


#define TITLE_JANUARY @"Январь"
#define TITLE_FEBRUARY @"Февраль"
#define TITLE_MARCH @"Март"
#define TITLE_APRIL @"Апрель"
#define TITLE_MAY @"Май"
#define TITLE_JUNE @"Июнь"
#define TITLE_JULY @"Июль"
#define TITLE_AUGUST @"Август"
#define TITLE_SEPTEMBER @"Сентябрь"
#define TITLE_OCTOBER @"Октябрь"
#define TITLE_NOVEMBER @"Ноябрь"
#define TITLE_DECEMBER @"Декабрь"
#define TITLE_JANUARY_NEXT @"Январь " //с пробелом!!! это важно



#define TITLE_JANUARY_WITH_DECLINATION @"Января"
#define TITLE_FEBRUARY_WITH_DECLINATION @"Февраля"
#define TITLE_MARCH_WITH_DECLINATION @"Марта"
#define TITLE_APRIL_WITH_DECLINATION @"Апреля"
#define TITLE_MAY_WITH_DECLINATION @"Мая"
#define TITLE_JUNE_WITH_DECLINATION @"Июня"
#define TITLE_JULY_WITH_DECLINATION @"Июля"
#define TITLE_AUGUST_WITH_DECLINATION @"Августа"
#define TITLE_SEPTEMBER_WITH_DECLINATION @"Сентября"
#define TITLE_OCTOBER_WITH_DECLINATION @"Октября"
#define TITLE_NOVEMBER_WITH_DECLINATION @"Ноября"
#define TITLE_DECEMBER_WITH_DECLINATION @"Декабря"
#define TITLE_JANUARY_NEXT_WITH_DECLINATION @"Января " //с пробелом!!! это важно

#define SECONDS_IN_NON_LEAP_YEAR 31536000

@implementation _43FoldersTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _tableDataSource = [NSMutableDictionary new];
        
        _titles = [NSArray arrayWithObjects:
                   TITLE_JANUARY, 
                   TITLE_FEBRUARY, 
                   TITLE_MARCH, 
                   TITLE_APRIL, 
                   TITLE_MAY, 
                   TITLE_JUNE, 
                   TITLE_JULY, 
                   TITLE_AUGUST, 
                   TITLE_SEPTEMBER, 
                   TITLE_OCTOBER, 
                   TITLE_NOVEMBER, 
                   TITLE_DECEMBER, 
                   TITLE_JANUARY_NEXT, 
                   nil];

        _titles_with_declination = [NSArray arrayWithObjects:
                                    TITLE_JANUARY_WITH_DECLINATION, 
                                    TITLE_FEBRUARY_WITH_DECLINATION, 
                                    TITLE_MARCH_WITH_DECLINATION, 
                                    TITLE_APRIL_WITH_DECLINATION, 
                                    TITLE_MAY_WITH_DECLINATION, 
                                    TITLE_JUNE_WITH_DECLINATION, 
                                    TITLE_JULY_WITH_DECLINATION, 
                                    TITLE_AUGUST_WITH_DECLINATION, 
                                    TITLE_SEPTEMBER_WITH_DECLINATION, 
                                    TITLE_OCTOBER_WITH_DECLINATION, 
                                    TITLE_NOVEMBER_WITH_DECLINATION, 
                                    TITLE_DECEMBER_WITH_DECLINATION, 
                                    TITLE_JANUARY_NEXT_WITH_DECLINATION, 
                                    nil];
        
        _images = [NSArray arrayWithObjects:
                   [UIImage imageNamed:@"winter_30x30.png"],
                   [UIImage imageNamed:@"winter_30x30.png"],
                   [UIImage imageNamed:@"spring_30x30.png"],
                   [UIImage imageNamed:@"spring_30x30.png"],                   
                   [UIImage imageNamed:@"spring_30x30.png"],
                   [UIImage imageNamed:@"sun_30x30.png"],
                   [UIImage imageNamed:@"sun_30x30.png"],                                                    
                   [UIImage imageNamed:@"sun_30x30.png"],
                   [UIImage imageNamed:@"autumn_30x30.png"],
                   [UIImage imageNamed:@"autumn_30x30.png"],
                   [UIImage imageNamed:@"autumn_30x30.png"],
                   [UIImage imageNamed:@"winter_30x30.png"],
                   nil];
        
        _numberOfDaysInMonth = [NSArray arrayWithObjects:
                               [NSNumber numberWithInt:31],
                               [NSNumber numberWithInt:28],
                               [NSNumber numberWithInt:31],
                               [NSNumber numberWithInt:30],
                               [NSNumber numberWithInt:31],
                               [NSNumber numberWithInt:30],
                               [NSNumber numberWithInt:31],
                               [NSNumber numberWithInt:31],
                               [NSNumber numberWithInt:30],
                               [NSNumber numberWithInt:31],
                               [NSNumber numberWithInt:30],
                               [NSNumber numberWithInt:31],
                               [NSNumber numberWithInt:31],
                               nil];
        
        _number_of_current_month = 0;
        _number_of_selected_row = -1;
        _additional_31_day = 0; 
        
        [self.tableView setEditing:YES];
        self.tableView.allowsSelectionDuringEditing = YES;
        
        hideBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Свернуть" style:UIBarButtonItemStylePlain target:self action:@selector(hide)];
        self.navigationItem.rightBarButtonItem = hideBarButtonItem;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void) hideModalController
{
    [self dismissModalViewControllerAnimated:YES];
}


-(void)reloadData{
    NSTimeInterval intervalForDate_01_01_2012 = 1325361601; //количество секунд с 1970 до 01.01.2012 00:00:01
    NSTimeInterval intervalForDate_01_01_2013 = 1356984001; //количество секунд с 1970 до 01.01.2013 00:00:01
    
    NSDate* _01_01_2012__00_00_01 = [NSDate dateWithTimeIntervalSince1970:intervalForDate_01_01_2012];
    NSDate* _01_01_2013__00_00_01 = [NSDate dateWithTimeIntervalSince1970:intervalForDate_01_01_2013];
    NSTimeInterval secondsInOneNonLeapYear = [_01_01_2013__00_00_01 timeIntervalSince1970] - [_01_01_2012__00_00_01 timeIntervalSince1970];
    
    //высчитываем текущий год
    int number_of_years_past_since_01_01_2012 = 0;
    
    NSTimeInterval secondsPastFrom_01_01_2012_TilNow = [[NSDate date] timeIntervalSince1970] - intervalForDate_01_01_2012;
    
    if ( secondsPastFrom_01_01_2012_TilNow > 0 ) { //значит текущая дата позже чем 01.01.2012 00:00:01
        while (secondsPastFrom_01_01_2012_TilNow > number_of_years_past_since_01_01_2012 * secondsInOneNonLeapYear + intervalForDate_01_01_2012) {
            //пока число секунд... > число лет * на количество секунд в високосном году, плюс количество секунд с 1970 до 01_01_2012
            number_of_years_past_since_01_01_2012 ++ ;
        }
    } else {
        while (secondsPastFrom_01_01_2012_TilNow < number_of_years_past_since_01_01_2012 * secondsInOneNonLeapYear + intervalForDate_01_01_2012) {
            number_of_years_past_since_01_01_2012 --;
        }
    }
    
    NSDate* _01_01_current_year__00_00_01 = [NSDate dateWithTimeInterval:number_of_years_past_since_01_01_2012 * secondsInOneNonLeapYear sinceDate:_01_01_2012__00_00_01];
    
    NSDate* january_inThisYear = _01_01_current_year__00_00_01;
    NSDate* february_inThisYear = [NSDate dateWithTimeInterval:31 * 86400 sinceDate:january_inThisYear];
    NSDate* march_inThisYear = [NSDate dateWithTimeInterval:(number_of_years_past_since_01_01_2012 % 4 == 0) ? (29 * 86400) : (28*86400) sinceDate:february_inThisYear];
    NSDate* april_inThisYear = [NSDate dateWithTimeInterval:31 * 86400 sinceDate:march_inThisYear];
    NSDate* may_inThisYear = [NSDate dateWithTimeInterval:30 * 86400 sinceDate:april_inThisYear];
    NSDate* june_inThisYear = [NSDate dateWithTimeInterval:31 * 86400 sinceDate:may_inThisYear];
    NSDate* july_inThisYear = [NSDate dateWithTimeInterval:30 * 86400 sinceDate:june_inThisYear];
    NSDate* august_inThisYear = [NSDate dateWithTimeInterval:31 * 86400 sinceDate:july_inThisYear];
    NSDate* september_inThisYear = [NSDate dateWithTimeInterval:31 * 86400 sinceDate:august_inThisYear];
    NSDate* october_inThisYear = [NSDate dateWithTimeInterval:30 * 86400 sinceDate:september_inThisYear];
    NSDate* november_inThisYear = [NSDate dateWithTimeInterval:31 * 86400 sinceDate:october_inThisYear];
    NSDate* december_inThisYear = [NSDate dateWithTimeInterval:30 * 86400 sinceDate:november_inThisYear];
    
    NSDate* january_inNextYear = [NSDate dateWithTimeInterval:31 * 86400 sinceDate:december_inThisYear];
    NSDate* february_inNextYear = [NSDate dateWithTimeInterval:31 * 86400 sinceDate:january_inNextYear];
    NSDate* march_inNextYear = [NSDate dateWithTimeInterval:28 * 86400 sinceDate:february_inNextYear];
    NSDate* april_inNextYear = [NSDate dateWithTimeInterval:31 * 86400 sinceDate:march_inNextYear];
    NSDate* may_inNextYear = [NSDate dateWithTimeInterval:30 * 86400 sinceDate:april_inNextYear];
    NSDate* june_inNextYear = [NSDate dateWithTimeInterval:31 * 86400 sinceDate:may_inNextYear];
    NSDate* july_inNextYear = [NSDate dateWithTimeInterval:30 * 86400 sinceDate:june_inNextYear];
    NSDate* august_inNextYear = [NSDate dateWithTimeInterval:31 * 86400 sinceDate:july_inNextYear];
    NSDate* september_inNextYear = [NSDate dateWithTimeInterval:31 * 86400 sinceDate:august_inNextYear];
    NSDate* october_inNextYear = [NSDate dateWithTimeInterval:30 * 86400 sinceDate:september_inNextYear];
    NSDate* november_inNextYear = [NSDate dateWithTimeInterval:31 * 86400 sinceDate:october_inNextYear];
    NSDate* december_inNextYear = [NSDate dateWithTimeInterval:30 * 86400 sinceDate:november_inNextYear];
    
    NSDate* january_inNextNextYear = [NSDate dateWithTimeInterval:31 * 86400 sinceDate:december_inNextYear];
    
    
    NSArray * dates = [NSArray arrayWithObjects:
                       january_inThisYear, 
                       february_inThisYear, 
                       march_inThisYear, 
                       april_inThisYear, 
                       may_inThisYear, 
                       june_inThisYear, 
                       july_inThisYear, 
                       august_inThisYear, 
                       september_inThisYear, 
                       october_inThisYear, 
                       november_inThisYear, 
                       december_inThisYear, 
                       
                       january_inNextYear,                    
                       february_inNextYear, 
                       march_inNextYear, 
                       april_inNextYear, 
                       may_inNextYear, 
                       june_inNextYear, 
                       july_inNextYear, 
                       august_inNextYear, 
                       september_inNextYear, 
                       october_inNextYear, 
                       november_inNextYear,
                       december_inNextYear,
                       
                       january_inNextNextYear,
                       nil];
    
    
    _tableDataSource = [NSMutableDictionary new];
    int row = 0;
    for (NSString* title in _titles) {
        if ([[NSDate date] timeIntervalSince1970] > [[dates objectAtIndex:row] timeIntervalSince1970]) {
            _number_of_current_month = ++row;
        }
    }
    
    newDates = [NSMutableArray new];
    newTitles = [NSMutableArray new];
    newNumberOfDaysInMonth = [NSMutableArray new]; 
    newTitlesWithDeclination = [NSMutableArray new];
    newImages = [NSMutableArray new];
    
    for (int i = _number_of_current_month; i < _number_of_current_month + 13; i++) {
        [newDates addObject:[dates objectAtIndex:i-1]];   
        int year = (int)([[dates objectAtIndex:i+1] timeIntervalSince1970 ] + 40000) / secondsInOneNonLeapYear + 1970 ;
        int indexToSearch = (i > 12) ? (i - 12 - 1) : (i - 1);
        [newTitles addObject:[NSString stringWithFormat:@"%@ %i",[_titles objectAtIndex: indexToSearch], year]];
        [newNumberOfDaysInMonth addObject:[_numberOfDaysInMonth objectAtIndex:indexToSearch]];
        [newTitlesWithDeclination addObject:[_titles_with_declination objectAtIndex:indexToSearch]];
        [newImages addObject:[_images objectAtIndex:indexToSearch]];
    }
    
    NSLog(@"newTitles 1; %@", newTitles);

    
    
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:3*86400]];
    
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    
    
//    for( NSDate* date in newDates )     {
//        NSLog(@"%@", [formatter stringFromDate:date]);
//    }
    
    
    newCompletencyLabels = [NSMutableArray new];
    for (int j=0; j<12; j++) {
        NSDate* date1 = [newDates objectAtIndex:j];
        NSDate* date2 = [newDates objectAtIndex:j+1];
        [newCompletencyLabels addObject: [self countNumberOfDoneAndAllTasksBetweenDate:date1 AndDate:date2]];
    }
    
    
    int i = 0; 
    NSMutableArray* newTitlesCopy = [newTitles copy];
    for (NSString* title in newTitlesCopy) {
        if (i == 12) {
            break;
        }
        [_tableDataSource setObject:[NSArray arrayWithObjects:[NSMutableArray arrayWithObject:[newDates objectAtIndex:i]], [NSMutableArray arrayWithObject: [newCompletencyLabels objectAtIndex:i]], nil] forKey:title];
        if (i == _number_of_selected_row) {
            for (int j=0; j < [[newNumberOfDaysInMonth objectAtIndex:i] intValue]; j++) {
                NSDate* day = [newDates objectAtIndex:i];
                NSDate* day_plus_j_days = [NSDate dateWithTimeInterval:86400*j sinceDate:day];
                NSDate* day_plus_j_plus_one_days = [NSDate dateWithTimeInterval:86400*(j+1) sinceDate:day];
            
                NSString* completencyLabelForDay = [self countNumberOfDoneAndAllTasksBetweenDate:day_plus_j_days 
                                                                                         AndDate:day_plus_j_plus_one_days];
                [newTitles insertObject: [NSString stringWithFormat:@"%i %@",j+1, [newTitlesWithDeclination objectAtIndex:i]] atIndex:i+j+1];
                
                [[[_tableDataSource objectForKey:title] objectAtIndex:0] addObject:day_plus_j_plus_one_days];
                [newCompletencyLabels insertObject:completencyLabelForDay atIndex:i+j+1 ];
            }   
        }
        i++;
    }
    
    [hideBarButtonItem setEnabled:_additional_31_day != 0];
    [self.tableView reloadData];
}



- (void)viewDidUnload
{
    [super viewDidUnload];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"43 Папки GTD";     
    [self reloadData];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_additional_31_day != 0) {
        return 12 + _additional_31_day;
    }
    return 12;
}


-(void)hide 
{
    _additional_31_day = 0;
    _number_of_selected_row = 1;
    [self reloadData];
//    [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:_number_of_selected_row inSection:0]];
}


-(NSString*)countNumberOfDoneAndAllTasksBetweenDate:(NSDate *) date1 AndDate:(NSDate *) date2
{
    NSManagedObjectContext* context = [[NMTaskGraphManager sharedManager] managedContext];
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"NMTGTask" inManagedObjectContext:context];
    NSFetchRequest* request = [NSFetchRequest new];
    [request setEntity:entity];
    NSArray* resultsOfFetchExec = [context executeFetchRequest:request error:nil];
    
    int allTasks = 0;
    int doneTasks = 0;
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:3*86400]];
    
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
//NSLog(@"%@ _____-_____ %@",[formatter stringFromDate:date1],[formatter stringFromDate:date2]);
    
    NSMutableArray* allTasksDuringDay = [NSMutableArray new];
    NSMutableArray* allDoneTasksDuringDay = [NSMutableArray new];
    
    for (NMTGTask* task in resultsOfFetchExec) {
        if (allTasks == resultsOfFetchExec.count) {
            return [NSString stringWithFormat:@"сделано %i(%i)"];
        }
//        NSLog(@"%@ =-= %@",[formatter stringFromDate:task.alertDate_first],[formatter stringFromDate:task.alertDate_second]);
//        NSLog(@"%@ ===-==== %@",[formatter stringFromDate:date1],[formatter stringFromDate:date2]);
        
        if ([task.alertDate_first compare:date1] == NSOrderedDescending &&
            [task.alertDate_first compare:date2] == NSOrderedAscending ) {
            if ([task.done isEqualToNumber:[NSNumber numberWithBool:YES]]) {
                if ([allTasksDuringDay containsObject:task] == NO) {
                    [allDoneTasksDuringDay addObject:task];
                }
                doneTasks = [allDoneTasksDuringDay count];
            }
            if ([allTasksDuringDay containsObject:task] == NO) {
                [allTasksDuringDay addObject:task];   
            }
            allTasks = [allTasksDuringDay count];
        } else if ([task.alertDate_second compare:date1] == NSOrderedDescending &&
                   [task.alertDate_second compare:date2] == NSOrderedAscending ) {

            if ([task.done isEqualToNumber:[NSNumber numberWithBool:YES]]) {
                if ([allTasksDuringDay containsObject:task] == NO) {
                    [allDoneTasksDuringDay addObject:task];
                }
                doneTasks = [allDoneTasksDuringDay count];
            }
            if ([allTasksDuringDay containsObject:task] == NO) {
                [allTasksDuringDay addObject:task];   
            }
            allTasks = [allTasksDuringDay count];
        } 
    }
    
    return [NSString stringWithFormat:@"сделано %i(%i)",doneTasks, allTasks];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        
    if (_additional_31_day == 0) {
        cell.textLabel.text = [newTitles objectAtIndex:indexPath.row];
        NSString* key = [newTitles objectAtIndex:indexPath.row];       
        cell.detailTextLabel.text = [[[_tableDataSource objectForKey:key] objectAtIndex:1] objectAtIndex:0];
        cell.imageView.image = [newImages objectAtIndex:indexPath.row];
    } else {
        if (indexPath.row  <= _number_of_selected_row) {
            cell.imageView.image = [newImages objectAtIndex:indexPath.row];            
        } else if (indexPath.row <= _number_of_selected_row + _additional_31_day) {
            //
        } else {
            cell.imageView.image = [newImages objectAtIndex:indexPath.row - _additional_31_day];
        }
        cell.textLabel.text = [newTitles objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [newCompletencyLabels objectAtIndex:indexPath.row];
    }

    if (indexPath.row % 2 == 0) { 
        cell.backgroundColor = [UIColor colorWithRed:241./255 green:241./255 blue:241./255 alpha:1];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return  cell;
}




// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_additional_31_day != 0) {
        if (indexPath.row <= _number_of_selected_row) return NO;
        if (indexPath.row <= _number_of_selected_row + _additional_31_day) return YES; 
    }
    return NO;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return UITableViewCellEditingStyleNone;
}

        
                           
#pragma mark - Table view delegate
 -(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_additional_31_day == 0) {
         _number_of_selected_row = indexPath.row;
         _additional_31_day = [[newNumberOfDaysInMonth objectAtIndex:_number_of_selected_row] intValue];
     } else if (indexPath.row <= _number_of_selected_row || indexPath.row >=  _number_of_selected_row + _additional_31_day) {  
         if (indexPath.row == _number_of_selected_row) {
             _number_of_selected_row = -1;
             _additional_31_day = 0;
         } else {
             _number_of_selected_row = indexPath.row - _additional_31_day;
         }
     } else {
         FocusedAndContextedViewController* vc = [[FocusedAndContextedViewController alloc]initWithStyle:UITableViewStylePlain];
         vc.alert_date_1 = [newDates objectAtIndex:indexPath.row];
         vc.alert_date_2 = [newDates objectAtIndex:indexPath.row + 1];
         [self.navigationController pushViewController:vc animated:YES];
     }
     [self reloadData];
}
                   
   
                           
@end
