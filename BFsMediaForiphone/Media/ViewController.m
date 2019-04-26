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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [self testFFmpeg];
}

#pragma mark - Func

- (void)testFFmpeg {
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"VideoDemo.mp4" ofType:nil];
    [[BFsFFmpegAssistant2 assistant] decodeVideo:filePath];
}

@end
