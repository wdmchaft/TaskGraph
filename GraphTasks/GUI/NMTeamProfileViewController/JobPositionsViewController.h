//
//  JobPositionsViewController.h
//  GraphTasks
//
//  Created by Тимур Юсипов on 07.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EmployerPropertiesDelegate;


@protocol JobPositionsDelegate <NSObject>
-(void) createNewJobPositionWithName: (NSString *) name;
@end

@interface JobPositionsViewController : UITableViewController <JobPositionsDelegate> {
    id<EmployerPropertiesDelegate> _delegate;
    NSArray *_tableDataSource;
    NSIndexPath *_indexPathOfLastSelectedRow;
}
-(void) addJobPostion;
-(void) reloadData;
-(void) cancel;
@property (nonatomic, retain) id<EmployerPropertiesDelegate> delegate;
@end
