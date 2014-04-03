//
//  DetailViewController.m
//  Scenery
//
//  Created by Nai Chng on 17/2/14.
//  Copyright (c) 2014 NYC. All rights reserved.
//

#import "DetailViewController.h"
#import "ImageItem.h"
#import "ImgurCellDetail.h"
#import "NetworkChecker.h"
#import <iAd/iAD.h>

@interface DetailViewController () <ADBannerViewDelegate>


@end

@implementation DetailViewController

//- (UIScrollView *)scrollView:(UIScrollView *)scrollView
//{
//    ImgurCellDetail *cell = [self.collectionView visibleCells][0];
//    
//    _scrollView = scrollView;
//    _scrollView.minimumZoomScale = 0.2;
//    _scrollView.maximumZoomScale = 3.0;
//    _scrollView.delegate = self;
//    _scrollView.contentSize = cell.imageView.image.size;
//    
//    return _scrollView;
//}

//- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
//{
//    ImgurCellDetail *cell = [self.collectionView visibleCells][0];
//    return cell.imageView;
//}

#pragma mark - Managing the detail image



- (void)viewDidLoad {
    [super viewDidLoad];
    self.canDisplayBannerAds = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UICollectionViewFlowLayout *layout = (id) self.collectionView.collectionViewLayout;
    layout.itemSize = self.collectionView.frame.size;
    NSLog(@"%f", self.collectionView.frame.size.height);
    [self loadSelectedImage];

}

- (void)viewWillLayoutSubviews {
    [super viewDidLayoutSubviews];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    ImgurCellDetail *cell = [self.collectionView visibleCells][0];
    cell.imageView = nil;
}

- (IBAction)saveButton:(id)sender
{
    // there should only be 1 visible cell
    ImgurCellDetail *cell = [self.collectionView visibleCells][0];
    UIImageWriteToSavedPhotosAlbum(cell.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
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
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
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

- (ImgurCellDetail *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    ImgurCellDetail *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier
                                                                           forIndexPath:indexPath];
    //[self resetImage:cell];
    ImageItem *image = [self.imageArray objectAtIndex:indexPath.row];
    
    if (cell.activityIndicator) {
        [cell.activityIndicator removeFromSuperview];
    }
    [cell setupActivityIndicator];

    if ([NetworkChecker hasConnectivity]) {
        __weak typeof(ImgurCellDetail) *weakCell = cell;
        [cell.imageView setImageWithURL:image.url
                  placeholderImage:nil
                           options:SDWebImageProgressiveDownload
                          progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                              [weakCell.activityIndicator startAnimating];
                          }
                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                             [weakCell.activityIndicator stopAnimating];
                             [weakCell.activityIndicator removeFromSuperview];
                         }];
        
        cell.title.hidden = NO;
        cell.title.text = image.title;
        cell.title.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        
        //[self loadGestures:cell.imageView];

    } else {
        [NetworkChecker showNetworkMessage:@"No network connection found. An Internet connection is required for this application to work" title:@"No Network Connectivity!" delegate:self];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImgurCellDetail *cell = (ImgurCellDetail *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.title.hidden = cell.title.hidden ? NO : YES;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
 sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return self.collectionView.frame.size;
}

//- (void)loadGestures:(UIImageView *)imageView
//{
//    imageView.userInteractionEnabled = YES;
//    
//    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc]
//                                                 initWithTarget:self action:@selector(pinch:)];
//    [imageView addGestureRecognizer:pinchRecognizer];
//    
//    //	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]
//    //                                             initWithTarget:self action:@selector(move:)];
//    //	[panRecognizer setMinimumNumberOfTouches:1];
//    //	[panRecognizer setMaximumNumberOfTouches:1];
//    //	[imageView addGestureRecognizer:panRecognizer];
//    
//}
//
//- (void)pinch:(UIPinchGestureRecognizer *)gesture {
//    ImgurCellDetail *cell = [self.collectionView visibleCells][0];
//    if (gesture.state == UIGestureRecognizerStateEnded
//        || gesture.state == UIGestureRecognizerStateChanged) {
//        
//        CGFloat currentScale = cell.frame.size.width / cell.bounds.size.width;
//        CGFloat newScale = currentScale * gesture.scale;
//        
//        if (newScale < 1.0) {
//            newScale = 1.0;
//        }
//        if (newScale > 3.0) {
//            newScale = 3.0;
//        }
//        
//        CGAffineTransform transform = CGAffineTransformMakeScale(newScale, newScale);
//        cell.transform = transform;
//        gesture.scale = 1;
//    }
//}
//
//- (void)move:(id)sender {
//    ImgurCellDetail *cell = [self.collectionView visibleCells][0];
//    CGPoint translatedPoint = [(UIPanGestureRecognizer *)sender translationInView:self.collectionView];
//    
//    if ([(UIPanGestureRecognizer *)sender state] == UIGestureRecognizerStateBegan) {
//        _firstX = [cell.imageView center].x;
//        _firstY = [cell.imageView center].y;
//    }
//    
//    translatedPoint = CGPointMake(_firstX+translatedPoint.x, _firstY+translatedPoint.y);
//    [cell.imageView setCenter:translatedPoint];
//}
//
//- (void)resetImage:(ImgurCellDetail *)cell
//{
//    CGAffineTransform transform = CGAffineTransformMakeScale(1.0, 1.0);
//    cell.transform = transform;
//    //    UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
//    //    [imageView setCenter:CGPointMake([imageView center].x, [imageView center].y)];
//}

@end
