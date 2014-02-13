//
//  ImgurCell.m
//  CityPorn
//
//  Created by Nai Chng on 12/2/14.
//  Copyright (c) 2014 NYC. All rights reserved.
//

#import "ImgurCell.h"

@implementation ImgurCell

- (void)prepareForReuse
{
    self.thumbnailImage.image = nil;
    [self.thumbnailImage cancelCurrentImageLoad];
}

- (void)setupActivityIndicator
{
    if (self.activityIndicator) {
        [self.activityIndicator removeFromSuperview];
    }
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator.hidden = NO;
    //[activityIndicator startAnimating];
    self.activityIndicator.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    self.activityIndicator.tag = 200;
    [self.thumbnailImage addSubview:self.activityIndicator];
}

- (void)showActivityIndicator
{
    
}

- (void)hideActivityIndicator
{
    
}

@end
