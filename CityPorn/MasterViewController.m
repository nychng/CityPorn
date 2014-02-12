//
//  MasterViewController.m
//  CityPorn
//
//  Created by Nai Chng on 7/2/14.
//  Copyright (c) 2014 NYC. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "UIImage+animatedGIF.h"
#import "ImageItem.h"
#import <SDWebImage/UIImageView+WebCache.h>



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
    NSLog(@"%@",imgurArray);
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
    return _imageArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier
                                                                           forIndexPath:indexPath];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
    ImageItem *image = [_imageArray objectAtIndex:indexPath.row];
    
    UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[cell viewWithTag:200];
    if (activityIndicator) [activityIndicator removeFromSuperview];
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.hidesWhenStopped = YES;
    activityIndicator.hidden = NO;
    [activityIndicator startAnimating];
    activityIndicator.center = CGPointMake(cell.frame.size.width /2, cell.frame.size.height/2);
    activityIndicator.tag = 200;
    [imageView addSubview:activityIndicator];
    
    [imageView setImageWithURL:image.url
              placeholderImage:nil
                       options:SDWebImageProgressiveDownload
                      progress:^(NSUInteger receivedSize, long long expectedSize) { [activityIndicator startAnimating]; }
                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                         if (image) {
                             [activityIndicator stopAnimating];
                             [activityIndicator removeFromSuperview];
                         }
                     }];


    return cell;
}

- (UIActivityIndicatorView *)activityIndicator:(UICollectionViewCell *)cell
{
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.hidesWhenStopped = YES;
    activityIndicator.hidden = NO;
    //activityIndicator.center =

    return activityIndicator;
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

//- (void)configure
//{
//    // some stuff
//    SDWebImageManager *manager = [SDWebImageManager sharedManager];
//    self.imageOperation = [manager downloadWithURL:[NSURL URLWithString:self.move.image]
//                                           options:SDWebImageRetryFailed
//                                          progress:nil
//                                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
//                                             if (image)
//                                                 self.moveImageView.image = image;
//                                         }];
//
//}

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
