//
//  BFsFFmpegAssistant.m
//  Media
//
//  Created by Alex BF on 2019/4/3.
//  Copyright © 2019年 BFs. All rights reserved.
//

#import "BFsFFmpegAssistant.h"

#include <libavformat/avformat.h>
#include <libavcodec/avcodec.h>
#include <libswscale/swscale.h>

#define kVideoName @"VideoDemo.mp4"

@implementation BFsFFmpegAssistant

static BFsFFmpegAssistant *assistant;
static dispatch_once_t onceToken;

+  (instancetype)sharedInstance {
    
    dispatch_once(&onceToken, ^{
        assistant = [[BFsFFmpegAssistant alloc] init];
    });
    
    return assistant;
}

- (void)destoryInstance {
    
    if (onceToken > 0 || assistant) {
        onceToken = 0;
        assistant = nil;
    }
}

#pragma mark - 解封装

- (void)decodeVideo:(NSString *)fileName {
    
    av_register_all();
    avcodec_register_all();
    avformat_network_init();

    static AVFormatContext *fmt_ctx = NULL;
    if (avformat_open_input(&fmt_ctx, [fileName UTF8String], NULL, NULL) < 0) {
        //
        NSLog(@"1");
        return;
    }

    if (avformat_find_stream_info(fmt_ctx, NULL) < 0) {
        NSLog(@"2");
        av_dump_format(fmt_ctx, 0, [fileName UTF8String], 0);
        return;
    }

    // 流
    AVCodecContext *pCodecCtxOrig = NULL;
    AVCodecContext *pCodecCtx = NULL;
    int videoStream = -1;
    for (int i = 0; i < fmt_ctx->nb_streams; i++) {
        if (fmt_ctx->streams[i]->codec->codec_type == AVMEDIA_TYPE_VIDEO) {
            videoStream = i;
            break;
        }
    }
    if (videoStream == -1) {
        NSLog(@"3");
        return;
    }
    pCodecCtx = fmt_ctx->streams[videoStream]->codec;

    AVCodec *pCodec = NULL;
    pCodec = avcodec_find_decoder(pCodecCtx->codec_id);
    if (pCodec == NULL) {
        NSLog(@"4");
        return;
    }
    pCodecCtx = avcodec_alloc_context3(pCodec);
    if (avcodec_copy_context(pCodecCtx, pCodecCtxOrig) != 0) {
        NSLog(@"5");
        return;
    }

    if (avcodec_open2(pCodecCtx, pCodec, NULL) < 0) {
        NSLog(@"6");
        return;
    }

    // 帧
    AVFrame *pFrame = NULL;
    pFrame = av_frame_alloc();
}

@end
