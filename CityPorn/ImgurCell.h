//
//  ImgurCell.h
//  CityPorn
//
//  Created by Nai Chng on 12/2/14.
//  Copyright (c) 2014 NYC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImgurCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *thumbnailImage;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSString *url;

- (void)setupActivityIndicator;
- (void)showActivityIndicator;
- (void)hideActivityIndicator;

@end
