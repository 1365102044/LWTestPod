//
//  WQDownloder.h
//  下载器
//
//  Created by 刘文强 on 2018/3/30.
//  Copyright © 2018年 LWQ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WQDownloder : NSObject
//下载指定的URL 文件
- (void)downloderWithUrl:(NSURL *)Url progress:(void (^)(float progress))progress completion:(void (^)(NSString *completion))completion errorMsg:(void (^)(NSString *errorMsg))errorMsg;

//暂停
- (void)pause;
//开始
//- (void)start;
@end
