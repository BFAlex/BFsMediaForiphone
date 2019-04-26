//
//  BFsFFmpegAssistant2.m
//  Media
//
//  Created by 刘玲 on 2019/4/25.
//  Copyright © 2019年 BFs. All rights reserved.
//

#import "BFsFFmpegAssistant2.h"
#import <CoreImage/CoreImage.h>

#include <libavformat/avformat.h>
#include <libavcodec/avcodec.h>
#include <libswscale/swscale.h>

@interface BFsFFmpegAssistant2 () {
    AVFormatContext     *_formatCtx;
    AVCodecContext      *_codecCxt;
}

@end

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
    _formatCtx = formatCtx;
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
    _codecCxt = codecCxt;
    
    //
    [self readingVideoStreamData:pFormatCtx codecContext:codecCxt andStreamIndex:videoStrIndex];
}

- (void)readingVideoStreamData:(AVFormatContext *)pFormatCtx
                  codecContext:(AVCodecContext *)pCodecCtx
                andStreamIndex:(int)pStreamIndex {
    
    struct SwsContext *swsCtx = sws_getContext(pCodecCtx->width,
                                               pCodecCtx->height,
                                               pCodecCtx->pix_fmt,
                                               pCodecCtx->width,
                                               pCodecCtx->height,
                                               AV_PIX_FMT_RGB24,
                                               SWS_BILINEAR,
                                               NULL,
                                               NULL,
                                               NULL);
    
    AVPacket packet;
    AVFrame *frame = NULL;
    int finish;
    while (av_read_frame(pFormatCtx, &packet)) {
        //
        if (packet.stream_index == pStreamIndex) {
            // 解码视频帧
            avcodec_decode_video2(pCodecCtx, frame, &finish, &packet);
            if (finish) {
                // 成功读取一个帧数据
                if (self.videoView) {
                    self.videoView.image = [self dataOfImageForRBG:frame codecContext:pCodecCtx andSwsContext:swsCtx];
                }
            }
        }
    }
}

- (UIImage *)dataOfImageForRBG:(AVFrame *)pFrame
                  codecContext:(AVCodecContext *)pCodecCtx
                 andSwsContext:(struct SwsContext *)pSwsCtx {
    
    AVFrame *frameRGB = av_frame_alloc();
    if (frameRGB == nil) {
        NSLog(@"创建RGB帧异常");
        return nil;
    }
    uint8_t *buffer = NULL;
    int numBytes;
    numBytes = avpicture_get_size(AV_PIX_FMT_RGB24,
                                  pCodecCtx->width,
                                  pCodecCtx->height);
    buffer = (uint8_t *)av_malloc(numBytes * sizeof(uint8_t));
    avpicture_fill((AVPicture *)frameRGB,
                   buffer,
                   AV_PIX_FMT_RGB24,
                   pCodecCtx->width,
                   pCodecCtx->height);
    
    sws_scale(pSwsCtx,
              (uint8_t const * const *)pFrame->data,
              pFrame->linesize,
              0,
              pCodecCtx->height,
              frameRGB->data,
              frameRGB->linesize);
    
    CGFloat width = 200;
    CGFloat height = 160;
    CGBitmapInfo bitmapInfo =kCGBitmapByteOrderDefault;
    CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault,
                                                 frameRGB->data[0],
                                                 frameRGB->linesize[0]*height,
                                                 kCFAllocatorNull);
    
    CGDataProviderRef provider =CGDataProviderCreateWithCFData(data);
    CGColorSpaceRef colorSpace =CGColorSpaceCreateDeviceRGB();
    CGImageRef cgImage = CGImageCreate(width,
                                           height,
                                           8,
                                           24,
                                           frameRGB->linesize[0],
                                           colorSpace,
                                           bitmapInfo,
                                           provider,NULL,NO,kCGRenderingIntentDefault);
    CGColorSpaceRelease(colorSpace);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    
    return image;
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
