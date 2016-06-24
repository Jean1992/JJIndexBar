//
//  JJIndexBar.m
//  IndexBarDemo
//
//  Created by 梁晋杰 on 15/7/30.
//  Copyright (c) 2015年 LJJ. All rights reserved.
//

#import "JJIndexBar.h"
#import <QuartzCore/QuartzCore.h>

@interface JJIndexBar ()

// items
@property (nonatomic, strong) NSArray *indexItems;
@property (nonatomic, strong) NSArray *itemsAtrributes;

@property (nonatomic, strong) NSNumber *section;

// items尺寸
@property (nonatomic) CGFloat itemsOffset;
@property (nonatomic) CGPoint firstItemOrigin;
@property (nonatomic) CGSize indexSize;
@property (nonatomic, assign) CGFloat maxWidth;
@property (nonatomic) BOOL animate;

// curtains
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic) BOOL curtain;
@property (nonatomic, assign) CGFloat curtainFadeFactor;


@property (nonatomic, assign) BOOL dot;
@property (nonatomic, assign) int times;


@end

@implementation JJIndexBar
//@synthesize自动生成getters和setters
@synthesize fontColor = _fontColor;

#pragma mark - getters方法

- (UIColor *)fontColor {
    if (!_fontColor) {
        self.fontColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    }
    return _fontColor;
}


- (UIColor *)selectedItemFontColor {
    if (!_selectedItemFontColor) {
        _selectedItemFontColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
        
    }
    return _selectedItemFontColor;
}


#pragma mark - setters方法

- (void)setCurtainColor:(UIColor *)curtainColor {
    _curtainColor = curtainColor;
    
}


- (void)setFontColor:(UIColor *)fontColor {
    // 在set方法里屏蔽黑白灰,避免出错
    if ([fontColor isEqual:[UIColor grayColor]]) {
        _fontColor = [UIColor colorWithRed:0.5
                                     green:0.5
                                      blue:0.5
                                     alpha:1.0];
    } else if ([fontColor isEqual:[UIColor blackColor]]) {
        _fontColor = [UIColor colorWithRed:0.0
                                     green:0.0
                                      blue:0.0
                                     alpha:1.0];
    } else if ([fontColor isEqual:[UIColor whiteColor]]) {
        _fontColor = [UIColor colorWithRed:1.0
                                     green:1.0
                                      blue:1.0
                                     alpha:1.0];
    } else _fontColor = fontColor;
}

- (void)setCurtainFade:(CGFloat)curtainFade {
    if (self.gradientLayer) {
        [self.gradientLayer removeFromSuperlayer];
        self.gradientLayer = nil;
    }
    _curtainFade = curtainFade;
}


- (void)setDataSource:(id<JJIndexBarDataSource>)dataSource {
    _dataSource = dataSource;
    self.indexItems = [dataSource sectionIndexTitlesForJJIndexBar:self];
}


#pragma mark - 初始化方法

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 设置所有默认值
        self.backgroundColor = [UIColor clearColor];
        self.darkening = YES;
        self.fading = YES;
        self.itemsAligment = NSTextAlignmentCenter;
        self.upperMargin = 20.0;
        self.lowerMargin = 20.0;
        self.rightMargin = 10.0;
        self.maxItemDeflection = 100.0;
        self.rangeOfDeflection = 3;
        self.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0];
        self.selectedItemFont = [UIFont fontWithName:@"HelveticaNeue" size:50.0];
        self.ergonomicHeight = YES;
        self.maxValueForErgonomicHeight = 400.0;
        self.minimumGapBetweenItems = 5.0;
        self.getSelectedItemsAfterPanGestureIsFinished = YES;
    }
    return self;
}


- (id)init {
    self = [self initWithFrame:CGRectZero];
    return self;
}

- (void)didMoveToSuperview {
    [self getAllItemsSize];
    [self initialiseAllAttributes];
    [self resetPosition];
}

// 刷新所有items
- (void)refreshIndexItems {
    // 如果items有值,把它移除掉再创建
    if (self.itemsAtrributes) {
        for (NSDictionary *item in self.itemsAtrributes) {
            CALayer *layer = item[@"layer"];
            [layer removeFromSuperlayer];
        }
        self.itemsAtrributes = nil;
    }
    
    if (self.gradientLayer) [self.gradientLayer removeFromSuperlayer];
    
    
    self.indexItems = [self.dataSource sectionIndexTitlesForJJIndexBar:self];
    [self getAllItemsSize];
    [self initialiseAllAttributes];
    [self resetPosition];
}


#pragma mark - 计算items的尺寸

- (void)getAllItemsSize {
    CGSize indexSize = CGSizeZero;
    
    // 获取字体大小
    CGFloat lineHeight = self.font.lineHeight;
    CGFloat maxlineHeight = self.selectedItemFont.capHeight;
    CGFloat capitalLetterHeight = self.font.capHeight;
    CGFloat ascender = self.font.ascender;
    CGFloat descender = - self.font.descender;
    CGFloat entireHeight = ascender;
    
    
    if ([self checkForLowerCase] && [self checkForUpperCase]) {
        entireHeight = lineHeight;
        maxlineHeight = self.selectedItemFont.lineHeight;
    } else if ([self checkForLowerCase] && ![self checkForUpperCase]) {
        entireHeight = capitalLetterHeight + descender;
        maxlineHeight = self.selectedItemFont.lineHeight;
    }
    
    // 计算items的大小
    for (NSString *item in self.indexItems) {
        NSMutableDictionary *attr = [NSMutableDictionary dictionary];
        attr[NSFontAttributeName] = self.font;
        CGSize currentItemSize = [item sizeWithAttributes:attr];
        indexSize.height += entireHeight;
        if (currentItemSize.width > indexSize.width) {
            indexSize.width = currentItemSize.width;
        }
    }
    
    
    for (NSString *item in self.indexItems) {
        NSMutableDictionary *attr = [NSMutableDictionary dictionary];
        attr[NSFontAttributeName] = self.selectedItemFont;
        CGSize currentItemSize = [item sizeWithAttributes:attr];
        if (currentItemSize.width > self.maxWidth) {
            self.maxWidth = currentItemSize.width;
        }
        if (currentItemSize.width > self.maxItemDeflection) {
            self.maxItemDeflection = currentItemSize.width;
        }
    }
    
    CGFloat optimalIndexHeight = indexSize.height;
    if (optimalIndexHeight > self.maxValueForErgonomicHeight) optimalIndexHeight = self.maxValueForErgonomicHeight;
    CGFloat offsetRatio = self.minimumGapBetweenItems * (float)([self.indexItems count]-1) + optimalIndexHeight + maxlineHeight / 1.5;
    if (self.ergonomicHeight && (self.bounds.size.height - offsetRatio > 0.0)) {
        self.upperMargin = (self.bounds.size.height - offsetRatio)/2.0;
        self.lowerMargin = self.upperMargin;
    }
    

    if (indexSize.height  > self.bounds.size.height - (self.upperMargin + self.lowerMargin) - (self.minimumGapBetweenItems * [self.indexItems count])) {
        self.font = [self.font fontWithSize:(self.font.pointSize - 0.1)];
        [self getAllItemsSize];
        
    } else {
        self.itemsOffset = ((self.bounds.size.height - (self.upperMargin + self.lowerMargin + maxlineHeight / 1.5)) - indexSize.height) / (float)([self.indexItems count]-1);
        
        
        
        
        if (self.itemsAligment == NSTextAlignmentRight) {
            self.firstItemOrigin = CGPointMake(self.bounds.size.width - self.rightMargin,
                                               self.upperMargin + maxlineHeight / 2.5 + entireHeight / 2.0);
            
        } else if (self.itemsAligment == NSTextAlignmentCenter) {
            self.firstItemOrigin = CGPointMake(self.bounds.size.width - self.rightMargin - indexSize.width/2,
                                               self.upperMargin + maxlineHeight / 2.5 + entireHeight / 2.0);
            
        } else self.firstItemOrigin = CGPointMake(self.bounds.size.width - self.rightMargin - indexSize.width,
                                                  self.upperMargin + maxlineHeight / 2.5 + entireHeight / 2.0);
        
        //
        self.itemsOffset += entireHeight;
        self.indexSize = indexSize;
    }
    
    if (self.rangeOfDeflection > self.indexItems.count * 0.5 - 1) self.rangeOfDeflection = self.indexItems.count * 0.5 - 1;
}


- (BOOL)checkForLowerCase {
    NSCharacterSet *lowerCaseSet = [NSCharacterSet lowercaseLetterCharacterSet];
    for (NSString *item in self.indexItems) {
        if ([item rangeOfCharacterFromSet:lowerCaseSet].location != NSNotFound) return YES;
    }
    return NO;
}


- (BOOL)checkForUpperCase {
    NSCharacterSet *upperCaseSet = [NSCharacterSet uppercaseLetterCharacterSet];
    for (NSString *item in self.indexItems) {
        if ([item rangeOfCharacterFromSet:upperCaseSet].location != NSNotFound) return YES;
    }
    return NO;
}


- (void) initialiseAllAttributes {
    CGFloat verticalPos = self.firstItemOrigin.y;
    NSMutableArray *newItemsAttributes = [NSMutableArray new];
    
    int count = 0;
    
    for (NSString *item in self.indexItems) {
        
        CGPoint point;
        NSMutableDictionary *attr = [NSMutableDictionary dictionary];
        attr[NSFontAttributeName] = self.font;
        if (self.itemsAligment == NSTextAlignmentCenter){
            
            CGSize itemSize = [item sizeWithAttributes:attr];
            point.x = self.firstItemOrigin.x - itemSize.width/2;
        } else if (self.itemsAligment == NSTextAlignmentRight) {
            
            CGSize itemSize = [item sizeWithAttributes:attr];
            point.x = self.firstItemOrigin.x - itemSize.width;
        } else point.x = self.firstItemOrigin.x;
        
        point.y = verticalPos;
        NSValue *newValueForPoint = [NSValue valueWithCGPoint:point];
        
        
        if (!self.itemsAtrributes) {
            CATextLayer * singleItemTextLayer = [CATextLayer layer];
            
            NSNumber *alpha = @(CGColorGetAlpha([self.fontColor CGColor]));
            
            // 不想写注释了
            NSNumber *zPosition = @(5.0);
            
            NSCache *itemAttributes = [@{@"item":item,
                                         @"origin":newValueForPoint,
                                         @"position":newValueForPoint,
                                         @"font":self.font,
                                         @"color":self.fontColor,
                                         @"alpha":alpha,
                                         @"zPosition":zPosition,
                                         @"layer":singleItemTextLayer}mutableCopy];
            
            [newItemsAttributes addObject:itemAttributes];
        } else {
            self.itemsAtrributes[count][@"origin"] = newValueForPoint;
            self.itemsAtrributes[count][@"position"] = newValueForPoint;
        }
        
        verticalPos += self.itemsOffset;
        count ++;
        
        
    }
    if (self.curtainColor) [self addCurtain];
    if (!self.itemsAtrributes) self.itemsAtrributes = newItemsAttributes;
}

- (void) resetPosition {
    for (NSCache *itemAttributes in self.itemsAtrributes){
        CGPoint origin = [[itemAttributes objectForKey:@"origin"] CGPointValue];
        [itemAttributes setObject:[NSValue valueWithCGPoint:origin] forKey:@"position"];
        [itemAttributes setObject:self.font forKey:@"font"];
        [itemAttributes setObject:@(1.0) forKey:@"alpha"];
        [itemAttributes setObject:self.fontColor forKey:@"color"];
        [itemAttributes setObject:@(5.0) forKey:@"zPosition"];
        
    }
    
    [self drawIndex];
    [self setNeedsDisplay];
    
    self.animate = YES;
}


#pragma mark - 计算items位置
- (void) positionForIndexItemsWhilePanLocation:(CGPoint)location {
    CGFloat verticalPos = self.firstItemOrigin.y;
    
    int section = 0;
    for (NSCache *itemAttributes in self.itemsAtrributes) {
        
        CGFloat alpha = [[itemAttributes objectForKey: @"alpha"] floatValue];
        CGPoint point = [[itemAttributes objectForKey:@"position"] CGPointValue];
        CGPoint origin = [[itemAttributes objectForKey:@"origin"] CGPointValue];
        CGFloat fontSize = [[itemAttributes objectForKey:@"fontSize"] floatValue];
        UIColor *fontColor;
        
        BOOL inRange = NO;
        
        
        float mappedAmplitude = self.maxItemDeflection / self.itemsOffset / ((float)self.rangeOfDeflection);
        
        BOOL min = location.y > point.y - ((float)self.rangeOfDeflection * self.itemsOffset);
        BOOL max = location.y < point.y + ((float)self.rangeOfDeflection * self.itemsOffset);
        
        if (min && max) {
            
            float differenceMappedToAngle = 90.0 / (self.itemsOffset * (float)self.rangeOfDeflection);
            float angle = (fabs(point.y - location.y)* differenceMappedToAngle);
            float angleInRadians = angle * (M_PI/180);
            float arcusTan = fabs(atan(angleInRadians));
            
            point.x = origin.x - (self.maxItemDeflection) + (fabs(point.y - location.y) * mappedAmplitude) * (arcusTan);
            
            point.x = MIN(point.x, origin.x);
            
            float differenceMappedToRange = self.rangeOfDeflection / (self.rangeOfDeflection * self.itemsOffset);
            
            CGFloat zPosition = self.rangeOfDeflection - fabs(point.y - location.y) * differenceMappedToRange;
            
            [itemAttributes setObject:@(5.0 + zPosition) forKey:@"zPosition"];
            
            CGFloat fontIncrease = (self.maxItemDeflection - (fabs(point.y - location.y)) *
                                    mappedAmplitude) / (self.maxItemDeflection / (self.selectedItemFont.pointSize - self.font.pointSize));
            
            fontIncrease = MAX(fontIncrease, 0.0);
            
            fontSize = self.font.pointSize + fontIncrease;
            
            float differenceMappedToColorChange = 1.0 / (self.rangeOfDeflection * self.itemsOffset);
            CGFloat colorChange = fabs(point.y - location.y) * differenceMappedToColorChange;
            
            if (self.darkening) {
                fontColor = [self darkerColor:self.fontColor by: colorChange];
            } else fontColor = self.fontColor;
            
            if (self.fading) {
                alpha = colorChange;
            } else alpha = 1.0;
            
            [itemAttributes setObject:[UIFont fontWithName:self.font.fontName size:fontSize] forKey:@"font"];
            
            [itemAttributes setObject:fontColor forKey:@"color"];
            
            BOOL selectedInRange  = location.y > point.y - self.itemsOffset / 2.0 && location.y < point.y + self.itemsOffset / 2.0;
            
            BOOL firstItemInRange = (section == 0 && (location.y < self.upperMargin + self.selectedItemFont.pointSize / 2.0));
            BOOL lastItemInRange = (section == [self.itemsAtrributes  count] - 1 &&
                                    location.y > self.bounds.size.height - (self.lowerMargin + self.selectedItemFont.pointSize / 2.0));
            
            if (selectedInRange || firstItemInRange || lastItemInRange) {
                alpha = 1.0;
                
                [itemAttributes setObject:[UIFont fontWithName:self.selectedItemFont.fontName size:fontSize] forKey:@"font"];
                [itemAttributes setObject:self.selectedItemFontColor forKey:@"color"];
                [itemAttributes setObject:@(10.0) forKey:@"zPosition"];
                if (!self.getSelectedItemsAfterPanGestureIsFinished && [self.section integerValue] != section) {
                    [self.dataSource sectionForSectionJJIndexTitle:self.indexItems[section] atIndex:section];
                }
                self.section = @(section);
                
            }
            
            inRange = YES;
            
        }
        
        if (!inRange) {
            
            point.x = origin.x;
            alpha = 1.0;
            [itemAttributes setObject:self.font forKey:@"font"];
            fontColor = self.fontColor;
            [itemAttributes setObject:self.fontColor forKey:@"color"];
            [itemAttributes setObject:@(5.0) forKey:@"zPosition"];
        }
        
        point.y = verticalPos;
        NSValue *newValueForPoint = [NSValue valueWithCGPoint:point];
        [itemAttributes setObject:newValueForPoint forKey:@"position"];
        [itemAttributes setObject:@(alpha) forKey:@"alpha"];
        verticalPos += self.itemsOffset;
        section ++;
    }
    
    [self drawIndex];
    self.animate = NO;
}


- (UIColor *)darkerColor:(UIColor *)color by:(float)value {
    double h, s, b, a;
    if ([color getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:b * value
                               alpha:a];
    return nil;
}


#pragma mark -
- (void) drawIndex {
    for (NSCache *itemAttributes in self.itemsAtrributes) {
        
        UIFont *currentFont = [itemAttributes objectForKey:@"font"];
        NSMutableDictionary *attr = [NSMutableDictionary dictionary];
        attr[NSFontAttributeName] = currentFont;
        CATextLayer * singleItemTextLayer = [itemAttributes objectForKey:@"layer"];
        
        if ([self.itemsAtrributes count] != [self.layer.sublayers count] - 1) {
            [self.layer addSublayer:singleItemTextLayer];
        }
        
        if (singleItemTextLayer.fontSize != currentFont.pointSize) {
            [CATransaction begin];
            
            
            if (!self.animate) [CATransaction setAnimationDuration:0.005];
            else [CATransaction setAnimationDuration:0.2];
            
            CGPoint point = [[itemAttributes objectForKey:@"position"] CGPointValue];
            NSString *currentItem = [itemAttributes objectForKey:@"item"];
            CGSize textSize = [currentItem sizeWithAttributes:attr];
            UIColor *fontColor = [itemAttributes objectForKey:@"color"];
            
            singleItemTextLayer.zPosition = [[itemAttributes objectForKey:@"zPosition"] floatValue];
            singleItemTextLayer.font = (__bridge CFTypeRef)(currentFont.fontName);
            singleItemTextLayer.fontSize = currentFont.pointSize;
            singleItemTextLayer.opacity = [[itemAttributes objectForKey:@"alpha"] floatValue];
            singleItemTextLayer.string = currentItem;
            singleItemTextLayer.backgroundColor = [UIColor clearColor].CGColor;
            singleItemTextLayer.foregroundColor = fontColor.CGColor;
            singleItemTextLayer.bounds = CGRectMake(0.0,
                                                    0.0,
                                                    textSize.width,
                                                    textSize.height);
            singleItemTextLayer.position = CGPointMake(point.x + textSize.width/2.0,
                                                       point.y);
            singleItemTextLayer.contentsScale = [[UIScreen mainScreen]scale];
            
            [CATransaction commit];
            
        }
    }
}


#pragma mark - 触摸事件

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    int section = 0;
    
    for (NSCache *itemAttributes in self.itemsAtrributes) {
        CGPoint point = [[itemAttributes objectForKey:@"position"] CGPointValue];
        CGPoint location = [touch locationInView:self];
        if (location.y > point.y - self.itemsOffset / 2.0  &&
            location.y < point.y + self.itemsOffset / 2.0) {
            self.section = @(section);
        }
        section ++;
    }
    self.dot = NO;
    return YES;
}


- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGFloat currentY = [touch locationInView:self].y;
    CGFloat prevY = [touch previousLocationInView:self].y;
    
    [self showCurtain];
    
    if (fabs(currentY - prevY) > 3.0) {
        self.animate = NO;
    }
    [self positionForIndexItemsWhilePanLocation:[touch locationInView:self]];
    
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [self.dataSource sectionForSectionJJIndexTitle:self.indexItems[[self.section integerValue]] atIndex:[self.section integerValue]];
    
    if ([self.section integerValue] == 3 * self.times) {
        self.times ++;
        if (self.times == 5) {
            self.dot = YES;
            [self setNeedsDisplay];
        }
    } else self.times = 0;
    
    self.animate = YES;
    [self resetPosition];
    [self hideCurtain];
    
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
    self.animate = YES;
    [self resetPosition];
    [self hideCurtain];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if ((point.x > self.bounds.size.width - (self.indexSize.width + self.rightMargin + 10.0)) &&
        point.y > 0.0 && point.y < self.bounds.size.height) return YES;
    //if (point.y > self.bounds.size.height) return NO;
    return NO;
}


#pragma drawing curtain with CAGradientLayer or CALayer

- (void)addCurtain {
    if (self.curtainFade != 0.0) {
        if (self.curtainFade > 1) self.curtainFade = 1;
        if (!self.gradientLayer) {
            self.gradientLayer = [CAGradientLayer layer];
            [self.layer insertSublayer:self.gradientLayer atIndex:0];
        }
        
        const CGFloat * colorComponents = CGColorGetComponents(self.curtainColor.CGColor);
        self.gradientLayer.colors = @[(id)[[UIColor colorWithRed:colorComponents[0]
                                                           green:colorComponents[1]
                                                            blue:colorComponents[2]
                                                           alpha:0.0] CGColor],(id)[self.curtainColor CGColor]];
        
        self.curtainFadeFactor = (self.bounds.size.width - self.rightMargin - self.maxItemDeflection - 0.25 * self.maxWidth - 15.0) / self.bounds.size.width;
        self.gradientLayer.startPoint = CGPointMake(self.curtainFadeFactor - (self.curtainFade * self.curtainFadeFactor),
                                                    0.0);
        self.gradientLayer.endPoint = CGPointMake(MAX(self.curtainFadeFactor,0.02),
                                                  0.0);
        
        
    } else {
        
        if (!self.gradientLayer) {
            self.gradientLayer = (CAGradientLayer *)[CALayer layer];
            [self.layer insertSublayer:self.gradientLayer atIndex:0];
        }
        self.gradientLayer.backgroundColor = self.curtainColor.CGColor;
    }
    
    self.curtain = YES;
    [self hideCurtain];
}

- (void)hideCurtain {
    if (self.curtain && self.curtainColor) {
        CGRect curtainBoundsRect;
        CGFloat curtainVerticalCenter;
        CGFloat curtainHorizontalCenter;
        CGFloat multiplier = 2.0;
        
        if (!self.curtainMargins) {
            curtainBoundsRect = CGRectMake(0.0,
                                           0.0,
                                           self.indexSize.width * multiplier + self.rightMargin,
                                           self.bounds.size.height);
            curtainVerticalCenter = self.bounds.size.height / 2.0;
        }
        else {
            curtainBoundsRect = CGRectMake(0.0,
                                           0.0,
                                           self.indexSize.width * multiplier + self.rightMargin,
                                           self.bounds.size.height - (self.upperMargin + self.lowerMargin));
            curtainVerticalCenter = self.upperMargin + curtainBoundsRect.size.height / 2.0;
        }
        
        
        if (!self.curtainStays) {
            curtainHorizontalCenter = self.bounds.size.width + self.bounds.size.width / 2.0;
            
        } else {
            if (self.curtainMargins) curtainBoundsRect = CGRectMake(0.0,
                                                                    0.0,
                                                                    self.bounds.size.width,
                                                                    self.bounds.size.height - (self.upperMargin + self.lowerMargin));
            else curtainBoundsRect = self.bounds;
            
            
            CGFloat offset;
            if (self.itemsAligment == NSTextAlignmentRight) offset = self.bounds.size.width - (self.firstItemOrigin.x  - self.indexSize.width/2.0);
            else if (self.itemsAligment == NSTextAlignmentCenter) offset =  (self.bounds.size.width - self.firstItemOrigin.x);
            else offset = (self.bounds.size.width - (self.firstItemOrigin.x +  self.indexSize.width/2.0));
            
            curtainHorizontalCenter = (self.bounds.size.width + self.bounds.size.width / 2.0) -  2 * offset;
            
            if ([self.gradientLayer.class isSubclassOfClass:[CAGradientLayer class]]) {
                
                curtainHorizontalCenter = (self.bounds.size.width + self.bounds.size.width / 2.0) -  (2.0  * offset + self.curtainFade * offset);
                
                self.gradientLayer.startPoint = CGPointMake(0.001,
                                                            0.0);
                
                self.gradientLayer.endPoint = CGPointMake(MAX(self.curtainFade,
                                                              300.0 * self.gradientLayer.startPoint.x) * 00.1, 0.0);
            }
        }
        
        self.gradientLayer.bounds = curtainBoundsRect;
        self.gradientLayer.position = CGPointMake(curtainHorizontalCenter, curtainVerticalCenter);
        self.curtain = NO;
    }
}


- (void)showCurtain {
    if (!self.curtain && self.curtainColor && self.curtainMoves) {
        CGFloat curtainVerticalCenter;
        CGRect curtainBoundsRect;
        
        if (!self.curtainMargins) {
            curtainBoundsRect = self.bounds;
            curtainVerticalCenter = self.bounds.size.height / 2.0;
        } else {
            curtainBoundsRect = CGRectMake(0.0, self.upperMargin, self.bounds.size.width, self.bounds.size.height - (self.upperMargin + self.lowerMargin));
            curtainVerticalCenter = self.upperMargin + curtainBoundsRect.size.height / 2.0;
        }
        
        if ([self.gradientLayer.class isSubclassOfClass:[CAGradientLayer class]]) {
            [CATransaction begin];
            [CATransaction setAnimationDuration:0.075];
            
            self.gradientLayer.bounds = curtainBoundsRect;
            self.gradientLayer.startPoint = CGPointMake(MAX(self.curtainFadeFactor - (self.curtainFade * self.curtainFadeFactor),0.001), 0.0);
            self.gradientLayer.endPoint = CGPointMake(MAX(self.curtainFadeFactor,0.3), 0.0);
            self.gradientLayer.position = CGPointMake(self.bounds.size.width / 2.0, curtainVerticalCenter);
            [CATransaction commit];
        } else {
            [CATransaction begin];
            [CATransaction setAnimationDuration:0.075];
            
            self.gradientLayer.bounds = curtainBoundsRect;
            self.gradientLayer.position = CGPointMake((self.bounds.size.width - self.rightMargin - self.maxItemDeflection - 0.25 * self.maxWidth - 15.0) + self.bounds.size.width / 2.0, curtainVerticalCenter);
            [CATransaction commit];
        };
        
        self.curtain = YES;
    }
    
    
}

- (void)drawLabel:(NSString *)label withFont:(UIFont *)font forSize:(CGSize)size
          atPoint:(CGPoint)point withAlignment:(NSTextAlignment)alignment lineBreakMode:(NSLineBreakMode)lineBreak color:(UIColor *)color {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    
    
    NSMutableDictionary *attr = [NSMutableDictionary dictionary];
    attr[NSFontAttributeName] = font;
    //7.0以前的叼毛方法
//    CGSize newSize = [label sizeWithFont:font
//                       constrainedToSize:size
//                           lineBreakMode:lineBreak];
    CGSize newSize = [label boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil].size;
    CGRect rect = CGRectMake(point.x, point.y,
                             newSize.width, newSize.height);
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    
    //7.0以前的叼毛方法
//    [label drawInRect:rect
//             withFont:font
//        lineBreakMode:lineBreak
//            alignment:alignment];
    [label drawInRect:rect
             withAttributes:attr];
    CGContextRestoreGState(context);
}


- (void)drawTestRectangleAtPoint:(CGPoint)p withSize:(CGSize)size red:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetRGBFillColor(context, red, green, blue, alpha);
    CGContextBeginPath(context);
    CGRect rect = CGRectMake(p.x, p.y, size.width, size.height);
    CGContextAddRect(context, rect);
    CGContextFillPath(context);
    CGContextRestoreGState(context);
}

- (void)drawRect:(CGRect)rect
{
    if (self.dot) {
        [self drawTestRectangleAtPoint:CGPointMake(self.bounds.size.width / 2.0 - 100.0, self.bounds.size.height / 2.0 - 100.0)
                              withSize:CGSizeMake(200.0, 200.0)
                                   red:1.0
                                 green:1.0
                                  blue:1.0
                                 alpha:1.0];
        
        [self drawLabel:@"xxx"
               withFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:25.0]
                forSize:CGSizeMake(175.0, 150.0)
                atPoint:CGPointMake(self.bounds.size.width / 2.0 - 78.0, self.bounds.size.height / 2.0 - 80.0)
          withAlignment:NSTextAlignmentCenter
          lineBreakMode:NSLineBreakByWordWrapping
                  color:[UIColor colorWithRed:0.0 green:105.0/255.0 blue:240.0/255.0 alpha:1.0]];
    }
    
}


@end

