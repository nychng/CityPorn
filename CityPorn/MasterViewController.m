//
//  MasterViewController.m
//  CityPorn
//
//  Created by Nai Chng on 7/2/14.
//  Copyright (c) 2014 NYC. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "ImageItem.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ImgurCell.h"
#import "NetworkChecker.h"

@interface MasterViewController ()

@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic) int page;
@end

@implementation MasterViewController

- (NSMutableArray *)imageArray
{
    if (!_imageArray) {
        _imageArray = [[NSMutableArray alloc] init];
    }
    return _imageArray;
}

- (int)page
{
    if (!_page) {
        _page = 1;
    }
    return _page;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.page = 1;
    [self loadImages];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setStyle
{
    self.navigationController.navigationBar.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
}

#pragma mark - Collection View

- (void)loadImages
{
    if ([NetworkChecker hasConnectivity]) {
        NSString *url = [self getURL:self.page];
        NSData *response = [[self getDataFrom:url] dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = [[NSError alloc] init];
        NSMutableDictionary *imageResponse = [NSJSONSerialization JSONObjectWithData:response
                                                                             options:NSJSONReadingMutableContainers
                                                                               error:&error];
        NSMutableArray *data = [imageResponse objectForKey:@"data"];
        [self populateImageArray:data];
        self.page++;
    } else {
        [NetworkChecker showNetworkMessage:@"No network connection found. An Internet connection is required for this application to work" title:@"No Network Connectivity!" delegate:self];
    }

}

- (void)populateImageArray:(NSArray *)data
{
    for (NSDictionary *obj in data) {
        NSString *title = [obj objectForKey:@"title"];
        NSString *stringURL = [obj objectForKey:@"link"];
        NSURL *url = [NSURL URLWithString:stringURL];
        ImageItem *image = [[ImageItem alloc] init];
        image.title = title;
        image.url = url;
        [self.imageArray addObject:image];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // contentOffset.y = distance from top left hand corner of screen. starts at 0
    // contentSize.height = total height inclusive of all the objects
    // frame.size.height = fixed height of the screen. iphone5 is 568
    if (fabsf(scrollView.contentOffset.y) >= fabsf(roundf(scrollView.contentSize.height-scrollView.frame.size.height))) {
//        dispatch_queue_t imageQueue = dispatch_queue_create("com.CityPorn.loadImagesQueue", NULL);
//        dispatch_async(imageQueue, ^{
//            [self loadMoreImages];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.collectionView reloadData];
//            });
//        });
        if ([NetworkChecker hasConnectivity]) {
            [self loadImages];
            [self.collectionView reloadData];
        } else {
            [NetworkChecker showNetworkMessage:@"No network connection found. An Internet connection is required for this application to work" title:@"No Network Connectivity!" delegate:self]; 
        }
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    if ([NetworkChecker hasConnectivity]) {
        return self.imageArray.count + 1;
    } else {
        return 0;
    }

}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    ImgurCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier
                                                                forIndexPath:indexPath];
    
    if (indexPath.item < _imageArray.count) {
        ImageItem *image = [_imageArray objectAtIndex:indexPath.row];
        [image getSmallThumbnailURL];
        
        UIActivityIndicatorView *activityIndicator = cell.activityIndicator;
        if (activityIndicator) {
            [activityIndicator removeFromSuperview];
        }
        [cell setupActivityIndicator];
        [cell.thumbnailImage setImageWithURL:[image getSmallThumbnailURL]
                            placeholderImage:nil
                                     options:SDWebImageProgressiveDownload
                                    progress:^(NSUInteger receivedSize, long long expectedSize) {
                                        [activityIndicator startAnimating];
                                    }
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                        [activityIndicator stopAnimating];
                                        [activityIndicator removeFromSuperview];
                                   }];
    } else {
        if ([NetworkChecker hasConnectivity]) {
            [cell setupActivityIndicator];
        }
    }
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        DetailViewController *vc = segue.destinationViewController;
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] lastObject];
        vc.imageIndex = indexPath;
        vc.imageArray = [NSMutableArray arrayWithArray:_imageArray];
    }

}


- (NSString *)getDataFrom:(NSString *)url
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:url]];
    [request setValue:CLIENTID forHTTPHeaderField:@"Authorization"];
    
    NSError *error;
    NSHTTPURLResponse *responseCode = nil;
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request
                                                  returningResponse:&responseCode
                                                              error:&error];
    if([responseCode statusCode] != 200) {
        NSLog(@"Error getting %@, HTTP status code %d", url, [responseCode statusCode]);
        return nil;
    }
    
    return [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
}

- (NSString *)getURL:(int)page
{
    NSString *p = [NSString stringWithFormat:@"%d", page];
    NSString *baseURL = @"https://api.imgur.com/3/gallery/r/cityporn/time/";
    NSString *url = [baseURL stringByAppendingString:p];
    return url;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
