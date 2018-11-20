//
//  ViewController.m
//  ChXDragChangeHeightDemo
//
//  Created by Xu Chen on 2018/11/20.
//  Copyright © 2018 xu.yzl. All rights reserved.
//

#import "ViewController.h"
#import "ChXTopScrollView.h"
#import "ChXBottomScrollView.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
// 拖拽按钮的高度
#define kDragButtonHeight 19.0

@interface ViewController ()
@property (nonatomic, strong) ChXTopScrollView *topScroll;
@property (nonatomic, strong) ChXBottomScrollView *bottomScroll;
@property (nonatomic, strong) UIButton *dragButton;

@property (nonatomic, assign) CGFloat originalY;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];

    [self setupUI];
}

- (void)setupUI {
    // 1. topScroll
    self.topScroll.frame = CGRectMake(0, UIApplication.sharedApplication.statusBarFrame.size.height +44, kScreenWidth, 200);

    UILabel *_label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    NSString *txt = @"    ①自那以后，我亲眼看见一个州接一个州地消灭了它们所有的狼。我看见过许多刚刚失去了狼的山的样子，看见南面的山坡由于新出现的弯弯曲曲的鹿径而变得皱皱巴巴。我看见所有可吃的灌木和树苗都被吃掉，先是衰弱不振，然后死去。这样一座山看起来就好像什么人给了上帝一把大剪刀，叫他成天只修剪树干，不做其他事情。结果，那原来渴望着食物的鹿群的饿殍，和死去的艾蒿丛一起变成了白色，或者就在高于鹿头的部分还留有叶子的刺柏下腐烂掉。——这些鹿是因其数目太多而死去的。\n    ②我现在想，正像当初鹿群在对狼的极度恐惧中生活着那样，那一座山将要在对它的鹿的极度恐惧中生活。而且，大概就比较充分的理由来说，当一只被狼拖去的公鹿在两年或三年就可得到补替时，一片被太多的鹿拖疲惫了的草原，可能在几十年里都得不到复原。\n    ③牛群也是如此，清除了其牧场上的狼的牧牛人并未意识到，他取代了狼用以调整牛群数目以适应其牧场的工作。他不知道像山那样来思考。正因为如此，我们才有了尘暴，河水把未来冲刷到大海去。\n    ④我们大家都在为安全、繁荣、舒适、长寿和平静而奋斗着。鹿用轻快的四肢奋斗着，牧牛人用套圈和毒药奋斗着，政治家用笔，而我们大家则用机器、选票和美金。所有这一切带来的都是同一种东西：我们这一时代的和平。用这一点去衡量成就，全部是很好的，而且大概也是客观的思考所不可缺少的，不过，太多的安全似乎产生了____的危险。这个世界的启示在荒野。——这也是狼的嗥叫中____的内涵，它已被群山所理解，却还极少为人类所____。（节选自《像山那样思考》）";
    _label.text = txt;
    _label.numberOfLines = 0;
    _label.backgroundColor = UIColor.clearColor;
    [self.topScroll addSubview:_label];
    
    CGSize maxSize = CGSizeMake(kScreenWidth, MAXFLOAT);
    CGFloat textHeight = [_label.text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17]} context:nil].size.height;
    NSLog(@"源高度：textHeight: %f", textHeight);
    self.topScroll.contentSize = CGSizeMake(0, textHeight + 40);
    
    
    // 2. dragbutton, 这里y值向上偏移了 kDragButtonHeight 的距离，是为了不遮挡 topScroll 的文字
    self.dragButton.frame = CGRectMake(0, CGRectGetMaxY(self.topScroll.frame) - kDragButtonHeight, kScreenWidth, kDragButtonHeight);
    
    // 3. bottomScroll
    self.bottomScroll.frame = CGRectMake(0, CGRectGetMaxY(self.dragButton.frame), kScreenWidth, kScreenHeight - CGRectGetMaxY(self.dragButton.frame));
    self.bottomScroll.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
    self.bottomScroll.layer.shadowColor = [UIColor colorWithRed:129/255.0 green:136/255.0 blue:161/255.0 alpha:0.18].CGColor;
    self.bottomScroll.layer.shadowOffset = CGSizeMake(0,-3);
    self.bottomScroll.layer.shadowOpacity = 1;
    self.bottomScroll.layer.shadowRadius = 8;
    
    UILabel *nextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, textHeight + 20)];
    nextLabel.text = txt;
    nextLabel.numberOfLines = 0;
    nextLabel.backgroundColor = UIColor.greenColor;
    [self.bottomScroll addSubview:nextLabel];
    self.bottomScroll.contentSize = CGSizeMake(0, textHeight + 40);

    
    [self.view addSubview:self.topScroll];
    [self.view addSubview:self.dragButton];
    [self.view addSubview:self.bottomScroll];
    
    // 添加拖拽手势
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self.dragButton addGestureRecognizer:panGesture];
    // 设置响应交互行为，默认为 NO
    self.dragButton.userInteractionEnabled = YES;
}


- (void)panAction:(UIPanGestureRecognizer *)pan {
    /*
     使用此段代码，可直接实现拖拽 view 的功能
     
     UIView *dragView = pan.view;
     CGPoint translation = [pan translationInView:dragView.superview];
     // dragView.center = CGPointMake(dragView.center.x + transPoint.x, dragView.center.y + transPoint.y);
     dragView.transform = CGAffineTransformTranslate(dragView.transform, transPoint.x, transPoint.y);
     // 每次移动完，将移动量置为0，否则下次移动会加上这次移动量
     [pan setTranslation:CGPointZero inView:dragView.superview];
     
     */
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            self.originalY = self.dragButton.frame.origin.y;
            break;
        case UIGestureRecognizerStateChanged: {
            // 横、纵坐标上拖动了多少像素（即偏移量）
            CGPoint transPoint = [pan translationInView:self.view];
            NSLog(@"拖拽 y 值：%f",transPoint.y);
            
            // 转换为相对于父视图的坐标
            CGFloat newPoint_y = transPoint.y + self.originalY;
            
            // 距离父视图底部最小间距
            if (newPoint_y > self.dragButton.superview.frame.size.height - 88) {
                newPoint_y = self.dragButton.superview.frame.size.height - 88;
            }
            // 距离 topScroll 顶部最小间距
            if (newPoint_y < self.topScroll.frame.origin.y + 50) {
                newPoint_y = self.topScroll.frame.origin.y + 50;
            }
        
            // 1. dragButton 新坐标
            CGRect dragViewFrame_new = self.dragButton.frame;
            dragViewFrame_new.origin.y = newPoint_y;
            self.dragButton.frame = dragViewFrame_new;
            
            // 2. topScroll 新坐标
            CGRect topScrollFrame_new = self.topScroll.frame;
            topScrollFrame_new.size.height = self.dragButton.frame.origin.y - topScrollFrame_new.origin.y + kDragButtonHeight;
            self.topScroll.frame = topScrollFrame_new;
        
            // 3. bottomScroll 新坐标
            CGRect bottomScrollFrame_new = self.bottomScroll.frame;
            // 相对偏移位置
            CGFloat bottomOffset_y = CGRectGetMaxY(self.dragButton.frame) - bottomScrollFrame_new.origin.y;
            
            bottomScrollFrame_new.origin.y = CGRectGetMaxY(self.dragButton.frame);
            
            // 这里可以不改变
            bottomScrollFrame_new.size.height -= bottomOffset_y;
            
            self.bottomScroll.frame = bottomScrollFrame_new;
            
        }
            break;
        case UIGestureRecognizerStateEnded:
            break;
        default:
            break;
    }
    
}


- (ChXTopScrollView *)topScroll {
    if (!_topScroll) {
        _topScroll = [[ChXTopScrollView alloc] init];
        _topScroll.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
    }
    return _topScroll;
}

- (UIButton *)dragButton {
    if (!_dragButton) {
        _dragButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_dragButton setImage:[UIImage imageNamed:@"dragImage"] forState:UIControlStateNormal];
        [_dragButton setImage:[UIImage imageNamed:@"dragImage"] forState:UIControlStateHighlighted];
        _dragButton.backgroundColor = UIColor.clearColor;
    }
    return _dragButton;
}

- (ChXBottomScrollView *)bottomScroll {
    if (!_bottomScroll) {
        _bottomScroll = [[ChXBottomScrollView alloc] init];
        _bottomScroll.backgroundColor = UIColor.blueColor;
    }
    return _bottomScroll;
}






@end
