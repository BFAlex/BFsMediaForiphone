//
//  ViewController.m
//  Media
//
//  Created by Alex BF on 2019/4/3.
//  Copyright © 2019年 BFs. All rights reserved.
//

#import "ViewController.h"
#import "BFsFFmpegAssistant2.h"

@interface ViewController ()
@property (nonatomic, weak) UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CGRect imgFrame = CGRectMake(0, 0, 200, 160);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:imgFrame];
    imageView.center = self.view.center;
    [self.view addSubview:imageView];
}

- (void)viewDidAppear:(BOOL)animated {
    [self testFFmpeg];
}

#pragma mark - Func

- (void)testFFmpeg {
    
    BFsFFmpegAssistant2 *assistant = [BFsFFmpegAssistant2 assistant];
    assistant.videoView = self.imageView;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"VideoDemo.mp4" ofType:nil];
    [assistant decodeVideo:filePath];
}

@end
