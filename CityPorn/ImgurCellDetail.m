//
//  ImgurCellDetail.m
//  Scenery
//
//  Created by Nai Chng on 3/4/14.
//  Copyright (c) 2014 NYC. All rights reserved.
//

#import "ImgurCellDetail.h"

@implementation ImgurCellDetail

- (void)prepareForReuse
{
    if (self.activityIndicator) {
        [self.activityIndicator stopAnimating];
        [self.activityIndicator removeFromSuperview];
    }
    self.imageView.image = nil;
    [self.imageView cancelCurrentImageLoad];
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
    [self.imageView addSubview:self.activityIndicator];
}

@end
