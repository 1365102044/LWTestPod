//
//  ViewController.m
//  TestPod
//
//  Created by 刘文强 on 2018/10/30.
//  Copyright © 2018年 LWQ. All rights reserved.
//

#import "ViewController.h"
#import "WQDownloadManager.h"
@interface ViewController ()
@property (nonatomic, strong) NSURL * url;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //    CFAbsoluteTime star =  CFAbsoluteTimeGetCurrent();
    
    //    NSString *str = @"http://127.0.0.1/004--NSFileHandle写入.wmv.pbb";
    NSString *str = @"http://sw.bos.baidu.com/sw-search-sp/software/4ea1aa9dfac30/QQ_mac_6.2.1.dmg";
    str = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    self.url = [NSURL URLWithString:str];
}
- (IBAction)start:(id)sender {
    
    [[WQDownloadManager shareDownloadManager] downloderWithUrl:self.url progress:^(float progress) {
        NSLog(@"--->progress:%f",progress);
    } completion:^(NSString *completion) {
        NSLog(@"--->completion:%@",completion);
    } errorMsg:^(NSString *errorMsg) {
        NSLog(@"--->errorMsg:%@",errorMsg);
    }];
}
- (IBAction)pause:(id)sender {
    [[WQDownloadManager shareDownloadManager] pauseWithURL:self.url];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //
    //    NSString *str = @"http://127.0.0.1/004--NSFileHandle写入.wmv.pbb";
    //    str = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //    NSURL *URL = [NSURL URLWithString:str];
    //
    //    [[WQDownloadManager shareDownloadManager] downloderWithUrl:URL progress:^(float progress) {
    //        NSLog(@"--->progress:%f",progress);
    //    } completion:^(NSString *completion) {
    //        NSLog(@"--->completion:%@",completion);
    //    } errorMsg:^(NSString *errorMsg) {
    //        NSLog(@"--->errorMsg:%@",errorMsg);
    //    }];
    
}
@end
