//
//  PlacaViewController.m
//  TaxiLegal
//
//  Created by Vinicius Mello Lima on 23/04/14.
//  Copyright (c) 2014 Vinicius Mello Lima. All rights reserved.
//

#import "PlacaViewController.h"
#import <TesseractOCR/TesseractOCR.h>
#import "ImageCropView.h"

@interface PlacaViewController ()

@property (nonatomic, retain) UIImagePickerController *imgPickerPlaca;

@property (weak, nonatomic) IBOutlet UITextField *txtPlacaTaxi;
@property (weak, nonatomic) IBOutlet UILabel *lblInfoTaxi;

@end

@implementation PlacaViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _imgPickerPlaca = [[UIImagePickerController alloc] init];
    _imgPickerPlaca.delegate = self;
//    _imgPickerPlaca.allowsEditing = false;
//    _imgPickerPlaca.showsCameraControls = false;

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        _imgPickerPlaca.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        _imgPickerPlaca.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (IBAction)consultarInformacoesTaxi:(id)sender
{
    [self presentViewController:_imgPickerPlaca animated:YES completion:nil];
    /*
    NSString *placaTaxi = _txtPlacaTaxi.text;
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[A-Z]{3}[0-9]{4}"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *matches = [regex matchesInString:placaTaxi
                                      options:0
                                        range:NSMakeRange(0, [placaTaxi length])];
    if (matches.count == 1) {
        NSString *finalPlaca = [placaTaxi substringWithRange:NSMakeRange(5, 2)];

//        NSDate *hoje = [NSDate date];
        
        //
        
        _lblInfoTaxi.text = finalPlaca;
    } else {
        _txtPlacaTaxi.text = @"";
        
        NSString *msg = [NSString stringWithFormat:@"A placa %@ é inválida.", placaTaxi];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Placa inválida."
                                                        message:msg
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
     */
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (picker == _imgPickerPlaca) {
        [self dismissViewControllerAnimated:YES completion:nil];

        UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
        if (!image) {
            image = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        UIImage *editedImage = gs_convert_image(image);
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        UIImageWriteToSavedPhotosAlbum(editedImage, nil, nil, nil);

        Tesseract* tesseract = [[Tesseract alloc] initWithLanguage:@"eng+por"];
//        tesseract.delegate = self;

//        [tesseract setVariableValue:@"0123456789" forKey:@"tessedit_char_whitelist"];
        [tesseract setImage: editedImage];
        [tesseract recognize];

        _txtPlacaTaxi.text = [tesseract recognizedText];

        tesseract = nil;
    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

 #pragma mark - Tratamento de imagem.

UIImage * gs_convert_image (UIImage * src_img) {
    CGColorSpaceRef d_colorSpace = CGColorSpaceCreateDeviceRGB();
    /*
     * Note we specify 4 bytes per pixel here even though we ignore the
     * alpha value; you can't specify 3 bytes per-pixel.
     */
    size_t d_bytesPerRow = src_img.size.width * 4;
    unsigned char * imgData = (unsigned char*)malloc(src_img.size.height*d_bytesPerRow);
    CGContextRef context =  CGBitmapContextCreate(imgData, src_img.size.width,
                                                  src_img.size.height,
                                                  8, d_bytesPerRow,
                                                  d_colorSpace,
                                                  kCGImageAlphaNoneSkipFirst);
    
    UIGraphicsPushContext(context);
    // These next two lines 'flip' the drawing so it doesn't appear upside-down.
    CGContextTranslateCTM(context, 0.0, src_img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    // Use UIImage's drawInRect: instead of the CGContextDrawImage function, otherwise you'll have issues when the source image is in portrait orientation.
    [src_img drawInRect:CGRectMake(0.0, 0.0, src_img.size.width, src_img.size.height)];
    UIGraphicsPopContext();
    
    /*
     * At this point, we have the raw ARGB pixel data in the imgData buffer, so
     * we can perform whatever image processing here.
     */
    
    
    // After we've processed the raw data, turn it back into a UIImage instance.
    CGImageRef new_img = CGBitmapContextCreateImage(context);
    UIImage * convertedImage = [[UIImage alloc] initWithCGImage:
                                new_img];
    
    CGImageRelease(new_img);
    CGContextRelease(context);
    CGColorSpaceRelease(d_colorSpace);
    free(imgData);
    return convertedImage;
}

@end
