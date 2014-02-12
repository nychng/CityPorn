//
//  Image.m
//  CityPorn
//
//  Created by Nai Chng on 10/2/14.
//  Copyright (c) 2014 NYC. All rights reserved.
//

#import "ImageItem.h"

@implementation ImageItem

- (NSString *)description
{
    return [NSString stringWithFormat:@"<Name: %@, URL: %@>", self.title, self.url];
}

- (NSString *)getSmallThumbnailURL
{
    NSArray *strings = [[self.url absoluteString] componentsSeparatedByString:@".jpg"];
    NSString *thumbnailURL = [strings[0] stringByAppendingString:@"l.jpg"];
    return thumbnailURL;
}

@end
