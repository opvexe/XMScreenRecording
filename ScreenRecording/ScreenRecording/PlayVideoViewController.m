//
//  PlayVideoViewController.m
//  ScreenRecording
//
//  Created by GDBank on 2017/9/20.
//  Copyright © 2017年 com.GDBank.Company. All rights reserved.
//

#import "PlayVideoViewController.h"

@interface PlayVideoViewController ()

@end

@implementation PlayVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIWebView *playWeb = [[UIWebView alloc] initWithFrame:CGRectMake(0, 50, 768, 900)];
    [playWeb setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:playWeb];
    
      [playWeb loadRequest:self.requstUrl];
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
