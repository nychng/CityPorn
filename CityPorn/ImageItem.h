//
//  Image.h
//  CityPorn
//
//  Created by Nai Chng on 10/2/14.
//  Copyright (c) 2014 NYC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageItem : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSURL *url;

- (NSURL *)getSmallThumbnailURL;

@end
