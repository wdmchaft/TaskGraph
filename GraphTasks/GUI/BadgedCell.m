//
//  TDBadgedCell.m
//  TDBadgedTableCell
//	TDBageView
//
//	Any rereleasing of this code is prohibited.
//	Please attribute use of this code within your application
//
//	Any Queries should be directed to hi@tmdvs.me | http://www.tmdvs.me
//	
//  Created by Tim on [Dec 30].
//  Copyright 2009 Tim Davies. All rights reserved.
//

#import "BadgedCell.h"

@implementation TableViewCellBadgeView

@synthesize width=__width, badgeString=__badgeString, parent=__parent, badgeColor=__badgeColor, badgeColorHighlighted=__badgeColorHighlighted, radius=__radius;

- (id) initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame]))
	{		
		self.backgroundColor = [UIColor clearColor];
	}
	
	return self;	
}

- (void) drawRect:(CGRect)rect
{		
    CGFloat fontsize = 13;
    
	CGSize numberSize = [self.badgeString sizeWithFont:[UIFont boldSystemFontOfSize: fontsize]];
		
    CGRect bounds = (self.badgeString.length == 1) ? CGRectMake(0 , 0, numberSize.width + 12 , 19) : (CGRectMake(0 , 0, numberSize.width + 10 , 19) );
	CGFloat radius =  9.0;
    
	UIColor *colour;
    
	if((__parent.selectionStyle != UITableViewCellSelectionStyleNone) && (__parent.highlighted || __parent.selected))
    { 
        colour = (__badgeColorHighlighted) ? (__badgeColorHighlighted) : ([UIColor colorWithRed:0.2f green:0.549f blue:0.961f alpha:1.000f]);
	} else {
        colour = (__badgeColor) ? (__badgeColor) : ([UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.000f]);
    }
    // Bounds for the text label
	bounds.origin.x = (bounds.size.width - numberSize.width) / 2.0f + 0.5f;
	bounds.origin.y += 1.0f;
	
    CALayer *__badge = [CALayer layer];
	[__badge setFrame:rect];
    
    CGSize imageSize = __badge.frame.size;
    
    // Render the image @x2 for retina people
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00)
    {
        imageSize = CGSizeMake(__badge.frame.size.width * 2, __badge.frame.size.height * 2);
        [__badge setFrame:CGRectMake(__badge.frame.origin.x, 
                                     __badge.frame.origin.y,
                                     __badge.frame.size.width*2, 
                                     __badge.frame.size.height*2)];
        fontsize = (fontsize * 2);
        bounds.origin.x = ((bounds.size.width * 2) - (numberSize.width * 2)) / 2.0f + 1;
        bounds.origin.y += 3;
        bounds.size.width = bounds.size.width * 2;
        radius = radius * 2;
    }
    
    [__badge setBackgroundColor:[colour CGColor]];
	[__badge setCornerRadius:radius];
    
	UIGraphicsBeginImageContext(imageSize);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSaveGState(context);
	[__badge renderInContext:context];
	CGContextRestoreGState(context);
	
	CGContextSetBlendMode(context, kCGBlendModeClear);
	
	[__badgeString drawInRect:bounds withFont:[UIFont boldSystemFontOfSize:fontsize] lineBreakMode:UILineBreakModeClip];
	
	CGContextSetBlendMode(context, kCGBlendModeNormal);
	
	UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	[outputImage drawInRect:rect];
	
	if((__parent.selectionStyle != UITableViewCellSelectionStyleNone) && (__parent.highlighted || __parent.selected))
	{
		[[self layer] setCornerRadius:radius];
		[[self layer] setShadowOffset:CGSizeMake(0, 1)];
		[[self layer] setShadowRadius:1.0];
		[[self layer] setShadowOpacity:0.8];
	} else {
		[[self layer] setCornerRadius:radius];
		[[self layer] setShadowOffset:CGSizeMake(0, 0)];
		[[self layer] setShadowRadius:0];
		[[self layer] setShadowOpacity:0];
	}
	
}


@end


@implementation BadgedCell

@synthesize badgeString1, badge1=__badge1, badgeColor1, badgeColorHighlighted1,
            badgeString2, badge2=__badge2, badgeColor2, badgeColorHighlighted2,
            badgeString3, badge3=__badge3, badgeColor3, badgeColorHighlighted3;

#pragma mark - Init methods

- (void)configureSelf 
{
    // Initialization code
    __badge1 = [[TableViewCellBadgeView alloc] initWithFrame:CGRectZero];
    __badge2 = [[TableViewCellBadgeView alloc] initWithFrame:CGRectZero];
    __badge3 = [[TableViewCellBadgeView alloc] initWithFrame:CGRectZero];
    
    self.badge1.parent = self;
    self.badge2.parent = self;
    self.badge3.parent = self;
    
    [self.contentView addSubview:self.badge3];
    [self.contentView addSubview:self.badge2];
    [self.contentView addSubview:self.badge1];
    
    [self.badge1 setNeedsDisplay];
    [self.badge2 setNeedsDisplay];
    [self.badge3 setNeedsDisplay];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    if ((self = [super initWithCoder:decoder])) 
    {
        [self configureSelf];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier 
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) 
    {
        [self configureSelf];
    }
    return self;
}

#pragma mark - Drawing Methods

- (void) layoutSubviews
{
	[super layoutSubviews];
	
	if(self.badgeString1 && self.badgeString3)
	{
		//force badges to hide on edit.
        [self.badge1 setHidden:self.editing];
        [self.badge2 setHidden:self.editing];
        [self.badge3 setHidden:self.editing];
		
		CGSize badgeSize1 = [self.badgeString1 sizeWithFont:[UIFont boldSystemFontOfSize: 12]];
        CGSize badgeSize3 = [self.badgeString3 sizeWithFont:[UIFont boldSystemFontOfSize: 12]];
        
		CGRect badgeframe1 = CGRectMake(
            self.contentView.frame.size.width - (badgeSize1.width + 17),
            (CGFloat)round((self.contentView.frame.size.height - 20) / 2),
            badgeSize1.width + 14, 
            20);
        
		CGRect badgeframe2 = CGRectMake(badgeframe1.origin.x - 2.5, 
                                        badgeframe1.origin.y,
                                        badgeframe1.size.width + 2.5,
                                        badgeframe1.size.height);
                                        
		
        CGRect badgeframe3 = CGRectMake(
            self.contentView.frame.size.width - (badgeframe1.size.width + badgeSize3.width + 14), 
            (CGFloat)round((self.contentView.frame.size.height - 20) / 2),
            badgeSize3.width + 16.5 + badgeframe1.size.width/2, 
            20);        
		
		[self.badge1 setFrame:badgeframe1];
        [self.badge2 setFrame:badgeframe2];
        [self.badge3 setFrame:badgeframe3];
        
		[self.badge1 setBadgeString:self.badgeString1];
		[self.badge3 setBadgeString:self.badgeString3];        
		
//		if ((self.textLabel.frame.origin.x + self.textLabel.frame.size.width) >= badgeframe.origin.x)
//		{
//			CGFloat badgeWidth = self.textLabel.frame.size.width - badgeframe.size.width - 10.0f;
//			
//			self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x, self.textLabel.frame.origin.y, badgeWidth, self.textLabel.frame.size.height);
//		}
//		
//		if ((self.detailTextLabel.frame.origin.x + self.detailTextLabel.frame.size.width) >= badgeframe.origin.x)
//		{
//			CGFloat badgeWidth = self.detailTextLabel.frame.size.width - badgeframe.size.width - 10.0f;
//			
//			self.detailTextLabel.frame = CGRectMake(self.detailTextLabel.frame.origin.x, self.detailTextLabel.frame.origin.y, badgeWidth, self.detailTextLabel.frame.size.height);
//		}
        
		//set badge highlighted colours or use defaults
        self.badge1.badgeColorHighlighted = (self.badgeColorHighlighted1) ? (self.badgeColorHighlighted1) : [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.000f];
		self.badge3.badgeColorHighlighted = (self.badgeColorHighlighted3) ? (self.badgeColorHighlighted3) : [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.000f];
		
        
        
        //set badge colours or impose defaults
        self.badge1.badgeColor = (self.badgeColor1) ? self.badgeColor1 : [UIColor colorWithRed:0.530f green:0.600f blue:0.738f alpha:1.000f];
        self.badge3.badgeColor = (self.badgeColor3) ? self.badgeColor3 : [UIColor colorWithRed:0.530f green:0.600f blue:0.738f alpha:1.000f];
	}
	else
	{
		[self.badge1 setHidden:YES];
        [self.badge2 setHidden:YES];
        [self.badge3 setHidden:YES];
	}   
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
	[super setHighlighted:highlighted animated:animated];
	[self.badge1 setNeedsDisplay];
	[self.badge2 setNeedsDisplay];    
    [self.badge3 setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];
	[self.badge1 setNeedsDisplay];
	[self.badge2 setNeedsDisplay];    
    [self.badge3 setNeedsDisplay];    
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];
	
    self.badge1.hidden = editing;
    self.badge2.hidden = editing;
    self.badge3.hidden = editing;
    
    [self.badge1 setNeedsDisplay];
    [self.badge2 setNeedsDisplay];
    [self.badge3 setNeedsDisplay];    
    [self setNeedsDisplay];
}


@end
