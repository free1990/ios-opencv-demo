//
//  UIImage+OpenCV.h
//  OpenCVDemo
//
//  Created by John on 14/12/19.
//  Copyright (c) 2014年 WorkMac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/types_c.h>
#import <opencv2/imgcodecs/ios.h>

@interface UIImage (OpenCV)

+(UIImage *)imageWithCVMat:(const cv::Mat&)cvMat;
-(id)initWithCVMat:(const cv::Mat&)cvMat;

@property(nonatomic, readonly) cv::Mat CVMat;
@property(nonatomic, readonly) cv::Mat CVGrayscaleMat;

@end
