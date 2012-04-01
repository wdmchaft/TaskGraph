//
//  NMPhotoViewerView.h
//  SlavYard
//
//  Created by Николай Сычев on 15.07.11.
//  Copyright 2011 СКИБ. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NMPhotoViewer : UIView <UIScrollViewDelegate>
{
    UIScrollView    *_scrollView;
    UIPageControl   *_pageControl;
    
    NSMutableArray  *_imagesArray;
}

@property(nonatomic,strong)                             UIScrollView *scrollView;
@property(nonatomic,strong)                             UIPageControl   *pageControl;

@property(nonatomic,strong, setter = setImagesArray:)   NSMutableArray  *imagesArray;

@end
