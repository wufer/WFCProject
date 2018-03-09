//
//  WFDraggableDemoVc.m
//  WFCProject
//
//  Created by wufer on 2018/3/9.
//  Copyright © 2018年 wufer. All rights reserved.
//

#import "WFDraggableDemoVc.h"
#import "UIView+WFDraggable.h"

@interface WFDraggableDemoVc ()

@property (nonatomic,strong)UIView *draggableView;

@end

@implementation WFDraggableDemoVc

- (void)viewDidLoad {
    [super viewDidLoad];
    self.draggableView = [[UIView alloc]initWithFrame:CGRectMake(100, 100, 200, 200)];
    self.draggableView.center = self.view.center;
    self.draggableView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:self.draggableView];
    [self.draggableView WF_makeDraggable];
    // Do any additional setup after loading the view.
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [self.draggableView WF_updateSnapPoint];
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
