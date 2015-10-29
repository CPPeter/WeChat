//
//  UIView+Frame.h
//  IOS-Categories
//
//  Created by Jakey on 14/12/15.
//  Copyright (c) 2014年 www.skyfox.org. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Frame)
// shortcuts for frame properties
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGSize size;

// shortcuts for positions
@property (nonatomic) CGFloat centerX;
@property (nonatomic) CGFloat centerY;


@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat bottom;
@property (nonatomic) CGFloat right;
@property (nonatomic) CGFloat left;

@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;



/**
 *  Next Content Add By SiBu_iOS_Dev
 */
@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;
@property (nonatomic) BOOL hiddenWithAnimation;

-(CGFloat)maxX;
-(CGFloat)maxY;
-(CGFloat)minX;
-(CGFloat)minY;
-(NSString*)frameString;

//得到此view 所在的viewController
- (UIViewController *)viewController;

#pragma mark---布局常用------
- (void)centerInRect:(CGRect)rect;
- (void)centerVerticallyInRect:(CGRect)rect;
- (void)centerHorizontallyInRect:(CGRect)rect;
//相对父视图居中
- (void)centerInSuperView;
//垂直居中
- (void)centerVerticallyInSuperView;
//水平居中
- (void)centerHorizontallyInSuperView;

- (void)centerHorizontallyBelow:(UIView *)view padding:(CGFloat)padding;
- (void)centerHorizontallyBelow:(UIView *)view;



#pragma mark -
#pragma mark----Add By SIBU NET 2015.8---------

// Move via offset
- (void) moveBy: (CGPoint) delta;

// Scaling
- (void) scaleBy: (CGFloat) scaleFactor;


@end