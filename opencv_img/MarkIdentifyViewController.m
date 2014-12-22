//
//  MarkIdentify ViewController.m
//  OpenCVDemo
//
//  Created by John on 14/12/19.
//  Copyright (c) 2014年 WorkMac. All rights reserved.
//

#import "MarkIdentifyViewController.h"

@interface MarkIdentifyViewController ()

@end

@implementation MarkIdentifyViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(200, 0, 100, 100)];
    
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.imageView1];
    
    UIImage *mImage =  [UIImage imageNamed:@"testone.jpg"];
    IplImage *srcIpl = [self convertToIplImage:mImage];
    IplImage *dscIpl = cvCreateImage(cvGetSize(srcIpl), srcIpl->depth, 1);
    IplImage *dscIplNew = cvCreateImage(cvGetSize(srcIpl),  IPL_DEPTH_8U, 3);
    cvCvtColor(dscIpl, dscIplNew, CV_GRAY2BGR);
    
    UIImage *mImage1 =  [UIImage imageNamed:@"testtwo.jpg"];
    IplImage *srcIpl1 = [self convertToIplImage:mImage1];
    IplImage *dscIpl1 = cvCreateImage(cvGetSize(srcIpl1), srcIpl1 ->depth, 1);
    IplImage *dscIplNew1 = cvCreateImage(cvGetSize(srcIpl1), IPL_DEPTH_8U, 3);
    cvCvtColor(dscIpl1, dscIplNew1, CV_GRAY2BGR);
    
    UIImage *tempImage = [UIImage imageNamed:@"testone.jpg"];
    IplImage *iplTempImage = [self convertToIplImage:tempImage];
    
    BOOL tf = [self ComparePPKImage:srcIpl withAnotherImage:srcIpl1 withTempleImage:iplTempImage];
    if (tf) {
        printf("匹配成功");
    }else{
        printf("匹配失败");
    }
    
}

-(BOOL)ComparePPKImage:(IplImage*)mIplImage withAnotherImage:(IplImage*)mIplImage1 withTempleImage:(IplImage*)mTempleImage
{
    //第一次模板标记
    CvPoint minLoc =[self CompareTempleImage:mTempleImage withImage:mIplImage];
    if (minLoc.x==mIplImage->width || minLoc.y==mIplImage->height) {
        printf("第一个图片的模板标记失败");
               return false;
               }
               CvPoint minLoc1 =[self CompareTempleImage:mTempleImage withImage:mIplImage1];
               if (minLoc1.x==mIplImage1->width || minLoc1.y==mIplImage1->height) {
                   printf("第二个图片的模板标记失败");
                          return false;
                          }
                          //裁切图片
                          IplImage *cropImage,*cropImage1;
                          cropImage =[self cropIplImage:mIplImage withStartPoint:minLoc withWidth:mTempleImage->width withHeight:mTempleImage->height];
                          cropImage1=[self cropIplImage:mIplImage1 withStartPoint:minLoc1 withWidth:mTempleImage->width withHeight:mTempleImage->height];
                          self.imageView.image=[self convertToUIImage:cropImage];
                          self.imageView1.image=[self convertToUIImage:cropImage1];
                          double rst = [self CompareHist:cropImage withParam2:cropImage1];
                          if (rst<0.05) {
                              return true;
                          }
                          else{
                              return false;
                          }
}

-(CvPoint)CompareTempleImage:(IplImage*)templeIpl withImage:(IplImage*)mIplImage
{
    IplImage *src = mIplImage;
    IplImage *templat = templeIpl;
    IplImage *result;
    int srcW, srcH, templatW, templatH, resultH, resultW;
    srcW = src->width;
    srcH = src->height;
    templatW = templat->width;
    templatH = templat->height;
    resultW = srcW - templatW + 1;
    resultH = srcH - templatH + 1;
    result = cvCreateImage(cvSize(resultW, resultH), 32, 1);
    cvMatchTemplate(src, templat, result, CV_TM_SQDIFF);
    double minValue, maxValue;
    CvPoint minLoc, maxLoc;
    cvMinMaxLoc(result, &minValue, &maxValue, &maxLoc, &minLoc, &maxLoc);
    if (minLoc.y+templatH>srcH || minLoc.x+templatW>srcW) {
        printf("未找到标记图片");
        minLoc.x=srcW;
        minLoc.y=srcH;
    }
    return minLoc;
}


-(IplImage*)cropIplImage:(IplImage*)srcIpl withStartPoint:(CvPoint)mPoint withWidth:(int)width withHeight:(int)height
{
       //裁剪后的图片
       IplImage *cropImage;
       cvSetImageROI(srcIpl, cvRect(mPoint.x, mPoint.y, width, height));
       cropImage = cvCreateImage(cvGetSize(srcIpl), IPL_DEPTH_8U, 3);
       cvCopy(srcIpl, cropImage, Nil);
       cvResetImageROI(srcIpl);
       return cropImage;
}

// 多通道彩色图片的直方图比对
 -(double)CompareHist:(IplImage*)image1 withParam2:(IplImage*)image2
{
    
    int hist_size = 256;
    IplImage *gray_plane = cvCreateImage(cvGetSize(image1), 8, 1);
    cvCvtColor(image1, gray_plane, CV_BGR2GRAY);
    CvHistogram *gray_hist = cvCreateHist(1, &hist_size, CV_HIST_ARRAY, Nil,1);
    cvCalcHist(&gray_plane, gray_hist,0, Nil);

    IplImage *gray_plane2 = cvCreateImage(cvGetSize(image2), 8, 1);
    cvCvtColor(image2, gray_plane2, CV_BGR2GRAY);
    CvHistogram *gray_hist2 = cvCreateHist(1, &hist_size, CV_HIST_ARRAY, Nil, 1);
    cvCalcHist(&gray_plane2, gray_hist2, 0, Nil);
    double rst =cvCompareHist(gray_hist, gray_hist2, CV_COMP_BHATTACHARYYA);
    printf("对比结果=%f",rst);

    return rst;
}

// 单通道彩色图片的直方图
-(double)CompareHistSignle:(IplImage*)image1 withParam2:(IplImage*)image2
{

    int hist_size = 256;
    CvHistogram *gray_hist = cvCreateHist(1, &hist_size, CV_HIST_ARRAY, Nil, 1);
    cvCalcHist(&image1, gray_hist, 0, Nil);

    CvHistogram *gray_hist2 = cvCreateHist(1, &hist_size, CV_HIST_ARRAY, Nil, 1);
    cvCalcHist(&image2, gray_hist2, 0, Nil);

    return cvCompareHist(gray_hist, gray_hist2, CV_COMP_BHATTACHARYYA);
}

/// UIImage类型转换为IPlImage类型
-(IplImage*)convertToIplImage:(UIImage*)image
{
    CGImageRef imageRef = image.CGImage;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    IplImage *iplImage = cvCreateImage(cvSize(image.size.width, image.size.height), IPL_DEPTH_8U, 4);
    CGContextRef contextRef = CGBitmapContextCreate(iplImage->imageData, iplImage->width, iplImage->height, iplImage->depth, iplImage->widthStep, colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
    CGContextDrawImage(contextRef, CGRectMake(0, 0, image.size.width, image.size.height), imageRef);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    IplImage *ret = cvCreateImage(cvGetSize(iplImage), IPL_DEPTH_8U, 3);
    cvCvtColor(iplImage, ret, CV_RGB2BGR);
    cvReleaseImage(&iplImage);
    
    return ret;
}

/// IplImage类型转换为UIImage类型
-(UIImage*)convertToUIImage:(IplImage*)image
{
    cvCvtColor(image, image, CV_BGR2RGB);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSData *data = [NSData dataWithBytes:image->imageData length:image->imageSize];
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
    CGImageRef imageRef = CGImageCreate(image->width, image->height, image->depth, image->depth * image->nChannels, image->widthStep, colorSpace, kCGImageAlphaNone | kCGBitmapByteOrderDefault, provider, NULL, false, kCGRenderingIntentDefault);
    UIImage *ret = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    return ret;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.imageView = nil;
    self.imageView1=nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
