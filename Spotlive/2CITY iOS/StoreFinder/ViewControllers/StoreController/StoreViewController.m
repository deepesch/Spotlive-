//
//  StoreViewController.m
//  Galavanta
//
//
//  Copyright (c) 2014 MERKABAHNK LLC. All rights reserved.
//

#import "StoreViewController.h"
#import "DetailViewController.h"

@interface StoreViewController () <MGListViewDelegate>

@end

@implementation StoreViewController

@synthesize listViewMain;
@synthesize storeCategory;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self beginParsing];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.titleView = [MGUIAppearance createLogo:HEADER_LOGO];
    self.view.backgroundColor = BG_VIEW_COLOR;
    
    [MGUIAppearance enhanceNavBarController:self.navigationController
                               barTintColor:WHITE_TEXT_COLOR
                                  tintColor:WHITE_TEXT_COLOR
                             titleTextColor:WHITE_TEXT_COLOR];
    
    listViewMain.delegate = self;
    listViewMain.cellHeight = 250;
    
    [listViewMain registerNibName:@"FeaturedCell" cellIndentifier:@"FeaturedCell"];
    [listViewMain baseInit];
    
    
    
}


-(void)beginParsing {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = LOCALIZED(@"LOADING");
    
    [self.view addSubview:hud];
    [self.view setUserInteractionEnabled:NO];
	[hud showAnimated:YES whileExecutingBlock:^{
        
		[self performParsing];
        
	} completionBlock:^{
        
		[hud removeFromSuperview];
        [self.view setUserInteractionEnabled:YES];
        [listViewMain reloadData];
        
        if(listViewMain.arrayData == nil || listViewMain.arrayData.count == 0) {
            
            UIColor* color = [THEME_ORANGE_COLOR colorWithAlphaComponent:0.70];
            [MGUtilities showStatusNotifier:LOCALIZED(@"NO_RESULTS")
                                  textColor:[UIColor whiteColor]
                             viewController:self
                                   duration:0.5f
                                    bgColor:color
                                        atY:64];
        }
    }];
    
}

-(void) performParsing {
    
    listViewMain.arrayData = [NSMutableArray arrayWithArray:
                              [CoreDataController getStoreByCategoryId:storeCategory.category_id]];
    
//    NSArray *sortedArray = [listViewMain.arrayData sortedArrayUsingComparator: ^(Store* obj1, Store* obj2) {
//        
//        float rating1 = [obj1.rating_total floatValue] / [obj1.rating_count floatValue];
//        float rating2 = [obj2.rating_total floatValue] / [obj2.rating_count floatValue];
//        
//        rating1 = [obj1.rating_total floatValue] == 0 ? 0 : rating1;
//        rating2 = [obj2.rating_total floatValue] == 0 ? 0 : rating2;
//        
//        if (rating1 == 0 && rating2 == 0) {
//            return (NSComparisonResult)NSOrderedSame;
//        }
//        
//        if (rating1 < rating2 ) {
//            return (NSComparisonResult)NSOrderedDescending;
//        }
//        
//        return (NSComparisonResult)NSOrderedAscending;
//    }];
//    
//    listViewMain.arrayData = [NSMutableArray arrayWithArray:sortedArray];
//    [listViewMain reloadData];
}

-(void)didClickBarButtonMenu:(id)sender {
    [self.slidingViewController anchorTopViewToRightAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

-(void) MGListView:(MGListView *)_listView didSelectCell:(MGListCell *)cell indexPath:(NSIndexPath *)indexPath {
    
    DetailViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"storyboardDetail"];
    vc.store = listViewMain.arrayData[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
    
}

-(UITableViewCell*)MGListView:(MGListView *)listView1 didCreateCell:(MGListCell *)cell indexPath:(NSIndexPath *)indexPath {
    
    if(cell != nil) {
        
        Store* store = [listViewMain.arrayData objectAtIndex:indexPath.row];
        Photo* p = [CoreDataController getStorePhotoByStoreId:store.store_id];
        Favorite* fave = [CoreDataController getFavoriteByStoreId:store.store_id];
        
        cell.imgViewFeatured.hidden = NO;
        cell.imgViewFave.hidden = NO;
        
        if(fave == nil)
            cell.imgViewFave.hidden = YES;
        
        if([store.featured intValue] < 1)
            cell.imgViewFeatured.hidden = YES;
        
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        
        [cell.labelDescription setText:store.phone_no];
        [cell.labelDateAdded setText:store.sms_no];

        if(p != nil)
            [self setImage:p.thumb_url imageView:cell.imgViewThumb];
        else
            [self setImage:nil imageView:cell.imgViewThumb];
        
        
        cell.labelHeader1.backgroundColor = [BLACK_TEXT_COLOR colorWithAlphaComponent:0.66];
        
        cell.lblNonSelectorTitle.textColor = THEME_ORANGE_COLOR;
        cell.labelSubtitle.textColor = WHITE_TEXT_COLOR;
        
        cell.lblNonSelectorTitle.text = store.store_name;
        cell.labelSubtitle.text = store.store_address;
        
        cell.ratingView.notSelectedImage = [UIImage imageNamed:STAR_EMPTY];
        cell.ratingView.halfSelectedImage = [UIImage imageNamed:STAR_HALF];
        cell.ratingView.fullSelectedImage = [UIImage imageNamed:STAR_FILL];
        cell.ratingView.editable = YES;
        cell.ratingView.maxRating = 5;
        cell.ratingView.midMargin = 0;
        cell.ratingView.userInteractionEnabled = NO;
        
        double rating = [store.rating_total doubleValue]/[store.rating_count doubleValue];
        cell.ratingView.rating = rating;
        
        NSString* info = [NSString stringWithFormat:@"%.2f %@ %@ %@", rating, LOCALIZED(@"RATING_AVERAGE"), store.rating_count, LOCALIZED(@"RATING")];
        
        if([store.rating_total doubleValue] == 0 || [store.rating_count doubleValue] == 0 )
            info = LOCALIZED(@"NO_RATING");
        
        cell.labelExtraInfo.text = info;
        
    }
    
    return cell;
}

-(void)MGListView:(MGListView *)listView scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

-(void)setImage:(NSString*)imageUrl imageView:(UIImageView*)imgView {
    
    [imgView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:SLIDER_PLACEHOLDER]];
}

@end
