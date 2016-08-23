//
//  LHChartView.m
//  SuperFastDoctor
//
//  Created by LouisHors on 16/8/5.
//  Copyright © 2016年 LouisHors. All rights reserved.
//

#import "LHChartView.h"

@interface LHChartView ()

///  上限
@property(nonatomic,assign) NSInteger number;

///  平均值
@property(nonatomic, assign) CGFloat averageNum;

@end

@implementation LHChartView

- (instancetype)initWithFrame:(CGRect)frame{

    if ( self == [super initWithFrame:frame]) {

    }

    return self;
}

- (void)setArray:(NSMutableArray *)array{

    _array = array;

    if (array.count > 0) {
        CGFloat sum = 0;
        NSInteger max = [array[0] integerValue];
        for (int i = 0; i < array.count; i++) {

            //  和
            sum += [array[i] doubleValue];

            //  最大值
            if ([array[i] integerValue] > max) {
                max = [array[i] integerValue];
            }
        }

        if (max % 1000 > 0) {
            //  说明不是整, 整除 + 1 再 * 1000
            max = (max / 1000 + 1) * 1000;
        }

        self.number = max;
        self.averageNum = sum / array.count;
    }

    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];

    //
    int todayHour = [self.count intValue];

    if (self.array.count == 0) {
        return;
    }else{

        int todayCount = -1;

        //  X轴为时间, 每点间距为30
        float pointX = (self.bounds.size.width - 30) / 7;

        //  阴影
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextMoveToPoint(context, 10, self.frame.size.height - 45);

        for (int i = 0; i < todayHour; i++) {
            int point = [self.array[i] intValue];

            CGContextAddLineToPoint(context, 10 + i * pointX + pointX, self.frame.size.height - (self.frame.size.height - 80) / self.number * point - 45);
        }

        //  和最后一个点画成一个不规则矩形
        CGContextAddLineToPoint(context, 10 + todayHour * pointX, self.frame.size.height - 45);

        //  填充颜色
        [[UIColor colorWithRed:1 green:1 blue:1 alpha:.5] setFill];
        CGContextFillPath(context);

        //  折线
        CGContextRef contextSec = UIGraphicsGetCurrentContext();
        [[UIColor whiteColor] setStroke];

        CGContextSetLineWidth(contextSec, 1.0);
        //  坐标0点
        CGContextMoveToPoint(contextSec, 10, self.frame.size.height - 45);

        for (int i = 0; i < todayHour; i++) {
            int otherPoint = [self.array[i] intValue];
            CGContextAddLineToPoint(contextSec, 10 + i * pointX + pointX, self.frame.size.height - (self.frame.size.height - 80) / self.number * otherPoint - 45);
        }

        CGContextStrokePath(contextSec);
        todayCount  = -1;

        //  每个顶点的空心圆点
        [[UIColor whiteColor] setFill];

        CGContextFillEllipseInRect(contextSec, CGRectMake(10, self.frame.size.height - 45, 5, 5));

        [[UIColor orangeColor] setFill];
        CGContextFillEllipseInRect(contextSec, CGRectMake(10.8, self.frame.size.height - 47.5, 3, 3));

        //  生成
        for (int i = 0; i < todayHour; i++) {

            int circlePoint = [self.array[i] intValue];

            [[UIColor whiteColor] setFill];
            CGContextFillEllipseInRect(contextSec, CGRectMake(10 + i * pointX + pointX - 2, self.frame.size.height - 45 - (self.frame.size.height - 80) / self.number * circlePoint - 3, 5, 5));

            CGContextFillEllipseInRect(contextSec, CGRectMake(9 + i * pointX + pointX, self.frame.size.height - 45 - (self.frame.size.height - 80) / self.number * circlePoint - 2, 3, 3));
        }
    }

    //  上下白线
    CGContextRef contextThird = UIGraphicsGetCurrentContext();

    CGContextMoveToPoint(contextThird, 5, 40);
    CGContextAddLineToPoint(contextThird, self.bounds.size.width - 5, 40);

    CGContextSetStrokeColorWithColor(contextThird, [UIColor whiteColor].CGColor);

    CGContextMoveToPoint(contextThird, 5, self.bounds.size.height - 40);
    CGContextAddLineToPoint(contextThird, self.bounds.size.width - 5, self.bounds.size.height - 40);

    CGContextStrokePath(contextThird);

    //  虚线长度
    CGFloat length[] = {5, 5};

    CGContextRef contextFourth = UIGraphicsGetCurrentContext();
    //  虚线
    CGContextSetLineDash(contextFourth, 0, length, 2);
    CGContextMoveToPoint(contextFourth, 5, self.bounds.size.height / 2);
    CGContextAddLineToPoint(contextFourth, self.bounds.size.width - 5, self.bounds.size.height / 2);
    CGContextStrokePath(contextFourth);

    //  文字
    float characterW = (self.bounds.size.width - 30) / 7;
    CGContextRef contextFifth = UIGraphicsGetCurrentContext();

    //  文字填充颜色
    CGContextSetRGBFillColor(contextFifth, 1, 1, 1, 1.0);
    UIFont *font12 = [UIFont boldSystemFontOfSize:12.0];
    UIFont *font20 = [UIFont boldSystemFontOfSize:20.0];
    UIFont *font10 = [UIFont boldSystemFontOfSize:10.0];

    NSString *pace = @"步数";
    [pace drawInRect:CGRectMake(5, 5, 40, 20) withAttributes:@{NSFontAttributeName: font20, NSForegroundColorAttributeName: [UIColor whiteColor]}];

    NSString *string2 = [NSString stringWithFormat:@"日平均值: %.0lf", self.averageNum];
    [string2 drawInRect:CGRectMake(5, 25, 100, 10) withAttributes:@{NSFontAttributeName: font10, NSForegroundColorAttributeName: [UIColor whiteColor]}];
    if (self.array.count == 0) {
        [string2 drawInRect:CGRectMake(self.bounds.size.width - 40, 5, 100, 20) withAttributes:@{NSFontAttributeName: font20, NSForegroundColorAttributeName: [UIColor whiteColor]}];
    }else{

        int title = 0;
        for (int i = 0; i < todayHour; i++) {
            title += [self.array[i] intValue];
        }

        NSString *string3 = [NSString stringWithFormat:@"%d步", title];

        int dd = 0;
        if (string3.length > 3) {
            dd = 100;
        }else if (string3.length > 4){

            dd = 120;
        }else{

            dd = 100;
        }

        [string3 drawInRect:CGRectMake(self.bounds.size.width - 80, 5, dd, 20) withAttributes:@{NSFontAttributeName: font20, NSForegroundColorAttributeName: [UIColor whiteColor]}];

        NSString *string4 = @"最近七日总数据";
        [string4 drawInRect:CGRectMake(self.bounds.size.width - 80, 25, 100, 10) withAttributes:@{NSFontAttributeName: font10, NSForegroundColorAttributeName: [UIColor whiteColor]}];

        for (int i = 0; i < [self.count intValue] + 1; i++) {
            NSString *str = [NSString stringWithFormat:@"%d", i];
            [str drawInRect:CGRectMake(characterW * i + 10, self.bounds.size.height - 30, 20, 20) withAttributes:@{NSFontAttributeName: font12, NSForegroundColorAttributeName: [UIColor whiteColor]}];
        }

        NSString *maxNum = [NSString stringWithFormat:@"%zd步", self.number];
        [maxNum drawInRect:CGRectMake(self.bounds.size.width - 30, 45, 100, 20) withAttributes:@{NSFontAttributeName: font12, NSForegroundColorAttributeName: [UIColor whiteColor]}];
        
    }
}

@end
