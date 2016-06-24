//
//  JJIndexBar.h
//  IndexBarDemo
//
//  Created by 梁晋杰 on 15/7/30.
//  Copyright (c) 2015年 LJJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JJIndexBar;

@protocol JJIndexBarDataSource

// 传入索引的数组
- (NSArray *)sectionIndexTitlesForJJIndexBar:(JJIndexBar *)indexBar;

// 必须实现的方法,获得title对应的索引
- (void)sectionForSectionJJIndexTitle:(NSString *)title atIndex:(NSInteger)index;

@end


@interface JJIndexBar : UIControl

@property (nonatomic, weak) id <JJIndexBarDataSource> dataSource;


// 所有的颜色用RGB模型-不要用白色，黑色，灰色或colorwithwhite，colorwithhue

// 是否获取选中的items (默认是 YES)
@property (nonatomic, assign) BOOL getSelectedItemsAfterPanGestureIsFinished;

/* 设置字体大小（如果您选择的字体太大，它将自动调整到最合适）
 (默认字体 HelveticaNeue 15号字体)
 */
@property (nonatomic, strong) UIFont *font;

/* 选中字体大小
 (默认是上面的字体  40号) */
@property (nonatomic, strong) UIFont *selectedItemFont;

// 字体颜色(不解释,默认黑)
@property (nonatomic, strong) UIColor *fontColor;

// 渐变暗 (默认 YES)
@property (nonatomic, assign) BOOL darkening;

// 渐变亮 (默认 YES)
@property (nonatomic, assign) BOOL fading;

// 选中颜色
@property (nonatomic, strong) UIColor *selectedItemFontColor;

// 居中样式不解释 (NSTextAligmentLeft, NSTextAligmentCenter or NSTextAligmentRight - default is NSTextAligmentCenter)
@property (nonatomic, assign) NSTextAlignment itemsAligment;

// 右间距默认10
@property (nonatomic, assign) CGFloat rightMargin;

// 顶部间距默认20/
@property (nonatomic, assign) CGFloat upperMargin;

// 底部间距默认20
@property (nonatomic, assign) CGFloat lowerMargin;

// item最大偏移量 默认75
@property (nonatomic,assign) CGFloat maxItemDeflection;

// 选中时偏移多少个items 默认3个
@property (nonatomic, assign) int rangeOfDeflection;

// 设置蒙版颜色 默认没有颜色clear
@property (nonatomic, strong) UIColor *curtainColor;

// 蒙版渐变度 0 - 1 之间 (默认0.2)
@property (nonatomic, assign) CGFloat curtainFade;

// 显示蒙版 默认NO
@property (nonatomic, assign) BOOL curtainStays;

// 是否移动蒙版 默认NO
@property (nonatomic, assign) BOOL curtainMoves;

// 蒙版上下是否有间距 默认NO
@property (nonatomic, assign) BOOL curtainMargins;

// item之间的最小间隙 默认5.0
@property (nonatomic, assign) CGFloat minimumGapBetweenItems;

// 是否自动设置页边距 默认为YES 间距的值为minimumGapBetweenItems
@property BOOL ergonomicHeight;

// 最大高度 默认400
@property (nonatomic, assign) CGFloat maxValueForErgonomicHeight;



// 重新布局方法
- (void)refreshIndexItems;


@end

