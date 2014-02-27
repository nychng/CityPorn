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
#import "NetworkChecker.h"

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

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error
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
    [self resetImage:cell];
    ImageItem *image = [self.imageArray objectAtIndex:indexPath.row];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];

    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.hidesWhenStopped = YES;
    activityIndicator.hidden = NO;
    activityIndicator.center = CGPointMake(cell.frame.size.width/2, cell.frame.size.height/2);
    [imageView addSubview:activityIndicator];
    
    [self loadGestures:imageView];
    
    if ([NetworkChecker hasConnectivity]) {
        [imageView setImageWithURL:image.url
                  placeholderImage:nil
                           options:SDWebImageProgressiveDownload
                          progress:^(NSUInteger receivedSize, long long expectedSize) {
                              [activityIndicator startAnimating];
                          }
                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                             [activityIndicator stopAnimating];
                             [activityIndicator removeFromSuperview];
                         }];
        
        UILabel *imageLabel = (UILabel *)[cell viewWithTag:200];
        imageLabel.hidden = NO;
        imageLabel.text = image.title;
        imageLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    } else {
        [NetworkChecker showNetworkMessage:@"No network connection found. An Internet connection is required for this application to work" title:@"No Network Connectivity!" delegate:self];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UILabel *imageLabel = (UILabel *)[cell viewWithTag:200];
    
    imageLabel.hidden = imageLabel.hidden ? NO : YES;
}


- (void)loadGestures:(UIImageView *)imageView
{
    imageView.userInteractionEnabled = YES;
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc]
                                     initWithTarget:self action:@selector(pinch:)];
    [imageView addGestureRecognizer:pinchRecognizer];
    
//	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]
//                                             initWithTarget:self action:@selector(move:)];
//	[panRecognizer setMinimumNumberOfTouches:1];
//	[panRecognizer setMaximumNumberOfTouches:1];
//	[imageView addGestureRecognizer:panRecognizer];

}

- (void)pinch:(UIPinchGestureRecognizer *)gesture {
    UICollectionViewCell *cell = [self.collectionView visibleCells][0];
    if (gesture.state == UIGestureRecognizerStateEnded
        || gesture.state == UIGestureRecognizerStateChanged) {
        
        CGFloat currentScale = cell.frame.size.width / cell.bounds.size.width;
        CGFloat newScale = currentScale * gesture.scale;
        
        if (newScale < 1.0) {
            newScale = 1.0;
        }
        if (newScale > 3.0) {
            newScale = 3.0;
        }
        
        CGAffineTransform transform = CGAffineTransformMakeScale(newScale, newScale);
        cell.transform = transform;
        gesture.scale = 1;
    }
}

- (void)move:(id)sender {
    UICollectionViewCell *cell = [self.collectionView visibleCells][0];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
    CGPoint translatedPoint = [(UIPanGestureRecognizer *)sender translationInView:self.collectionView];
    
    if ([(UIPanGestureRecognizer *)sender state] == UIGestureRecognizerStateBegan) {
        _firstX = [imageView center].x;
        _firstY = [imageView center].y;
    }
    
    translatedPoint = CGPointMake(_firstX+translatedPoint.x, _firstY+translatedPoint.y);
    [imageView setCenter:translatedPoint];
}

- (void)resetImage:(UICollectionViewCell *)cell
{
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0, 1.0);
    cell.transform = transform;
//    UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
//    [imageView setCenter:CGPointMake([imageView center].x, [imageView center].y)];
}

@end
