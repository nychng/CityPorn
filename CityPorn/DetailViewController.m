//
//  DetailViewController.m
//  CityPorn
//
//  Created by Nai Chng on 7/2/14.
//  Copyright (c) 2014 NYC. All rights reserved.
//

#import "DetailViewController.h"
#import "ImageItem.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface DetailViewController ()
{
    NSIndexPath *_currentIndexPath;
}

@end

@implementation DetailViewController

#pragma mark - Managing the detail image

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self loadSelectedImage];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    UICollectionViewCell *cell = [self.collectionView visibleCells][0];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
    imageView = nil;
}

- (IBAction)saveButton:(id)sender
{
    // there should only be 1 visible cell
    UICollectionViewCell *cell = [self.collectionView visibleCells][0];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
    UIImageWriteToSavedPhotosAlbum(imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image
didFinishSavingWithError:(NSError *)error
  contextInfo: (void *) contextInfo
{
    NSString *title;
    NSString *message;
    if (error) {
        title = @"Failed!";
        message = @"The image was not saved due to %@", [error localizedDescription];
    }
    else
    {
        title = @"Success!";
        message = @"The image was saved to your Photos";
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(title, nil)
                                                        message:NSLocalizedString(message, nil)
                                                       delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)loadSelectedImage
{
    NSIndexPath *indexPath = self.imageIndex;
    [self.collectionView scrollToItemAtIndexPath:indexPath
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:NO];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return self.imageArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //_currentIndexPath = indexPath;
    static NSString *cellIdentifier = @"Cell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier
                                                                           forIndexPath:indexPath];
    ImageItem *image = [self.imageArray objectAtIndex:indexPath.row];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
    
    [imageView setImageWithURL:image.url];
    UILabel *imageLabel = (UILabel *)[cell viewWithTag:200];
    imageLabel.text = image.title;
    imageLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UILabel *imageLabel = (UILabel *)[cell viewWithTag:200];
    
    imageLabel.hidden = imageLabel.hidden ? NO : YES;
}

@end
