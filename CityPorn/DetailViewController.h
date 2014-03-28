//
//  DetailViewController.h
//  CityPorn
//
//  Created by Nai Chng on 7/2/14.
//  Copyright (c) 2014 NYC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@interface DetailViewController : UIViewController <UIScrollViewDelegate, UIAlertViewDelegate,
UICollectionViewDataSource, UICollectionViewDelegate, ADBannerViewDelegate> {
	CGFloat _firstX;
	CGFloat _firstY;
}

@property (strong, nonatomic) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, strong) NSIndexPath *imageIndex;

- (IBAction)saveButton:(id)sender;


@end
