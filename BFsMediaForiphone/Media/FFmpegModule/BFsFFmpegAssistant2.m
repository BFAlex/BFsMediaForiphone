//
//  BFsFFmpegAssistant2.m
//  Media
//
//  Created by 刘玲 on 2019/4/25.
//  Copyright © 2019年 BFs. All rights reserved.
//

#import "BFsFFmpegAssistant2.h"

#include <libavformat/avformat.h>
#include <libavcodec/avcodec.h>
#include <libswscale/swscale.h>

@implementation BFsFFmpegAssistant2

#pragma mark - API

+ (instancetype)assistant {
    
    BFsFFmpegAssistant2 *assistant = [[BFsFFmpegAssistant2 alloc] init];
    
    return assistant;
}

- (void)decodeVideo:(NSString *)filePath {
    //
    if (filePath.length < 1) {
        NSLog(@"文件路径无效: %@", filePath);
        goto decodeEnd;
    }
    //
    av_register_all();
    // 打开视频文件(读取文件头)
    AVFormatContext *formatCtx = NULL;
    if (avformat_open_input(&formatCtx, [filePath UTF8String], NULL, NULL) != 0) {
        NSLog(@"打开视频文件异常");
        goto decodeEnd;
    }
    // 检索流信息(信息填充formatCtx-> streams)
    if (avformat_find_stream_info(formatCtx, NULL) < 0) {
        NSLog(@"检索流信息异常");
        goto decodeEnd;
    }
    [self showStreamInfo:formatCtx];
    //
    [self handleVideoStream:formatCtx];
    
decodeEnd:
    return;
}

- (void)showStreamInfo:(AVFormatContext *)pFormatCtx {
    
    for (int i = 0; i < pFormatCtx->nb_streams; i++) {
        AVStream *stream = pFormatCtx->streams[i];
        NSLog(@"stream[%d]: %d", i, stream->codec->codec_type);
    }
}

- (void)handleVideoStream:(AVFormatContext *)pFormatCtx {
    //
    int videoStrIndex = [self queryVideoStreamIndex:pFormatCtx];
    if (videoStrIndex < 0) {
        NSLog(@"找不到视频流");
        return;
    }
    // 编解码器上下文(包含流的信息)
    AVStream *videoStream = pFormatCtx->streams[videoStrIndex];
    AVCodecContext *vCodecCtx = videoStream->codec;
    AVCodec *vCodec = avcodec_find_decoder(vCodecCtx->codec_id);
    if (vCodec == NULL) {
        NSLog(@"找不到支持的编解码器");
        return;
    }
    //
    AVCodecContext *codecCxt = avcodec_alloc_context3(vCodec);
    if (avcodec_copy_context(codecCxt, vCodecCtx) != 0) {
        NSLog(@"复制编解码器上下文异常");
        return;
    }
    //
    if (avcodec_open2(codecCxt, vCodec, NULL) < 0) {
        NSLog(@"打开编解码器异常");
        return;
    }
}

- (int)queryVideoStreamIndex:(AVFormatContext *)pFormatCtx {
    
    for (int i = 0; i < pFormatCtx->nb_streams; i++) {
        AVStream *curStream = pFormatCtx->streams[i];
        if (curStream->codec->codec_type == AVMEDIA_TYPE_VIDEO) {
            return i;
        }
    }
    
    return -1;
}

@end
