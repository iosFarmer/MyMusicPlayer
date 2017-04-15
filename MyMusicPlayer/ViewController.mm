//
//  ViewController.m
//  MyMusicPlayer
//
//  Created by panyanb on 2017/3/25.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "ViewController.h"
#import "MyMusicViewController.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSString *filepath;
@property (nonatomic, strong) MyMusicViewController *musicController;
@end

@implementation ViewController
{
    BOOL m_isVideo;
    NSString *m_musicTitle;
}
-(NSArray *)items
{
    if (!_items) {
        _items = [NSArray array];
    }
    return _items;
}

-(void)addTableView
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:tableView];
    _items = @[@"本地音乐",@"在线音乐",@"本地视频",@"在线视频"];
    
}


#pragma mark UITableViewDelegate,UITableViewDataSource method

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_items.count> 0) {
        return _items.count;
    }
    return 4;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"MyMusicPlayer";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    UILabel *label = [[UILabel alloc] init];
    label.text = [_items objectAtIndex:indexPath.row];
    label.textColor = [UIColor redColor];
    label.font = [UIFont systemFontOfSize:15];
    label.frame = CGRectMake(10, 2, 80, 40);
    [cell.contentView addSubview:label];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        self.filepath = [[NSBundle mainBundle] pathForResource:@"ysbg.mp3" ofType:nil];
        m_isVideo = NO;
        m_musicTitle = @"一丝不挂";
    }
    else if (indexPath.row == 1){
        self.filepath = @"http://html.gz.eecn.cn/base-gzsng/res/music/mp3/zuanji/2006_2007zhuanji/hy_nan/hy_nan_00026/hy_nan_00026_00004.mp3";
        m_isVideo = NO;
        m_musicTitle = @"红玫瑰";
    }
    else if (indexPath.row == 2){
        self.filepath = [[NSBundle mainBundle] pathForResource:@"hmg.mp4" ofType:nil];
        m_isVideo = YES;
        
    }
    else if (indexPath.row == 3){
        self.filepath = @"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4";
        m_isVideo = YES;
        
    }
    if (!_musicController) {
        _musicController = [[MyMusicViewController alloc] init];
    }
    _musicController.title = [_items objectAtIndex:indexPath.row];
    _musicController.musicTitle = m_musicTitle;
    [_musicController addMusicPlayerViewWithVideo:m_isVideo];
    [_musicController musicFilepath:self.filepath isVideo:m_isVideo];
    [self.navigationController pushViewController:_musicController animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"音频视频播放器";
    
    [self addTableView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}


@end
