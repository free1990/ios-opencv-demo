//
//  ViewController.h
//  opencv_img
//
//  Created by Shahn Auronas on 11/13/14.
//  Copyright (c) 2014 Shahn Auronas. All rights reserved.
//
#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/types_c.h>
#import <opencv2/imgcodecs/ios.h>
#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
    cv::Mat cvImage;
}

@property (nonatomic, strong) IBOutlet UIImageView *imageView;

@end

