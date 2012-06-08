//
//  NMTGContext.h
//  GraphTasks
//
//  Created by Тимур Юсипов on 07.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface NMTGContext : NSManagedObject

@property (nonatomic, retain) NSString * iconName;
@property (nonatomic, retain) NSNumber * isDefaultContext;
@property (nonatomic, retain) NSString * name;

@end
