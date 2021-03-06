//
//  MinePicViewController.m
//  PictureBook
//
//  Created by Yasin on 2017/7/12.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "MinePicViewController.h"
#import "SegmentTapView.h"
#import "FlipTableView.h"
#import "MinePicFreeViewController.h"
#import "MinePicPayViewController.h"

@interface MinePicViewController ()<SegmentTapViewDelegate,FlipTableViewDelegate, UIScrollViewDelegate>

@property(nonatomic,strong)FlipTableView *flipView;
@property(nonatomic,strong)SegmentTapView *segment;
@property(nonatomic,strong)NSMutableArray *controllsArray;
@property(nonatomic,strong)UIScrollView *scrollView;
@end

@implementation MinePicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.titleView = [UINavigationItem titleViewForTitle:@"我的绘本"];
    
    [self initSegment];
    [self initFlipTableView];
}

-(void)initSegment{
    if (IS_IPHONE5()) {
        self.segment = [[SegmentTapView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44) withDataArray:[NSArray arrayWithObjects:@"免费绘本",@"付费绘本",nil] withFont:14];
        self.segment.delegate = self;
        self.segment.backgroundColor=[Global convertHexToRGB:@"f7f7f7"];
        [self.view addSubview:self.segment];
    }else{
        self.segment = [[SegmentTapView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44) withDataArray:[NSArray arrayWithObjects:@"免费绘本",@"付费绘本",nil] withFont:16];
        self.segment.delegate = self;
        self.segment.backgroundColor=[Global convertHexToRGB:@"f7f7f7"];
        [self.view addSubview:self.segment];
    }
}

-(void)initFlipTableView{
   
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, SCREEN_HEIGHT-PBNew64-44)];
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    
    self.scrollView.pagingEnabled = YES;
    self.scrollView.bounces = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * 2, 0);
    //免费绘本
    MinePicFreeViewController *v1 = [[MinePicFreeViewController alloc] init];
    [self addChildViewController:v1];
    [self.scrollView addSubview:v1.view];
    v1.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-PBNew64-44);
    
    //付费绘本
    MinePicPayViewController *v2 = [[MinePicPayViewController alloc] init];
    [self addChildViewController:v2];
    [self.scrollView addSubview:v2.view];
    v2.view.frame = CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT-PBNew64-44);
   
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int index = scrollView.contentOffset.x / SCREEN_WIDTH;
    [self.segment selectIndex:index + 1];
    
    
}
#pragma mark -------- select Index
-(void)selectedIndex:(NSInteger)index{
   self.scrollView.contentOffset = CGPointMake(SCREEN_WIDTH * index, 0);
}

-(void)scrollChangeToIndex:(NSInteger)index{
    [self.segment selectIndex:index];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
