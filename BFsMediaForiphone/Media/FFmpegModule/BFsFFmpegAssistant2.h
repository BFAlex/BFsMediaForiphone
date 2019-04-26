//
//  BFsFFmpegAssistant2.h
//  Media
//
//  Created by 刘玲 on 2019/4/25.
//  Copyright © 2019年 BFs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BFsFFmpegAssistant2 : NSObject

+ (instancetype)assistant;
- (void)decodeVideo:(NSString *)filePath;

@end

NS_ASSUME_NONNULL_END
