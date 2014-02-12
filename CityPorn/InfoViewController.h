//
//  InfoViewController.h
//  CityPorn
//
//  Created by Nai Chng on 12/2/14.
//  Copyright (c) 2014 NYC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextView *infoLabel;
@property (strong, nonatomic) IBOutlet UIButton *closeButton;

- (IBAction)close;

@end
