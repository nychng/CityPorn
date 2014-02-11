//
//  DetailViewController.h
//  CityPorn
//
//  Created by Nai Chng on 7/2/14.
//  Copyright (c) 2014 NYC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UICollectionViewController

@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, strong) NSIndexPath *imageIndex;

- (IBAction)saveButton:(id)sender;


@end
