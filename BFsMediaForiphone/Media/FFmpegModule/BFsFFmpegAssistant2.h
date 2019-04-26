//
//  BFsFFmpegAssistant2.h
//  Media
//
//  Created by 刘玲 on 2019/4/25.
//  Copyright © 2019年 BFs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BFsFFmpegAssistant2 : NSObject
@property (nonatomic, weak) UIImageView *videoView;

+ (instancetype)assistant;
- (void)decodeVideo:(NSString *)filePath;

@end

NS_ASSUME_NONNULL_END
