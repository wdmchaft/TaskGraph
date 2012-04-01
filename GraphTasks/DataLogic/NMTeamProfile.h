//
//  NMTeamProfile.h
//  GraphTasks
//
//  Created by Тимур Юсипов on 30.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NMTGAbstract;

@interface NMTeamProfile : NSManagedObject

@property (nonatomic, retain) NSDate * birthday;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * mail;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) id photo;
@property (nonatomic, retain) NSSet *tasksAndProjects;
@end

@interface NMTeamProfile (CoreDataGeneratedAccessors)

- (void)addTasksAndProjectsObject:(NMTGAbstract *)value;
- (void)removeTasksAndProjectsObject:(NMTGAbstract *)value;
- (void)addTasksAndProjects:(NSSet *)values;
- (void)removeTasksAndProjects:(NSSet *)values;

@end
