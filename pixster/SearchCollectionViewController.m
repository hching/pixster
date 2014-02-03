//
//  SearchCollectionViewController.m
//  pixster
//
//  Created by Henry Ching on 2/2/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "SearchCollectionViewController.h"
#import "UIImageView+AFNetworking.h"
#import "AFNetworking.h"
#import "ImageCell.h"

@interface SearchCollectionViewController ()

@property (nonatomic, strong) NSMutableArray *imageResults;
@property (nonatomic) NSInteger totalImages;

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UICollectionView *imageCollectionView;

@end

@implementation SearchCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Pixster";
        self.imageResults = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UINib *imageCellNib = [UINib nibWithNibName:@"ImageCell" bundle:nil];
    [self.imageCollectionView registerNib:imageCellNib forCellWithReuseIdentifier:@"ImageCell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.imageResults count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ImageCell";
    ImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    UIImageView *imageView = cell.imageCellView;
    
    // Clear the previous image
    imageView.image = nil;
    [imageView setImageWithURL:[NSURL URLWithString:[self.imageResults[indexPath.row] valueForKeyPath:@"tbUrl"]]];
    return cell;
}

#pragma mark - UISearchBar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@&rsz=8", [searchBar.text stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        id results = [JSON valueForKeyPath:@"responseData.results"];
        if ([results isKindOfClass:[NSArray class]]) {
            [self.imageResults removeAllObjects];
            [self.imageResults addObjectsFromArray:results];
            self.totalImages = 8;
            [self.imageCollectionView reloadData];
            [self.view endEditing:YES];
        }
    } failure:nil];
    
    [operation start];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [searchBar resignFirstResponder];
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize cellSize = CGSizeMake(150, 100);
    return cellSize;
}

#pragma mark - UIScrollView delegate

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@&rsz=8&start=%d", [self.searchBar.text stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding], self.totalImages]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            id results = [JSON valueForKeyPath:@"responseData.results"];
            if ([results isKindOfClass:[NSArray class]]) {
                [self.imageResults addObjectsFromArray:results];
                self.totalImages = self.totalImages + 8;
                [self.imageCollectionView reloadData];
            }
        } failure:nil];
        
        [operation start];
}

@end
