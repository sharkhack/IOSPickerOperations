//
//  UIImagePickerController+NonRotatingViewController.m
//  IOSApplicationSettings
//
//  Created by Azer Bulbul on 1/21/14.
//  Copyright (c) 2014 Azer Bulbul. All rights reserved.
//

#import "UIImagePickerController+NonRotatingViewController.h"

@implementation UIImagePickerController (NonRotating)

- (BOOL)shouldAutorotate
{
    return NO;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

