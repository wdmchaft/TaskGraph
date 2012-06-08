//
//  NMTGTask.h
//  GraphTasks
//
//  Created by Тимур Юсипов on 07.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NMTGAbstract.h"

@class NMTGProject, NMTGTask;

@interface NMTGTask : NMTGAbstract

@property (nonatomic, retain) NSString * keyDescribingTaskType;
@property (nonatomic, retain) NSString * valueForKeyDescribingTaskType;
@property (nonatomic, retain) NMTGProject *parentProject;
@property (nonatomic, retain) NSSet *workers;
@end

@interface NMTGTask (CoreDataGeneratedAccessors)

- (void)addWorkersObject:(NMTGTask *)value;
- (void)removeWorkersObject:(NMTGTask *)value;
- (void)addWorkers:(NSSet *)values;
- (void)removeWorkers:(NSSet *)values;

@end
