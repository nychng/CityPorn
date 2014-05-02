//
//  ImgurCellDetail.m
//  Scenery
//
//  Created by Nai Chng on 3/4/14.
//  Copyright (c) 2014 NYC. All rights reserved.
//

#import "ImgurCellDetail.h"
#import <SDWebImage/UIImageView+WebCache.h>


@implementation ImgurCellDetail

- (UIActivityIndicatorView *)activityIndicator {
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc] init];
    }
    return _activityIndicator;
}

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
    [self.scrollView addSubview:self.activityIndicator];
}

- (void)awakeFromNib {
    self.scrollView.minimumZoomScale = 1;
    self.scrollView.maximumZoomScale = 3.0;
    self.scrollView.delegate = self;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerScrollViewContents];
}

- (void)centerScrollViewContents {
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.imageView.frame = contentsFrame;
}

@end
