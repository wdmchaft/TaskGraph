//
//  NMPhotoViewerView.m
//  SlavYard
//
//  Created by Николай Сычев on 15.07.11.
//  Copyright 2011 СКИБ. All rights reserved.
//

#import "NMPhotoViewer.h"

#define PAGE_CONTROL_HEIGHT 36.0

@implementation NMPhotoViewer

@synthesize scrollView  = _scrollView;
@synthesize pageControl = _pageControl;
@synthesize imagesArray = _imagesArray;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {        
        CGRect scrollFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height - PAGE_CONTROL_HEIGHT);
        CGRect pageControlFrame = CGRectMake(frame.origin.x, frame.origin.y + scrollFrame.size.height, frame.size.width, PAGE_CONTROL_HEIGHT);
        
        _scrollView = [[UIScrollView alloc] initWithFrame:scrollFrame];
        [_scrollView setDelegate:self];
        [_scrollView setShowsVerticalScrollIndicator:NO];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [_scrollView setPagingEnabled:YES];
        
        _pageControl = [[UIPageControl alloc] initWithFrame:pageControlFrame];
        [_pageControl setNumberOfPages:0];
        [_pageControl addTarget:self action:@selector(pageControlValueChanged) forControlEvents:UIControlEventValueChanged];
        
        [self addSubview:_scrollView];
        [self addSubview:_pageControl];
    }
    return self;
}

- (void)setImagesArray:(NSMutableArray *)imagesArray
{
    _imagesArray    =   imagesArray;
    [_pageControl setNumberOfPages:0];
    
    for (int i = 0; i < _imagesArray.count; i++)
    {
        if ([[_imagesArray objectAtIndex:i] isMemberOfClass:[UIImage class]])
        {
            CGSize scrollContentSize = CGSizeMake(_scrollView.contentSize.width + _scrollView.frame.size.width, _scrollView.frame.size.height);
                [_scrollView setContentSize:scrollContentSize];
            
            UIImage *photoImage = [_imagesArray objectAtIndex:i];
            UIImageView *photoView = [[UIImageView alloc] initWithImage:photoImage];
            
            CGSize photoViewSize = photoView.frame.size;
            CGSize scrollViewSize = _scrollView.frame.size;
            
            if (photoViewSize.width > scrollViewSize.width)
            {
                CGFloat k = photoViewSize.height/photoViewSize.width;
                
                photoViewSize.height = photoViewSize.height - (photoViewSize.width - scrollViewSize.width)*k;
                photoViewSize.width = scrollViewSize.width;
                
                CGRect rect = photoView.frame;
                rect.size = photoViewSize;
                [photoView setFrame:rect];
            }
            if (photoViewSize.height > scrollViewSize.height)
            {
                CGFloat k = photoViewSize.width/photoViewSize.height;
                
                photoViewSize.width = photoViewSize.width - (photoViewSize.height - scrollViewSize.height)*k;
                photoViewSize.height = scrollViewSize.height;
                
                CGRect rect = photoView.frame;
                rect.size = photoViewSize;
                [photoView setFrame:rect];
            }
            
            CGPoint origin = CGPointMake(scrollViewSize.width / 2 + scrollViewSize.width*_pageControl.numberOfPages++, scrollViewSize.height / 2);
            
            [photoView setCenter:origin];
            
            [_scrollView addSubview:photoView];
        }
    }
    
}

- (void)pageControlValueChanged
{    
    
    CGPoint offset = CGPointMake(_scrollView.frame.size.width * (_pageControl.currentPage), _scrollView.contentOffset.y);
    [_scrollView setContentOffset:offset animated:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat xOffset = scrollView.contentOffset.x;
    int k = (int)xOffset / (int)scrollView.frame.size.width;
    
    if ((int)xOffset % (int)scrollView.frame.size.width > scrollView.frame.size.width / 2)
        k+=1;
    
    [_pageControl setCurrentPage:k];
}


@end
