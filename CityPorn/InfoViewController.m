//
//  InfoViewController.m
//  CityPorn
//
//  Created by Nai Chng on 12/2/14.
//  Copyright (c) 2014 NYC. All rights reserved.
//

#import "InfoViewController.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.infoLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    self.closeButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75f];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)close
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
