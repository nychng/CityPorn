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



@end
