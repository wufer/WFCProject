//
//  ViewController.m
//  WFCProject
//
//  Created by wufer on 2018/3/6.
//  Copyright © 2018年 wufer. All rights reserved.
//

#import "ViewController.h"
#import "UIView+WFDraggable.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *dragView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
    dragView.center = self.view.center;
    [dragView WF_makeDraggable];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
