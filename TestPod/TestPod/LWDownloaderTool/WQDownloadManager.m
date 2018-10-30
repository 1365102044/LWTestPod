//
//  WQDownloadManager.m
//  下载器
//
//  Created by 刘文强 on 2018/3/30.
//  Copyright © 2018年 LWQ. All rights reserved.
//

#import "WQDownloadManager.h"
#import "WQDownloder.h"

@interface WQDownloadManager ()

//下载缓存池 防止多次调用相同URL
@property (nonatomic, strong) NSMutableDictionary * downloadCach;

@property (nonatomic, copy) void(^faildBlock)(NSString *);

@end

@implementation WQDownloadManager

+ (instancetype)shareDownloadManager
{
    static WQDownloadManager * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WQDownloadManager alloc] init];
    });
    return instance;
}

- (void)downloderWithUrl:(NSURL *)Url progress:(void (^)(float))progress completion:(void (^)(NSString *))completion errorMsg:(void (^)(NSString *))errorMsg
{
    self.faildBlock =  errorMsg;
    
    WQDownloder *downloader = [self.downloadCach objectForKey:[Url path]];
    if (downloader != nil) {
        NSLog(@"正在下载！！");
        return;
    }
    downloader = [[WQDownloder alloc] init];
    //临时改变参数名，如果外部不一样就没必要改变（这里是重名了，不改报错）
    [downloader downloderWithUrl:Url progress:progress completion:^(NSString *filedstr) {
        [self.downloadCach removeObjectForKey:Url.path];
        if (completion) {
            completion(filedstr);
        }
    } errorMsg:^(NSString *error) {
        [self.downloadCach removeObjectForKey:Url.path];
        if (errorMsg) {
            errorMsg(error);
        }
    }];
    [self.downloadCach setObject:downloader forKey:Url.path];
}

//暂停正在下载！！
- (void)pauseWithURL:(NSURL *)url
{
    WQDownloder *download = [self.downloadCach objectForKey:url.path];
    if (download == nil) {
        if (self.faildBlock) {
            self.faildBlock(@"该操作不存在！！");
        }
        return;
    }
    [download pause];
    [self.downloadCach removeObjectForKey:url.path];
}

- (NSMutableDictionary *)downloadCach
{
    if (!_downloadCach) {
        _downloadCach  = [[NSMutableDictionary alloc] init];
    }
    return _downloadCach;
}
@end
