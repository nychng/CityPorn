//
//  DetailViewController.h
//  Scenery
//
//  Created by Nai Chng on 17/2/14.
//  Copyright (c) 2014 NYC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UICollectionViewController <UIScrollViewDelegate, UIAlertViewDelegate> {
	CGFloat _firstX;
	CGFloat _firstY;
}

@property (strong, nonatomic) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, strong) NSIndexPath *imageIndex;


@end

