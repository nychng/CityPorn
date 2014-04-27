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
#import <MessageUI/MessageUI.h>
#import <SDWebImage/UIImageView+WebCache.h>


@interface DetailViewController () <ADBannerViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>


@end

@implementation DetailViewController

- (IBAction)showActionSheet:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save", @"Email", @"Open in Safari", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    [actionSheet showInView:self.collectionView];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.canDisplayBannerAds = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UICollectionViewFlowLayout *layout = (id) self.collectionView.collectionViewLayout;
    layout.itemSize = self.collectionView.frame.size;
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
    cell.url = image.url;
    cell.commentURL = image.commentURL;
    
    if (cell.activityIndicator) {
        [cell.activityIndicator removeFromSuperview];
    }
    [cell setupActivityIndicator];
    
    cell.imageView = [[UIImageView alloc] init];

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
                             weakCell.imageView = [[UIImageView alloc] initWithImage:image];
                             weakCell.imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=weakCell.imageView.image.size};
                             weakCell.scrollView.contentSize = weakCell.imageView.image.size;
                             
                             CGRect scrollViewFrame = weakCell.scrollView.frame;
                             CGFloat scaleWidth = scrollViewFrame.size.width / weakCell.scrollView.contentSize.width;
                             CGFloat scaleHeight = scrollViewFrame.size.height / weakCell.scrollView.contentSize.height;
                             CGFloat minScale = MIN(scaleWidth, scaleHeight);
                             
                             weakCell.scrollView.minimumZoomScale = minScale;
                             weakCell.scrollView.maximumZoomScale = 1.0f;
                             weakCell.scrollView.zoomScale = minScale;
                             
                             [weakCell.scrollView addSubview:weakCell.imageView];
                             [self centerScrollViewContents];
                         }];
        
        cell.title.hidden = NO;
        cell.title.text = image.title;
        cell.title.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        
        UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
        doubleTapRecognizer.numberOfTapsRequired = 2;
        doubleTapRecognizer.numberOfTouchesRequired = 1;
        [cell.scrollView addGestureRecognizer:doubleTapRecognizer];
        
        [self.collectionView addGestureRecognizer:cell.scrollView.pinchGestureRecognizer];
        [self.collectionView addGestureRecognizer:cell.scrollView.panGestureRecognizer];

    } else {
        [NetworkChecker showNetworkMessage:@"No network connection found. An Internet connection is required for this application to work" title:@"No Network Connectivity!" delegate:self];
    }
    
    return cell;
}

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
    ImgurCellDetail *cell = [self.collectionView visibleCells][0];

    float newScale = [cell.scrollView zoomScale] * 4.0;
    
    if (cell.scrollView.zoomScale > cell.scrollView.minimumZoomScale)
    {
        [cell.scrollView setZoomScale:cell.scrollView.minimumZoomScale animated:YES];
    }
    else
    {
        CGRect zoomRect = [self zoomRectForScale:newScale
                                      withCenter:[recognizer locationInView:recognizer.view]];
        [cell.scrollView zoomToRect:zoomRect animated:YES];
    }
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    ImgurCellDetail *cell = [self.collectionView visibleCells][0];

    zoomRect.size.height = [cell.imageView frame].size.height / scale;
    zoomRect.size.width  = [cell.imageView frame].size.width  / scale;
    
    center = [cell.imageView convertPoint:center fromView:cell.scrollView];
    
    zoomRect.origin.x    = center.x - ((zoomRect.size.width / 2.0));
    zoomRect.origin.y    = center.y - ((zoomRect.size.height / 2.0));
    
    return zoomRect;
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

- (void)centerScrollViewContents {
    ImgurCellDetail *cell = (ImgurCellDetail *)[self.collectionView cellForItemAtIndexPath:self.imageIndex];
    CGSize boundsSize = cell.scrollView.bounds.size;
    CGRect contentsFrame = cell.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    cell.imageView.frame = contentsFrame;
}

- (void)collectionView:(UICollectionView *)collectionView
  didEndDisplayingCell:(ImgurCellDetail *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.collectionView removeGestureRecognizer:cell.scrollView.pinchGestureRecognizer];
    [self.collectionView removeGestureRecognizer:cell.scrollView.panGestureRecognizer];
}

- (void)resetImage:(ImgurCellDetail *)cell {
    //reset zoomScale back to 1 so that contentSize can be modified correctly
    cell.scrollView.zoomScale = 1;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self saveImage];
    } else if (buttonIndex == 1) {
        [self sendEmail];
    } else if (buttonIndex == 2) {
        [self openInSafari];
    }
}

- (void)saveImage
{
    ImgurCellDetail *cell = [self.collectionView visibleCells][0];
    UIImageWriteToSavedPhotosAlbum(cell.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

static NSString * const kPageLink = @"https://itunes.apple.com/us/app/urban-city-wallpaper/id820844604?ls=1&mt=8";

- (NSString *)signatureString {
    return [NSString stringWithFormat:@"Sent from <a href=%@>Urban City Wallpaper</a> on iPhone.<hr>", kPageLink];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)sendEmail {
    if ([MFMailComposeViewController canSendMail]) {
        
        NSString *emailTitle = @"Room Idea";
        NSString *bodyString = @"";
        NSString *messageBody = [bodyString stringByAppendingString:self.signatureString];
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:YES];
        
        ImgurCellDetail *cell = [self.collectionView visibleCells][0];
        
        // Get the resource path and read the file using NSData
        NSData *fileData = [NSData dataWithContentsOfURL:cell.url];
        
        // Determine the MIME type
        NSString *mimeType = @"image/jpeg";
   
        
        // Add attachment
        [mc addAttachmentData:fileData mimeType:mimeType fileName:[NSString stringWithFormat:@"%@", cell.url]];
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];
        
    }
    else {
        
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:NSLocalizedString(@"Unable to send Mail!", nil)
                                  message:NSLocalizedString(@"Device is unable to send mail", nil)
                                  delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)openInSafari {
    ImgurCellDetail *cell = [self.collectionView visibleCells][0];
    NSString *url = [NSString stringWithFormat:@"http://www.reddit.com%@", cell.commentURL];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

@end
