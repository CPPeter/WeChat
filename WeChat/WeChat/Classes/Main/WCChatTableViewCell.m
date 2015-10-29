//
//  WCChatTableViewCell.m
//  WeChat
//
//  Created by apple on 15/10/20.
//  Copyright © 2015年 PengC. All rights reserved.
//

#import "WCChatTableViewCell.h"

@implementation WCChatTableViewCell
{
    CGFloat origenX;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.headerImg];
        [self.contentView addSubview:self.messageImg];
        [self.contentView addSubview:self.messageText];
        
    }
    return self;
}
-(UIImageView *)messageImg
{
    if (!_messageImg) {
        _messageImg = [[UIImageView alloc]initWithFrame:CGRectMake(origenX, 2, 40, 40)];
        _messageImg.hidden = YES;
    }
    return _messageImg;
}
-(UILabel *)messageText
{
    if (!_messageText) {
        _messageText = [[UILabel alloc]initWithFrame:CGRectMake(origenX, 2, kScreen_Width - 20 - origenX, 40)];
        _messageText.hidden = YES;
    }
    return _messageText;
}
-(UIImageView *)headerImg
{
    if (!_headerImg) {
        _headerImg = [[UIImageView alloc]initWithFrame:CGRectMake(10, 2, 40, 40)];
        origenX = CGRectGetMaxX(_headerImg.frame) + 5;
    }
    return _headerImg;
}

-(void)setIsoutgoing:(BOOL)isoutgoing
{
    _isoutgoing = isoutgoing;
    if (_isoutgoing) {
        self.messageText.textAlignment = NSTextAlignmentRight;
        self.messageText.x = 20;
        self.messageImg.x = kScreen_Width - 50 - 45;
        XMPPvCardTemp * myTemp = [WCXMPPTool sharedWCXMPPTool].vCard.myvCardTemp;
        if(myTemp.photo)
        {
            NSData *headerdata = myTemp.photo;
            self.headerImg.image = [UIImage imageWithData:headerdata];
        }
        self.headerImg.x = kScreen_Width - 50;
    }
    else
    {
        self.messageImg.x = origenX;
        self.messageText.x = origenX;
        self.messageText.textAlignment = NSTextAlignmentLeft;
        self.headerImg.x = 10;
        self.headerImg.image = nil;
    }
}
@end
