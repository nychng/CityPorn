//
//  ImageItem.m
//  Scenery
//
//  Created by Nai Chng on 17/2/14.
//  Copyright (c) 2014 NYC. All rights reserved.
//

#import "ImageItem.h"

@implementation ImageItem

- (NSString *)description
{
    return [NSString stringWithFormat:@"<Name: %@, URL: %@>", self.title, self.url];
}

- (NSURL *)getSmallThumbnailURL
{
    NSArray *strings = [[self.url absoluteString] componentsSeparatedByString:@".jpg"];
    // http://api.imgur.com/models/image
    NSString *thumbnailURL = [strings[0] stringByAppendingString:@"l.jpg"];
    NSURL *url = [[NSURL alloc] initWithString:thumbnailURL];
    return url;
}

@end
