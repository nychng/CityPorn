//
//  ImgurCellDetail.h
//  Scenery
//
//  Created by Nai Chng on 3/4/14.
//  Copyright (c) 2014 NYC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImgurCellDetail : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) IBOutlet UILabel *title;

@property (strong, nonatomic) NSString *url;

- (void)setupActivityIndicator;
@end
