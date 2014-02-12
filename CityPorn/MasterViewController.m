//
//  MasterViewController.m
//  CityPorn
//
//  Created by Nai Chng on 7/2/14.
//  Copyright (c) 2014 NYC. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "InfoViewController.h"
#import "UIImage+animatedGIF.h"
#import "ImageItem.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ImgurCell.h"

@interface MasterViewController () {
    NSMutableArray *_imageArray;
    int _page;
    UIActivityIndicatorView *_activityIndicator;
}
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    // load data here
    [self initialDataFetch];
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

- (void)initialDataFetch
{
    _page = 1;
    if(_imageArray == nil)
        _imageArray = [[NSMutableArray alloc] init];
    
    NSString *url = [self getURL:_page];
    NSData *response = [[self getDataFrom:url] dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = [[NSError alloc] init];
    NSMutableDictionary *imageResponse = [NSJSONSerialization JSONObjectWithData:response
                                                                         options:NSJSONReadingMutableContainers
                                                                           error:&error];
    NSMutableArray *imgurArray = [[NSMutableArray alloc] init];
    imgurArray = [imageResponse objectForKey:@"data"];
    [self populateImageArray:imgurArray];
}

#pragma mark - Collection View

- (void)loadMoreImages
{
    _page++;
    NSString *url = [self getURL:_page];
    NSData *response = [[self getDataFrom:url] dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = [[NSError alloc] init];
    NSMutableDictionary *imageResponse = [NSJSONSerialization JSONObjectWithData:response
                                                                         options:NSJSONReadingMutableContainers
                                                                           error:&error];
    NSMutableArray *data = [imageResponse objectForKey:@"data"];
    [self populateImageArray:data];
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
        [_imageArray addObject:image];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // contentOffset.y = distance from top left hand corner of screen. starts at 0
    // contentSize.height = total height inclusive of all the objects
    // frame.size.height = fixed height of the screen. iphone5 is 568
    if (scrollView.contentOffset.y == roundf(scrollView.contentSize.height-scrollView.frame.size.height)) {
        [self loadMoreImages];
        [self.collectionView reloadData];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return _imageArray.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    ImgurCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier
                                                                forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[ImgurCell alloc] init];
    }
    
    if (indexPath.item < _imageArray.count) {
        ImageItem *image = [_imageArray objectAtIndex:indexPath.row];
        [image getSmallThumbnailURL];
        
        UIActivityIndicatorView *activityIndicator = cell.activityIndicator;
        if (activityIndicator) {
            [activityIndicator removeFromSuperview];
        }
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityIndicator.hidesWhenStopped = YES;
        activityIndicator.hidden = NO;
        //[activityIndicator startAnimating];
        activityIndicator.center = CGPointMake(cell.frame.size.width /2, cell.frame.size.height/2);
        activityIndicator.tag = 200;
        
        [cell.thumbnailImage addSubview:activityIndicator];
        [cell.thumbnailImage setImageWithURL:[image getSmallThumbnailURL]
                            placeholderImage:nil
                                     options:SDWebImageProgressiveDownload
                                    progress:^(NSUInteger receivedSize, long long expectedSize) {
                                        if (!activityIndicator) {
                                            [activityIndicator startAnimating];
                                        }
                                    }
                                   completed:^(UIImage *completeImage, NSError *error, SDImageCacheType cacheType) {
                                       if (completeImage) {
                                           [activityIndicator stopAnimating];
                                           [activityIndicator removeFromSuperview];
                                       }
                                   }];
    } else {
        UIActivityIndicatorView *activityIndicator = cell.activityIndicator;
        if (activityIndicator) {
            [activityIndicator removeFromSuperview];
        }
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityIndicator.hidesWhenStopped = YES;
        activityIndicator.hidden = NO;
        //[activityIndicator startAnimating];
        activityIndicator.center = CGPointMake(cell.frame.size.width /2, cell.frame.size.height/2);
        activityIndicator.tag = 200;
        [cell.thumbnailImage addSubview:activityIndicator];
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
    
    if ([[segue identifier] isEqualToString:@"showInfo"]) {
        // do something
    }
}


- (NSString *)getDataFrom:(NSString *)url
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:url]];
    [request setValue:CLIENTID forHTTPHeaderField:@"Authorization"];
    
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *responseCode = nil;
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request
                                                  returningResponse:&responseCode
                                                              error:&error];
    if([responseCode statusCode] != 200){
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
