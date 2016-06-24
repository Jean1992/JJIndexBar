//
//  ViewController.m
//  IndexBarDemo
//
//  Created by 四威 on 15/7/30.
//  Copyright (c) 2015年 LJJ. All rights reserved.
//

#import "ViewController.h"
#import "JJIndexBar.h"
@implementation UIView (Extension)
+ (instancetype)allocWithFrame:(CGRect)frame {
    return [[self alloc] initWithFrame:frame];
}
@end
@interface ViewController ()<UITableViewDataSource, UITableViewDelegate, JJIndexBarDataSource> {
    UITableView *tblView;
    JJIndexBar *indexBar;
}
@property (nonatomic, strong) NSArray *arrayData;
@property (nonatomic, strong) NSArray *arrayIndex;
@end

@implementation ViewController
- (NSArray *)arrayData {
    if (!_arrayData) {
        _arrayData = @[@"Auck",@"Buck",@"Cuck",@"Duck",@"Euck",
                       @"Fuck",@"Guck",@"Huck",@"Iuck",@"Juck",
                       @"Kuck",@"Luck",@"Muck",@"Nuck",@"Ouck",
                       @"Puck",@"Quck",@"Ruck",@"Suck",@"Tuck",
                       @"Uuck",@"Vuck",@"Wuck",@"Xuck",@"Yuck",
                       @"Zuck"];
    }
    return _arrayData;
}
- (NSArray *)arrayIndex {
    if (!_arrayIndex) {
        NSMutableArray *arrM = [NSMutableArray array];
        for (char c = 'A'; c <= 'Z'; c++) {
            [arrM addObject:[NSString stringWithFormat:@"%c", c]];
        }
        _arrayIndex = arrM;
    }
    return _arrayIndex;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    tblView = [[UITableView alloc] initWithFrame:self.view.bounds];
    tblView.backgroundColor = [UIColor whiteColor];
    tblView.delegate = self;
    tblView.dataSource = self;
    tblView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:tblView];
//傻瓜式,看不懂的撞墙去
    indexBar = [[JJIndexBar alloc] initWithFrame:self.view.bounds];
    indexBar.dataSource = self;
    indexBar.darkening = NO;
    indexBar.fading = NO;
    indexBar.rangeOfDeflection = 5;
    indexBar.curtainColor = [UIColor colorWithRed:0.2 green:0.3 blue:0.4 alpha:0.3];
    indexBar.curtainStays = YES;
    indexBar.curtainFade = 0.7;
    indexBar.selectedItemFontColor = [UIColor orangeColor];
    indexBar.fontColor = [UIColor blackColor];
    [self.view addSubview:indexBar];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayData.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reusingId = @"CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reusingId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusingId];
    }
    cell.textLabel.text = self.arrayData[indexPath.row];
    return cell;
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (NSArray *)sectionIndexTitlesForJJIndexBar:(JJIndexBar *)indexBar {
    return self.arrayIndex;
}
- (void)sectionForSectionJJIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    [tblView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition: UITableViewScrollPositionTop animated:NO];
}
@end
