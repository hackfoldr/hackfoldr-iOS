//
//  HFSettingVC.m
//  hackfoldr-iOS
//
//  Created by bunny lin on 2014/9/29.
//  Copyright (c) 2014年 org.superbil. All rights reserved.
//

#import "HFSettingVC.h"
#import "HackfoldrClient.h"

#define HACKFOLDR_URL @"hack.etblue.tw"

@interface HFSettingVC ()

@end

@implementation HFSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction) updateHackFoldrURL:(id)sender
{
    NSString* hfId;
    if (self.idTextField.text != NULL)
    {
        hfId = self.idTextField.text;
    }
    else {
    
        NSString *input = self.urlTextField.text;
        NSString* regexString = @"hack.etblue.tw/([^/]*)/*";
        NSRegularExpression *regex =
        [NSRegularExpression regularExpressionWithPattern:regexString
                                                  options:NSRegularExpressionCaseInsensitive
                                                    error:nil];
        NSRange range = NSMakeRange(0,input.length);
        hfId = [regex stringByReplacingMatchesInString:input
                                               options:0
                                                 range:range
                                          withTemplate:@"$1"];
    }

    [[HackfoldrClient sharedClient] setHackfoldrId:hfId];
    [self.navigationController popViewControllerAnimated:YES];
    
}

@end
