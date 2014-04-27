//
//  ImageCell.h
//  Scenery
//
//  Created by Nai Chng on 17/2/14.
//  Copyright (c) 2014 NYC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImgurCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *thumbnailImage;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSString *url;

- (void)setupActivityIndicator;

@end
