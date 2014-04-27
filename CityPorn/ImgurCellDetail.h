//
//  ImgurCellDetail.h
//  Scenery
//
//  Created by Nai Chng on 3/4/14.
//  Copyright (c) 2014 NYC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImgurCellDetail : UICollectionViewCell <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) NSURL *url;
@property (nonatomic, strong) NSURL *commentURL;

- (void)setupActivityIndicator;
@end
