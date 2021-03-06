//
//  InfoCommentViewCell.h
//  PictureBook
//
//  Created by Yasin on 2017/7/15.
//  Copyright © 2017年 ZhiYuan Network. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoCommentViewCell : UITableViewCell

@property(nonatomic,strong)UILabel *nameLab;
@property(nonatomic,strong)UILabel *detailLab;
@property(nonatomic,strong)UILabel *timeLab;
@property(nonatomic,strong)UIImageView *photoImg;
@property (nonatomic, strong)UILabel *greeLab;

-(void)setName:(NSString *)name detail:(NSString *)detail time:(NSString *)time;

@end
