//
//  pickeroperations.m
//  pickeroperations
//
//  Created by Azer Bulbul on 1/26/14.
//  Copyright (c) 2014 Azer Bulbul. All rights reserved.
//

#import "pickeroperations.h"

FREContext AirCtx = nil;
CGSize maximumSize;

@implementation pickeroperations

@synthesize uiImgPicker = _uiImgPicker;
@synthesize uiPopover = _uiPopover;
@synthesize uiPickedImage = _uiPickedImage;

static pickeroperations *sharedInstance = nil;

+ (pickeroperations *)sharedInstance
{
    if (sharedInstance == nil)
    {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [pickeroperations sharedInstance];
}

- (id)copy
{
    return self;
}

- (void)dealloc
{
    [_uiImgPicker release];
    [_uiPopover release];
    [_uiPickedImage release];
    
    [super dealloc];
}

- (void) refreshStatusBar:(NSString*)styleType
{
    if([styleType  isEqualToString:@"UIStatusBarStyleLightContent"]){
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    } else if ([styleType  isEqualToString:@"UIStatusBarStyleBlackOpaque"]){
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    } else if ([styleType  isEqualToString:@"UIStatusBarStyleBlackTranslucent"]){
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
    } else if ([styleType  isEqualToString:@"UIStatusBarStyleDefault"]){
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }
}

-(void)displayImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType anchor:(CGRect)anchor
{
    UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    
    self.uiImgPicker = [[[UIImagePickerController alloc] init] autorelease];
    self.uiImgPicker.sourceType = sourceType;
    self.uiImgPicker.delegate = self;
    
    if (sourceType == UIImagePickerControllerSourceTypeCamera || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [rootViewController presentViewController:self.uiImgPicker animated:NO completion:nil];
    }
    else
    {
        self.uiPopover = [[[UIPopoverController alloc] initWithContentViewController:self.uiImgPicker] autorelease];
        self.uiPopover.delegate = self;
        [self.uiPopover presentPopoverFromRect:anchor inView:rootViewController.view
                    permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
    }
    
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if (self.uiPopover) {
        [self.uiPopover dismissPopoverAnimated:NO];
        self.uiPopover = nil;
        
        [self refreshStatusBar:@"UIStatusBarStyleLightContent"];
    } else {
        
        [self.uiImgPicker dismissViewControllerAnimated:YES completion:^{
            self.uiImgPicker = nil;
            [self refreshStatusBar:@"UIStatusBarStyleLightContent"];
        }];
        
    }
    
    if (CFStringCompare((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo)
    {
        [self onImagePickedWithOriginalImage:[info objectForKey:UIImagePickerControllerOriginalImage]
                                 editedImage:[info objectForKey:UIImagePickerControllerEditedImage]];
    }
}

- (void) onImagePickedWithOriginalImage:(UIImage*)originalImage editedImage:(UIImage*)editedImage
{
    dispatch_queue_t thread = dispatch_queue_create("processing", NULL);
    dispatch_async(thread, ^{
        
        [_uiPickedImage release];
        _uiPickedImage = nil;
        
        if (editedImage)
        {
            _uiPickedImage =editedImage;
        }
        else
        {
            _uiPickedImage =originalImage;
        }
        
        // if you use maximum image width and height
        if(maximumSize.width > 0.0 && maximumSize.height > 0.0){
            _uiPickedImage = [_uiPickedImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:maximumSize interpolationQuality:kCGInterpolationDefault];
        } else {
            _uiPickedImage = [_uiPickedImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:_uiPickedImage.size interpolationQuality:kCGInterpolationDefault];
        }
        
        [_uiPickedImage retain];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            FREDispatchStatusEventAsync(AirCtx, (const uint8_t *)"PICKED", (const uint8_t *)"IMAGE");
        });
        
    });
    dispatch_release(thread);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (self.uiPopover)
    {
        [self.uiPopover dismissPopoverAnimated:NO];
        self.uiPopover = nil;
        [self refreshStatusBar:@"UIStatusBarStyleLightContent"];
        
    }
    else
    {
        [self.uiImgPicker dismissViewControllerAnimated:YES completion:^{
            self.uiImgPicker = nil;
            [self refreshStatusBar:@"UIStatusBarStyleLightContent"];
            
        }];
        
    }
    FREDispatchStatusEventAsync(AirCtx, (const uint8_t *)"CANCEL", (const uint8_t *)"OK");
    
}


- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if (self.uiPopover)
    {
        [self.uiPopover dismissPopoverAnimated:NO];
        self.uiPopover = nil;
        [self refreshStatusBar:@"UIStatusBarStyleLightContent"];
        
    }
    else
    {
        [self.uiImgPicker dismissViewControllerAnimated:YES completion:^{
            self.uiImgPicker = nil;
            [self refreshStatusBar:@"UIStatusBarStyleLightContent"];
            
        }];
        
    }
    FREDispatchStatusEventAsync(AirCtx, (const uint8_t *)"CANCEL", (const uint8_t *)"OK");
}

@end


NSData *toNSDataByteArray(FREObject *ba)
{
    FREByteArray byteArray;
    FREAcquireByteArray(ba, &byteArray);
    
    NSData *d = [NSData dataWithBytes:(void *)byteArray.bytes length:(NSUInteger)byteArray.length];
    FREReleaseByteArray(ba);
    
    return d;
}

FREObject isAvailablePicker(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    BOOL isAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    
    FREObject result;
    if (FRENewObjectFromBool(isAvailable, &result) == FRE_OK)
    {
        return result;
    }
    else return nil;
}


FREObject isAvailableCamera(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    BOOL isAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    
    FREObject result;
    if (FRENewObjectFromBool(isAvailable, &result) == FRE_OK)
    {
        return result;
    }
    else return nil;
}

FREObject showImagePicker(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    
    CGRect anchor;
    if (argc > 2)
    {
        FREObject anchorObject = argv[2];
        FREObject anchorX, anchorY, anchorWidth, anchorHeight, thrownException;
        FREGetObjectProperty(anchorObject, (const uint8_t *)"x", &anchorX, &thrownException);
        FREGetObjectProperty(anchorObject, (const uint8_t *)"y", &anchorY, &thrownException);
        FREGetObjectProperty(anchorObject, (const uint8_t *)"width", &anchorWidth, &thrownException);
        FREGetObjectProperty(anchorObject, (const uint8_t *)"height", &anchorHeight, &thrownException);
        
        // Convert anchor properties to double
        double x, y, width, height;
        FREGetObjectAsDouble(anchorX, &x);
        FREGetObjectAsDouble(anchorY, &y);
        FREGetObjectAsDouble(anchorWidth, &width);
        FREGetObjectAsDouble(anchorHeight, &height);
        
        // Divide properties by the scale (useful for Retina Display)
        CGFloat scale = [[UIScreen mainScreen] scale];
        anchor = CGRectMake(x/scale, y/scale, width/scale, height/scale);
    }
    else
    {
        UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        anchor = CGRectMake(rootViewController.view.bounds.size.width - 100, 0, 100, 1); // Default anchor: Top right corner
    }
    
    FREObject _mxwidth =argv[0];
    FREObject _mxheight =argv[1];
    double _w,_h;
    FREGetObjectAsDouble(_mxwidth,&_w);
    FREGetObjectAsDouble(_mxheight,&_h);
    
    float neww = (float) _w;
    float newh = (float) _h;
    
    maximumSize = CGSizeMake(neww, newh);
    
    [[pickeroperations sharedInstance] displayImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary anchor:anchor];
    
    return nil;
}


FREObject showCamera(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
   
    double _w,_h;
    
    if (argc > 1)
    {
        FREObject _mxwidth =argv[0];
        FREObject _mxheight =argv[1];
    
        FREGetObjectAsDouble(_mxwidth,&_w);
        FREGetObjectAsDouble(_mxheight,&_h);
    } else {
        _w = 0.0;
        _h = 0.0;
    }
    
    float neww = (float) _w;
    float newh = (float) _h;
    
    maximumSize = CGSizeMake(neww, newh);
    
    [[pickeroperations sharedInstance] displayImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera anchor:CGRectZero];
    
    return nil;
}

FREObject getImageWidth(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    
    UIImage *uiPickedImage = [[pickeroperations sharedInstance] uiPickedImage];
    
    if (uiPickedImage)
    {
        CGImageRef imageRef = [uiPickedImage CGImage];
        NSUInteger width = CGImageGetWidth(imageRef);
        
        FREObject result;
        if (FRENewObjectFromUint32(width, &result) == FRE_OK)
        {
            return result;
        }
        else
        {
            return nil;
        }
    }
    else
    {
        return nil;
    }
}

FREObject getImageHeight(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    
   
    
    UIImage *uiPickedImage = [[pickeroperations sharedInstance] uiPickedImage];
    
    if (uiPickedImage)
    {
        CGImageRef imageRef = [uiPickedImage CGImage];
        NSUInteger height = CGImageGetHeight(imageRef);
        
        FREObject result;
        if (FRENewObjectFromUint32(height, &result) == FRE_OK)
        {
           return result;
        }
        else
        {
             return nil;
        }
    }
    else
    {
        return nil;
    }
}

FREObject getBitmapData(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    
    
    UIImage *uiPickedImage = [[pickeroperations sharedInstance] uiPickedImage];
    
    if (uiPickedImage)
    {
        FREBitmapData bitmapData;
        FREAcquireBitmapData(argv[0], &bitmapData);
        CGImageRef imageRef = [uiPickedImage CGImage];
        NSUInteger width = CGImageGetWidth(imageRef);
        NSUInteger height = CGImageGetHeight(imageRef);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        unsigned char *rawData = malloc(height * width * 4);
        NSUInteger bytesPerPixel = 4;
        NSUInteger bytesPerRow = bytesPerPixel * width;
        NSUInteger bitsPerComponent = 8;
        CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
        CGColorSpaceRelease(colorSpace);
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
        CGContextRelease(context);
        int x, y;
        int offset = bitmapData.lineStride32 - bitmapData.width;
        int offset2 = bytesPerRow - bitmapData.width*4;
        int byteIndex = 0;
        uint32_t *bitmapDataPixels = bitmapData.bits32;
        for (y=0; y<bitmapData.height; y++)
        {
            for (x=0; x<bitmapData.width; x++, bitmapDataPixels++, byteIndex += 4)
            {
                // Values are currently in RGBA7777, so each color value is currently a separate number.
                int red     = (rawData[byteIndex]);
                int green   = (rawData[byteIndex + 1]);
                int blue    = (rawData[byteIndex + 2]);
                int alpha   = (rawData[byteIndex + 3]);
                
                // Combine values into ARGB32
                *bitmapDataPixels = (alpha << 24) | (red << 16) | (green << 8) | blue;
            }
            
            bitmapDataPixels += offset;
            byteIndex += offset2;
        }
        
        free(rawData);
        
        FREInvalidateBitmapDataRect(argv[0], 0, 0, bitmapData.width, bitmapData.height);
        
        FREReleaseBitmapData(argv[0]);
    }

    return nil;
}

#pragma write bitmapdata to cameraroll

FREObject writeCompressedImageToLibrary(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    
    NSData *d = toNSDataByteArray(argv[0]);
    
    ALAssetsLibrary *library = [[[ALAssetsLibrary alloc] init] autorelease];
    [library writeImageDataToSavedPhotosAlbum:d metadata:nil
                              completionBlock:^(NSURL *assetURL, NSError *error){
                                  if (error != NULL) {
                                      FREDispatchStatusEventAsync(AirCtx, (const uint8_t *)"SAVED", (const uint8_t *)"ERROR");
                                      
                                  } else {
                                      FREDispatchStatusEventAsync(AirCtx, (const uint8_t *)"SAVED", (const uint8_t *)"OK");
                                      
                                  }
                              }];
    
    
    
    
    return NULL;
}


void ContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx,
						uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet) {
    
    *numFunctionsToTest = 15;
    
	FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * 15);
	func[0].name = (const uint8_t*) "isAvailablePicker";
	func[0].functionData = NULL;
    func[0].function = &isAvailablePicker;
    
    func[1].name = (const uint8_t*) "isAvailableCamera";
	func[1].functionData = NULL;
    func[1].function = &isAvailableCamera;
    
    func[2].name = (const uint8_t*) "showImagePicker";
    func[2].functionData = NULL;
    func[2].function = &showImagePicker;
    
    func[3].name = (const uint8_t*) "showCamera";
    func[3].functionData = NULL;
    func[3].function = &showCamera;
    
    func[4].name = (const uint8_t*) "getImageWidth";
    func[4].functionData = NULL;
    func[4].function = &getImageWidth;
    
    func[5].name = (const uint8_t*) "getImageHeight";
    func[5].functionData = NULL;
    func[5].function = &getImageHeight;
    
    func[6].name = (const uint8_t*) "getBitmapData";
    func[6].functionData = NULL;
    func[6].function = &getBitmapData;
    
    func[7].name = (const uint8_t*) "writeCompressedImageToLibrary";
    func[7].functionData = NULL;
    func[7].function = &writeCompressedImageToLibrary;
    
	*functionsToSet = func;
    
    AirCtx = ctx;
    
    
}


void ContextFinalizer(FREContext ctx) {
    AirCtx = nil;
    return;
}

void ExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet,
                    FREContextFinalizer* ctxFinalizerToSet) {
    
    *extDataToSet = NULL;
    *ctxInitializerToSet = &ContextInitializer;
    *ctxFinalizerToSet = &ContextFinalizer;
}

void ExtFinalizer(void* extData) {
    return;
}

