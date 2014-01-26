//
//  pickeroperations.h
//  pickeroperations
//
//  Created by Azer Bulbul on 1/26/14.
//  Copyright (c) 2014 Azer Bulbul. All rights reserved.
//

#import "FlashRuntimeExtensions.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "UIImage+Resize.h"
#import "UIImagePickerController+NonRotatingViewController.h"


@interface pickeroperations : NSObject <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate>

@property (nonatomic, retain) UIImagePickerController *uiImgPicker;
@property (nonatomic, retain) UIPopoverController *uiPopover;
@property (nonatomic, readonly) UIImage *uiPickedImage;

+ (pickeroperations *)sharedInstance;

- (void) refreshStatusBar:(NSString*)styleType;

- (void) displayImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType anchor:(CGRect)anchor;
- (void) onImagePickedWithOriginalImage:(UIImage*)originalImage editedImage:(UIImage*)editedImage;

@end

void ContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx,
						uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet);

void ContextFinalizer(FREContext ctx);

void ExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet,
                    FREContextFinalizer* ctxFinalizerToSet);

void ExtFinalizer(void* extData);