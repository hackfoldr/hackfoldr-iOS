//
//  QRCodeViewController.m
//  hackfoldr-iOS
//
//  Created by Superbil on 2017/11/22.
//  Copyright © 2017年 org.g0v. All rights reserved.
//

#import "QRCodeViewController.h"

@interface QRCodeViewController ()
@property IBOutlet NSLayoutConstraint *widthOfCenterViewConstraint;
@property IBOutlet UIView *centerView;
@property IBOutlet UIImageView *qrCodeImageView;
@property IBOutlet UIView *cameraView;
@end

@implementation QRCodeViewController

+ (instancetype)viewController {
    return [[UIStoryboard storyboardWithName:@"QRCode" bundle:nil] instantiateViewControllerWithIdentifier:@"QRCodeViewController"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.title = self.qrCodeString ? @"Show QR Code" : @"Scan QR Code";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.qrCodeString) {
        CGSize size = self.qrCodeImageView.frame.size;
        CIImage *ciImage = [self outputNormalImageWithString:self.qrCodeString imageSize:size];
        self.qrCodeImageView.image = [self createNonInterpolatedUIImageFormCIImage:ciImage withImageSize:size];
        self.cameraView.hidden = YES;
    } else {
        self.centerView.hidden = YES;

    }
}

#pragma mark - Private

- (CIImage *)outputNormalImageWithString:(NSString *)string
                               imageSize:(CGSize)imageSize {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];

    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    [filter setValue:data forKey:@"inputMessage"];
    [filter setValue:@"H" forKey:@"inputCorrectionLevel"];

    return [filter outputImage];
}

- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image
                                       withImageSize:(CGSize)imageSize {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(imageSize.width / CGRectGetWidth(extent), imageSize.height / CGRectGetHeight(extent));

    size_t width  = CGRectGetWidth(extent)  * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);

    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);

    return [UIImage imageWithCGImage:scaledImage];;
}

@end
