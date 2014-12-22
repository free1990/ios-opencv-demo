//
//  MarkIdentify ViewController.h
//  OpenCVDemo
//
//  Created by John on 14/12/19.
//  Copyright (c) 2014年 WorkMac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+OpenCV.h"

#import <opencv2/highgui/ios.h>
#import <opencv2/imgproc/imgproc_c.h>
#import <opencv2/core/core_c.h>
#import <opencv2/features2d/features2d.hpp>
#import <opencv2/nonfree/features2d.hpp>

@interface MarkIdentifyViewController : UIViewController


@property (nonatomic, strong) UIImageView *imageView1;
@property (nonatomic, strong) UIImageView *imageView;

- (void)processFrame;

@end
