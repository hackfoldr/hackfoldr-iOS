//
//  QRCodeViewController.m
//  hackfoldr-iOS
//
//  Created by Superbil on 2017/11/22.
//  Copyright © 2017年 org.g0v. All rights reserved.
//

#import "QRCodeViewController.h"

#import <AVFoundation/AVFoundation.h>

@interface QRCodeViewController () <AVCaptureMetadataOutputObjectsDelegate>
@property IBOutlet NSLayoutConstraint *widthOfCenterViewConstraint;
@property IBOutlet UIView *centerView;
@property IBOutlet UIImageView *qrCodeImageView;
@property IBOutlet UIView *cameraView;

@property AVCaptureDevice *device;
@property AVCaptureSession *session;
@property AVCaptureVideoPreviewLayer *previewLayer;
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
#if !TARGET_IPHONE_SIMULATOR
        [self showCapture];
#endif
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

- (void)showCapture {
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];

    self.session = [[AVCaptureSession alloc] init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];

    if ([self.session canAddInput:input]) {
        [self.session addInput:input];
    }
    if ([self.session canAddOutput:output]) {
        [self.session addOutput:output];
    }

    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];

    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.previewLayer.videoGravity = AVLayerVideoGravityResize;;
    self.previewLayer.frame = self.view.bounds;

    [self.cameraView.layer insertSublayer:self.previewLayer atIndex:0];
    self.centerView.hidden = YES;

    [self.session startRunning];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if (metadataObj.stringValue && metadataObj.stringValue.length > 0) {

            [self.session stopRunning];

            if (self.foundedResult) {
                self.foundedResult(metadataObj.stringValue);
            }
        }
    }
}

@end
