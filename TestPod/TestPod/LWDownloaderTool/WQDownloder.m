//
//  WQDownloder.m
//  下载器
//
//  Created by 刘文强 on 2018/3/30.
//  Copyright © 2018年 LWQ. All rights reserved.
//

#import "WQDownloder.h"

#define  kOutTime 20
//NSURLConnectionDownloadDataDelegate,拿不到数据，
@interface WQDownloder ()<NSURLConnectionDataDelegate>

//文件路径
@property (nonatomic, strong) NSString * filePath;
//网络文件大小
@property (nonatomic, assign) long long  expectedContentLength;
//本地文件大小
@property (nonatomic, assign) long long localenght;

//输出流 拼接数据
@property (nonatomic, strong) NSOutputStream  * outputStream;

@property (nonatomic, assign) CFRunLoopRef  downloadRunloop;


@property (nonatomic, copy) void(^completionBlock)(NSString *);
@property (nonatomic, copy) void(^errorMsgBlock)(NSString *);
@property (nonatomic, copy) void(^pregressBlock)(float);


@property (nonatomic, strong) NSURLConnection  * connetion;

@end

@implementation WQDownloder


//暂停
- (void)pause
{
    [self.connetion cancel];
}
////开始
//- (void)start
//{
//    [self.connetion start];
//}

// 外部接口内 不写 碎代码
- (void)downloderWithUrl:(NSURL *)Url progress:(void (^)(float))progress completion:(void (^)(NSString *))completion errorMsg:(void (^)(NSString *))errorMsg{
    
    self.completionBlock = completion;
    self.pregressBlock = progress;
    self.errorMsgBlock = errorMsg;
    
    //获取服务器的文件的大小，方便下一步的比较工作
    [self getServerDataLenghtWith:Url];
    
    //检查本地文件大小，是否需要下载该资源
    if (![self checkLocaFileInfor]) {
        //不需要下载
        NSLog(@"不需要下载");
        if (self.completionBlock) {
            self.completionBlock(self.filePath);
        }
    }else{
        NSLog(@"需要下载");
        [self downloaderFileWith:Url];
    }
}

//下载网络文件
- (void)downloaderFileWith:(NSURL *)url {
    //
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:1 timeoutInterval:kOutTime];
        NSString *rangestr = [NSString stringWithFormat:@"bytes=%lld-",self.localenght];
        [request setValue:rangestr forHTTPHeaderField:@"Range"];
        self.connetion = [NSURLConnection connectionWithRequest:request delegate:self];
        [self.connetion start];
        
        //开启runloop
        self.downloadRunloop = CFRunLoopGetCurrent();
        CFRunLoopRun();
    });
}

//判断 是否需要 下载文件
- (BOOL)checkLocaFileInfor {
    
    long long fileSize = 0;
    
    [[NSFileManager defaultManager ] fileExistsAtPath:self.filePath];
    NSDictionary *attributes =  [[NSFileManager defaultManager] attributesOfItemAtPath:self.filePath error:NULL];
//    NSLog(@"%@",attributes);
    fileSize = [attributes fileSize];
    
    //重新下载
    if (fileSize > self.expectedContentLength) {
        [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:NULL];
        fileSize = 0;
    }
    self.localenght = fileSize;
    //不需要下载
    if (fileSize == self.expectedContentLength) {
        return NO;
    }
    return YES;
}

//获取服务器上的文件上的大小
- (void)getServerDataLenghtWith:(NSURL *)url {
    
    NSURLResponse *response = nil;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:1 timeoutInterval:kOutTime];
    //只会获取头部信息。不会获取整个数据，
    request.HTTPMethod = @"HEAD";
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
    //保存路径／ 文件总大小
    self.expectedContentLength =  response.expectedContentLength;
    self.filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:response.suggestedFilename];
}

#pragma  mark ----NSURLConnectionDelegate
//接受到服务器的响应头
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.outputStream = [[NSOutputStream alloc] initToFileAtPath:self.filePath append:YES];
    [self.outputStream open];
}
//接受到数据
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.outputStream write:data.bytes maxLength:data.length];
    self.localenght += data.length;
    float progress = (float) self.localenght / self.expectedContentLength;
//    NSLog(@"progress:%lf",progress);
    if (self.pregressBlock) {
        self.pregressBlock(progress);
    }
}
//数据下载完成
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.outputStream close];
    CFRunLoopStop(self.downloadRunloop);
    
    //完成 回到主线程，方便外部使用
    if (self.completionBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{self.completionBlock(self.filePath);});
    }
}
//请求失败
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.outputStream close];
    CFRunLoopStop(self.downloadRunloop);
    
    if(self.errorMsgBlock){
        self.errorMsgBlock(error.localizedDescription);
    }
}

@end
