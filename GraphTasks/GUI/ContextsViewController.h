//
//  ContextsViewController.h
//  GraphTasks
//
//  Created by Тимур Юсипов on 04.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddPropertiesViewController.h"

@protocol ContextAddDelegate <NSObject>
-(void)setContextName:(NSString*)name;
-(NSArray*) getData;
@end

@interface ContextsViewController : UITableViewController <ContextAddDelegate>{
    NSMutableDictionary* _tableDataSource;
    NSInteger _numberOfAddedContexts;
    NSString* _defaultContextName;
    id<SetTasksProperties> _delegate;
}
@property(nonatomic,retain) id<SetTasksProperties> delegate;
@property(nonatomic,retain) NSString* defaultContextName;

-(void) addContext;
-(void) reloadData;
@end
