//
//  WFDemoListVc.m
//  WFCProject
//
//  Created by wufer on 2018/3/9.
//  Copyright © 2018年 wufer. All rights reserved.
//

#import "WFDemoListVc.h"
#import "WFDraggableDemoVc.h"
#import "WFBMK_TrailVc.h"

@interface WFDemoListVc ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableV;

@property (nonatomic,strong) NSMutableArray<NSString *> *datascorceArr;

@end

@implementation WFDemoListVc

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"List";
    [self.datascorceArr addObject:@"WFDraggableDemoVc"];
    [self.datascorceArr addObject:@"WFBMK_TrailVc"];
    [self.view addSubview:self.tableV];
}

#pragma mark lazyLoard
-(UITableView *)tableV{
    if (!_tableV) {
        _tableV = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        _tableV.delegate = self;
        _tableV.dataSource = self;
    }
    return _tableV;
}

-(NSMutableArray *)datascorceArr{
    if (!_datascorceArr) {
        _datascorceArr = [[NSMutableArray alloc]init];
    }
    return _datascorceArr;
}

#pragma mark tableDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
 WF_BaseViewController *vc = [[NSClassFromString(self.datascorceArr[indexPath.row]) alloc] init];
    vc.title = [NSString stringWithFormat:@"【%ld】%@",indexPath.row,self.datascorceArr[indexPath.row]];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark tableDatasource
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0f;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.datascorceArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"【%ld】%@",indexPath.row,self.datascorceArr[indexPath.row]];
    return cell;
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
