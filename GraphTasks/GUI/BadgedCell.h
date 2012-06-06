//
//  TDBadgedCell.h
//  TDBadgedTableCell
//	TDBageView
//
//	Any rereleasing of this code is prohibited.
//	Please attribute use of this code within your application
//
//	Any Queries should be directed to hi@tmdvs.me | http://www.tmdvs.me
//	
//  Created by Tim
//  Copyright 2011 Tim Davies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface TableViewCellBadgeView : UIView
{
}

@property (nonatomic, readonly) NSUInteger width;
@property (nonatomic, retain)   NSString *badgeString;
@property (nonatomic, assign)   UITableViewCell *parent;
@property (nonatomic, retain)   UIColor *badgeColor;
@property (nonatomic, retain)   UIColor *badgeColorHighlighted;
@property (nonatomic, assign)   CGFloat radius;

@end

@interface BadgedCell : UITableViewCell {

}

@property (nonatomic, retain)   NSString *badgeString1;
@property (nonatomic, retain)   NSString *badgeString2;
@property (nonatomic, retain)   NSString *badgeString3;
@property (readonly, retain)    TableViewCellBadgeView *badge1;
@property (readonly, retain)    TableViewCellBadgeView *badge2;
@property (readonly, retain)    TableViewCellBadgeView *badge3;
@property (nonatomic, retain)   UIColor *badgeColor1;
@property (nonatomic, retain)   UIColor *badgeColor2;
@property (nonatomic, retain)   UIColor *badgeColor3;
@property (nonatomic, retain)   UIColor *badgeColorHighlighted1;
@property (nonatomic, retain)   UIColor *badgeColorHighlighted2;
@property (nonatomic, retain)   UIColor *badgeColorHighlighted3;

@end
