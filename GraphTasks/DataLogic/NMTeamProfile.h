//
//  NMTeamProfile.h
//  GraphTasks
//
//  Created by Тимур Юсипов on 07.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NMTGJobPosition, NMTGTask;

@interface NMTeamProfile : NSManagedObject

@property (nonatomic, retain) NSDate * birthday;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * mail;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) id photo;
@property (nonatomic, retain) NSSet *tasks;
@property (nonatomic, retain) NSSet *jobPosition;
@end

@interface NMTeamProfile (CoreDataGeneratedAccessors)

- (void)addTasksObject:(NMTGTask *)value;
- (void)removeTasksObject:(NMTGTask *)value;
- (void)addTasks:(NSSet *)values;
- (void)removeTasks:(NSSet *)values;

- (void)addJobPositionObject:(NMTGJobPosition *)value;
- (void)removeJobPositionObject:(NMTGJobPosition *)value;
- (void)addJobPosition:(NSSet *)values;
- (void)removeJobPosition:(NSSet *)values;

@end
