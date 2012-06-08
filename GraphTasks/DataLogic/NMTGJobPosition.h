//
//  NMTGJobPosition.h
//  GraphTasks
//
//  Created by Тимур Юсипов on 07.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NMTGJobPosition, NMTeamProfile;

@interface NMTGJobPosition : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *subJobPositions;
@property (nonatomic, retain) NMTGJobPosition *parentJobPosition;
@property (nonatomic, retain) NSSet *workersOnThisPosition;
@end

@interface NMTGJobPosition (CoreDataGeneratedAccessors)

- (void)addSubJobPositionsObject:(NMTGJobPosition *)value;
- (void)removeSubJobPositionsObject:(NMTGJobPosition *)value;
- (void)addSubJobPositions:(NSSet *)values;
- (void)removeSubJobPositions:(NSSet *)values;

- (void)addWorkersOnThisPositionObject:(NMTeamProfile *)value;
- (void)removeWorkersOnThisPositionObject:(NMTeamProfile *)value;
- (void)addWorkersOnThisPosition:(NSSet *)values;
- (void)removeWorkersOnThisPosition:(NSSet *)values;

@end
