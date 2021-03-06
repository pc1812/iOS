//
//  MineCoReadViewController.m
//  PictureBook
//
//  Created by Yasin on 2017/7/12.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import "MineCoReadViewController.h"
#import "CourseCollectionViewCell.h"
#import "MineRecordViewController.h"
#import "MineCoReadModel.h"
static NSString * const collectionIdentifier = @"collectionIdentifier";

@interface MineCoReadViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong)UICollectionView *collectionView;
@property (nonatomic) NSInteger pageNum;//页数
@property (nonatomic) BOOL isMorePage;
@property (nonatomic, strong)NSMutableArray *dataSource;
@property(nonatomic)UILabel *noLabel;
@end

@implementation MineCoReadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    self.collectionView.mj_header=[MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _pageNum=0;
        [self loadData];
        [self.collectionView.mj_header endRefreshing];
    }];
    
    self.collectionView.mj_footer=[MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if (_isMorePage) {
            _pageNum++;
            [self loadData];
        }
        [self.collectionView.mj_footer endRefreshing];
    }];
    // 马上进入刷新状态
    [self.collectionView.mj_header beginRefreshing];
}

-(UILabel *)noLabel
{
    if (!_noLabel) {
        self.noLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-250)/2, (SCREEN_HEIGHT-100-44-250)/2, 250, 250)];
        self.noLabel.backgroundColor=[UIColor clearColor];
        self.noLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:self.noLabel];
        
    }
    return _noLabel;
}

-(NSMutableArray *)dataSource{
    if (!_dataSource) {
        self.dataSource = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSource;
}

- (void)loadData{
    //得到基本固定参数字典，加入调用接口所需参数
    NSMutableDictionary *parame = [HttpManager necessaryParameterDictionary];
    [parame setObject:MINE_COURSE_Read forKey:@"uri"];
    //得到加盐MD5加密后的sign，并添加到参数字典
    [parame setObject:[HttpManager getAddSaltMD5Sign:parame] forKey:@"sign"];
    [parame setObject:@(_pageNum * kOffset) forKey:@"offset"];
    [parame setObject:@(kOffset) forKey:@"limit"];
    [parame setObject:@(2) forKey:@"status"];
    
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.labelText = @"加载中...";
    HUD.backgroundColor = [UIColor clearColor];
    
    [[HttpManager sharedManager] POST:MINE_COURSE_Read parame:parame sucess:^(id success) {
        
        if ([success[@"event"] isEqualToString:@"SUCCESS"]) {
            [HUD hide:YES];
            
            if (_pageNum == 0) {
                [self.dataSource removeAllObjects];
            }
            NSMutableArray *boyarray= success[@"data"];
            if (![boyarray isEqual:[NSNull null]]) {
                for (NSDictionary *dic in boyarray) {
                    MineCoReadModel *courseModel = [MineCoReadModel modelWithDictionary:dic];
                    [self.dataSource addObject:courseModel];
                }
            }
            
            if (self.dataSource.count) {
                self.noLabel.text = @"";
            }else{
                self.noLabel.text = @"暂无数据";
                
            }

            NSInteger total = 0;
            total = self.dataSource.count;
            NSInteger totalPages = total / kOffset;
            
            if (self.pageNum >= totalPages) {
                _isMorePage = NO;
                if (total > 0) {
                    self.collectionView.mj_footer.state = MJRefreshStateNoMoreData;
                }else{
                    self.collectionView.mj_footer.state = MJRefreshStateWillRefresh;
                }
            }else{
                self.collectionView.mj_footer.state = MJRefreshStateIdle;
                _isMorePage = YES;
            }
            [self.collectionView reloadData];
        }
    } failure:^(NSError *error) {
        [HUD hide:YES ];
        [Global showWithView:self.view withText:@"网络错误"];
    }];
}


- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.minimumInteritemSpacing = 12;
        layout.minimumLineSpacing = 12;
        layout.sectionInset = UIEdgeInsetsMake(12, 12, 12, 12);
        layout.itemSize = CGSizeMake(SCREEN_WIDTH - 36, 50 + (SCREEN_WIDTH - 36) *5/9);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - PBNew64 - 44) collectionViewLayout:layout];
        _collectionView.backgroundColor = RGBHex(0xf0f0f0);
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView registerClass:[CourseCollectionViewCell class] forCellWithReuseIdentifier:collectionIdentifier];
    }
    return _collectionView;
}

#pragma mark - collectionView代理方法实现
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CourseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionIdentifier forIndexPath:indexPath];
    MineCoReadModel *model = self.dataSource[indexPath.row];
    NSString * url = [NSString stringWithFormat:@"%@%@", Qiniu_host, model.coModel.icon[0]];
    [cell.photoImg sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"head_placeholder"]];
    NSString *courseStr;
    if (model.coModel.status == 0) {
        courseStr = [NSString stringWithFormat:@"%ld/%ld", (long)model.coModel.enter, (long)model.coModel.limit];
    }else if (model.coModel.status == 1){
        courseStr = @"正在开课";
    }else{
        courseStr = @"已结束";
    }
    [cell setName:model.coModel.name age:model.coModel.age course:courseStr day:[NSString stringWithFormat:@"%ld", (long)model.coModel.cycle] price:[NSString stringWithFormat:@"¥%.2f", model.coModel.price] water:@"" array:model.coModel.tag];
    return cell;
}

//点击
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
     MineCoReadModel *model = self.dataSource[indexPath.row];
    MineRecordViewController *recordVC = [[MineRecordViewController alloc] init];
    recordVC.readId = model.readId;
    [self.navigationController pushViewController:recordVC animated:YES];
}

//设置每个分区页眉的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    return CGSizeMake(SCREEN_WIDTH, 0.01f);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
