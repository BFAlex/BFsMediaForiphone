//
//  BFsFFmpegAssistant.h
//  Media
//
//  Created by Alex BF on 2019/4/3.
//  Copyright © 2019年 BFs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BFsFFmpegAssistant : NSObject

+ (instancetype)sharedInstance;
- (void)destoryInstance;
//
- (void)decodeVideo:(NSString *)fileName;

@end
