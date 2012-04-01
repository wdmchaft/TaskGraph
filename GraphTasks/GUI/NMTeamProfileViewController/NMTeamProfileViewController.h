//
//  NMTeamProfileViewController.h
//  GraphTasks
//
//  Created by Vladimir Konev on 2/28/12.
//  Copyright (c) 2012 Novilab Mobile. All rights reserved.
//

#import "NMTaskGraphManager.h"

@interface NMTeamProfileViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>{
    NSManagedObjectContext* _context;
    NSArray*         _fetchedProfiles;
    
    UITableView*            _profilesTableView;
}

-   (void)  reloadData;

-   (void)  addTeamProfile;

@end
