//
//  WQDownloadManager.h
//  下载器
//
//  Created by 刘文强 on 2018/3/30.
//  Copyright © 2018年 LWQ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WQDownloadManager : NSObject

+ (instancetype)shareDownloadManager;

- (void)downloderWithUrl:(NSURL *)Url progress:(void (^)(float progress))progress completion:(void (^)(NSString *completion))completion errorMsg:(void (^)(NSString *errorMsg))errorMsg;

//暂停
- (void)pauseWithURL:(NSURL *)url;
@end
