//
//  ViewController.m
//  ScreenRecording
//
//  Created by GDBank on 2017/9/20.
//  Copyright © 2017年 com.GDBank.Company. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "PlayVideoViewController.h"

@interface ViewController ()
{
    NSMutableArray  *imageArr;
    NSTimer         * timer;
    BOOL            isVideo;
}
@property(nonatomic,strong)UITextField *textView;    ///MARK: 文本输入
@property(nonatomic,strong)UIButton *startButton;   ///MARK: 开始录制
@property(nonatomic,strong)UIButton *stopButton;    ///MARK: 停止录制
@property(nonatomic,strong)UIButton *nextButton;   ///MARK: 跳转界面
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    isVideo = YES;
    
    UITextField *textView = [[UITextField alloc]init];
    textView.frame = CGRectMake(50, 200, 300, 220);
    textView.font = [UIFont systemFontOfSize:12.0];
    textView.backgroundColor = [UIColor redColor];
    [self.view addSubview:textView];
    self.textView = textView;
    
    UIButton *startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    startButton.frame = CGRectMake(10, 100, 100, 50);
    [startButton setTitle:@"开始录制" forState:UIControlStateNormal];
    [startButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    startButton.layer.masksToBounds = YES;
    startButton.layer.cornerRadius = 5.0;
    startButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    startButton.layer.borderWidth = 1.0;
    [startButton addTarget:self action:@selector(dothings:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startButton];
    startButton.tag = 100;
    self.startButton = startButton;
    
    
    UIButton *stopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    stopButton.frame = CGRectMake(120, 100, 100, 50);
    [stopButton setTitle:@"停止录制" forState:UIControlStateNormal];
    [stopButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    stopButton.layer.masksToBounds = YES;
    stopButton.layer.cornerRadius = 5.0;
    stopButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    stopButton.layer.borderWidth = 1.0;
    stopButton.tag = 101;
    [stopButton addTarget:self action:@selector(dothings:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:stopButton];
    self.stopButton = stopButton;
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.frame = CGRectMake(240, 100, 100, 50);
    [nextButton setTitle:@"跳转播放界面" forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    nextButton.layer.masksToBounds = YES;
    nextButton.layer.cornerRadius = 5.0;
    nextButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    nextButton.layer.borderWidth = 1.0;
    nextButton.tag = 102;
    [nextButton addTarget:self action:@selector(dothings:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];
    self.nextButton = nextButton;
    
}


-(void)dealloc{
    NSLog(@"delloc");
}

-(void)dothings:(UIButton *)sender{
    switch (sender.tag -100) {
        case 0:
        {
            if ([imageArr count] == 0 && isVideo == YES) {
                imageArr = [[NSMutableArray alloc] initWithCapacity:0];
                
                NSInvocationOperation *operation = [[NSInvocationOperation alloc]initWithTarget:self                                                                           selector:@selector(addImageData) object:nil];
                NSOperationQueue *queue = [[NSOperationQueue alloc]init];
                [queue addOperation:operation];
                [NSThread sleepForTimeInterval:0.1];
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *moviePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",@"test"]];
                CGSize size = CGSizeMake(1024 ,768);
                NSError *error = nil;
                
                unlink([moviePath UTF8String]);
                AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:moviePath]
                                                                       fileType:AVFileTypeQuickTimeMovie
                                                                          error:&error];
                NSParameterAssert(videoWriter);
                if(error)
                    NSLog(@"error = %@", [error localizedDescription]);
                
                NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey,
                                               [NSNumber numberWithInt:size.width], AVVideoWidthKey,
                                               [NSNumber numberWithInt:size.height], AVVideoHeightKey, nil];
                AVAssetWriterInput *writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
                NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey, nil];
                AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                                 assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
                NSParameterAssert(writerInput);
                NSParameterAssert([videoWriter canAddInput:writerInput]);
                
                if ([videoWriter canAddInput:writerInput])
                    NSLog(@"写入");
                else
                    NSLog(@"写入");
                
                [videoWriter addInput:writerInput];
                
                [videoWriter startWriting];
                [videoWriter startSessionAtSourceTime:kCMTimeZero];
                
                dispatch_queue_t dispatchQueue = dispatch_queue_create("mediaInputQueue", NULL);
                int __block frame = 0;
                
                [writerInput requestMediaDataWhenReadyOnQueue:dispatchQueue usingBlock:^{
                    NSLog(@"wrierInput %i",[writerInput isReadyForMoreMediaData]);
                    while ([writerInput isReadyForMoreMediaData])
                    {
                        NSLog(@"imageArr %d,isVieo %i",[imageArr count],isVideo);
                        if([imageArr count] == 0&&isVideo == NO)
                        {
                            isVideo = YES;
                            [writerInput markAsFinished];
                            [videoWriter finishWritingWithCompletionHandler:^{}];
                            break;
                        }
                        if ([imageArr count] == 0&&isVideo == YES) {
                        }
                        else
                        {
                            CVPixelBufferRef buffer = NULL;
                            buffer = (CVPixelBufferRef)[self pixelBufferFromCGImage:[[imageArr objectAtIndex:0] CGImage] size:size];
                            if (++frame%10 == 0) {
                                [imageArr removeObjectAtIndex:0];
                            }
                            if (buffer)
                            {
                                if(![adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(frame, 120)])
                                    NSLog(@"错误");
                                else{
                                    CFRelease(buffer);
                                }
                            }
                        }
                        
                        
                    }
                }];
            }
        }
            break;
        case 1:
        {
            if ([timer isValid] == YES) {
                [timer invalidate];
                timer = nil;
                isVideo = NO;
                return;
            }
        }
            break;
            
        case 2:{
            PlayVideoViewController *play = [[PlayVideoViewController alloc]init];
            play.requstUrl = [self getRecordUrl];
            [self presentViewController:play animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}

-(void)addImageData{
    timer = [[NSTimer alloc] initWithFireDate:[NSDate new] interval:0.09 target:self selector:@selector(getImageDataTimer:) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] run];
}

-(void)getImageDataTimer:(NSTimer *)timer{
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image= UIGraphicsGetImageFromCurrentImageContext();
    [imageArr addObject:image];
    UIGraphicsEndImageContext();
}

- (CVPixelBufferRef )pixelBufferFromCGImage:(CGImageRef)image size:(CGSize)size{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey, nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, size.width, size.height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options, &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width, size.height, 8, 4*size.width, rgbColorSpace, kCGImageAlphaPremultipliedFirst);
    NSParameterAssert(context);
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

-(NSURLRequest *)getRecordUrl{        ///MARK:获取录制文件地址
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *moviePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",@"test"]];
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:[moviePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    return request;
}



@end
