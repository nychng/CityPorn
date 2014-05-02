//
//  ImageCell.m
//  Scenery
//
//  Created by Nai Chng on 17/2/14.
//  Copyright (c) 2014 NYC. All rights reserved.
//

#import "ImgurCell.h"
#import <SDWebImage/UIImageView+WebCache.h>


@implementation ImgurCell

- (void)prepareForReuse
{
    if (self.activityIndicator) {
        [self.activityIndicator stopAnimating];
        [self.activityIndicator removeFromSuperview];
    }
    self.thumbnailImage.image = nil;
    [self.thumbnailImage cancelCurrentImageLoad];
}

- (void)setupActivityIndicator
{
    if (self.activityIndicator) {
        [self.activityIndicator removeFromSuperview];
    }
    self.activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    self.activityIndicator.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    self.activityIndicator.tag = 200;
    [self.thumbnailImage addSubview:self.activityIndicator];
}

@end
