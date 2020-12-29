//
//  ViewController.m
//  FaceSDKSample-ObjC
//
//  Created by Vladislav Yakimchik on 23.12.20.
//

#import "ViewController.h"

@import FaceSDK;
@import Photos;

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *firtImageView;
@property (weak, nonatomic) IBOutlet UIImageView *secondImageView;

@property (weak, nonatomic) IBOutlet UIButton *matchFacesButton;
@property (weak, nonatomic) IBOutlet UIButton *livenessButton;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;

@property (weak, nonatomic) IBOutlet UILabel *similarityLabel;
@property (weak, nonatomic) IBOutlet UILabel *livenessLabel;

@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) UIImageView *currentImageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imagePicker = [[UIImagePickerController alloc] init];
    
    UITapGestureRecognizer *tapGestureFirst = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    [self.firtImageView addGestureRecognizer:tapGestureFirst];
    self.firtImageView.userInteractionEnabled = YES;

    UITapGestureRecognizer *tapGestureSecond = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    [self.secondImageView addGestureRecognizer:tapGestureSecond];
    self.secondImageView.userInteractionEnabled = YES;

    self.similarityLabel.text = @"Similarity: nil";
    self.livenessLabel.text = @"Liveness: nil";
}

- (void)imageTapped:(UITapGestureRecognizer *)gesture {
    if (gesture.view != nil) {
        [self showActions:self imageView:(UIImageView *)gesture.view];
    }
}

- (void)showActions:(UIViewController *)controller imageView:(UIImageView *)imageView {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self startFaceCaptureVC:self imageView:imageView];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Gallery" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.currentImageView = imageView;
        imageView.tag = RGLImageTypePrinted;
        [self pickImage:UIImagePickerControllerSourceTypePhotoLibrary];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Camera shoot" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.currentImageView = imageView;
        imageView.tag = RGLImageTypeLive;
        [self pickImage:UIImagePickerControllerSourceTypeCamera];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    UIPopoverPresentationController *popoverPresentationController = alert.popoverPresentationController;
    if (popoverPresentationController != nil) {
        popoverPresentationController.sourceView = [self view];
        CGFloat midX = CGRectGetMidX(imageView.frame);
        CGFloat midY = CGRectGetMidY(imageView.frame);
        popoverPresentationController.sourceRect = CGRectMake(midX, midY, 0, 0);
    }
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)startFaceCaptureVC:(UIViewController *)controller imageView:(UIImageView *)imageView {
    [RGLFaceSDK.service presentFaceCaptureViewControllerFrom:self animated:YES onCapture:^(RGLImage * _Nullable image) {
        if (image != nil) {
            imageView.image = image.image;
            imageView.tag = RGLImageTypeLive;
        }
    } completion:nil];
}

- (IBAction)startMatchFaces:(id)sender {
    NSMutableArray *matchRequestImages = [[NSMutableArray alloc] init];

    if (self.firtImageView.image != nil && self.secondImageView.image != nil) {
        RGLImage *firstImage = [[RGLImage alloc] initWithImage:self.firtImageView.image];
        firstImage.imageType = self.firtImageView.tag;
        [matchRequestImages addObject: firstImage];

        RGLImage *secondImage = [[RGLImage alloc] initWithImage:self.secondImageView.image];
        secondImage.imageType = self.secondImageView.tag;
        [matchRequestImages addObject: secondImage];

        RGLMatchFacesRequest *request = [[RGLMatchFacesRequest alloc] initWithImages:matchRequestImages similarityThreshold:@0 customMetadata:nil];
        
        self.similarityLabel.text = @"Processing...";
        self.matchFacesButton.enabled = NO;
        self.livenessButton.enabled = NO;
        self.clearButton.enabled = NO;

        [RGLFaceSDK.service matchFaces:request completion:^(RGLMatchFacesResponse * _Nullable response, NSError * _Nullable error) {
            self.matchFacesButton.enabled = YES;
            self.livenessButton.enabled = YES;
            self.clearButton.enabled = YES;
            
            if (response != nil) {
                if (response.matchedFaces.firstObject) {
                    NSString *value = [NSString stringWithFormat:@"%.2f", [response.matchedFaces.firstObject.similarity doubleValue] * 100];
                    NSString *similarity = [NSString stringWithFormat:@"Similarity: %@%%", value];
                    self.similarityLabel.text = similarity;
                } else {
                    self.similarityLabel.text = @"Similarity: error";
                }
                NSLog(@"%@", response);
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:error.localizedDescription message:nil preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alert animated:YES completion:nil];
                NSLog(@"%@", error);
            }
        }];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Having both images are compulsory" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (IBAction)startLiveness:(id)sender {
    [RGLFaceSDK.service startLivenessFrom:self animated:YES onLiveness:^(RGLLivenessResponse * _Nonnull livenessResponse) {
        if (livenessResponse != nil) {
            self.firtImageView.image = livenessResponse.image;
            self.firtImageView.tag = RGLImageTypeLive;
            
            NSString *livenessStatus = livenessResponse.liveness == RGLLivenessStatusPassed ? @"Liveness: passed" : @"Liveness: unknown";
            self.livenessLabel.text = livenessStatus;
            self.similarityLabel.text = @"Similarity: nil";
        } else {
            NSLog(@"No response");
        }
    } completion:^{
        NSLog(@"Liveness completed");
    }];
}

- (IBAction)clear:(id)sender {
    self.firtImageView.image = nil;
    self.secondImageView.image = nil;
    self.similarityLabel.text = @"Similarity: nil";
    self.livenessLabel.text = @"Liveness: nil";
}

- (void)pickImage:(UIImagePickerControllerSourceType)sourceType {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        switch (status) {
            case PHAuthorizationStatusAuthorized: {
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.imagePicker.delegate = self;
                        self.imagePicker.sourceType = sourceType;
                        self.imagePicker.allowsEditing = NO;
                        self.imagePicker.navigationBar.tintColor = [UIColor blackColor];
                        [self presentViewController:self.imagePicker animated:YES completion:nil];
                    });
                }
            }
            break;

            case PHAuthorizationStatusDenied: {
                NSString *message = @"Application doesn't have permission to use the camera, please change privacy settings";
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Gallery Unavailable" message:message preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction: [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
                [alertController addAction:[UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    [UIApplication.sharedApplication openURL:url options:@{} completionHandler:nil];
                }]];
                [self presentViewController:alertController animated:YES completion:nil];
            }
            break;

            case PHAuthorizationStatusNotDetermined: {
                NSLog(@"%@", @"PHPhotoLibrary status: notDetermined");
            }

            case PHAuthorizationStatusRestricted: {
                NSLog(@"%@", @"PHPhotoLibrary status: restricted");
            }

            default:
            break;
        }
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:^{
        self.currentImageView.image = image;
    }];
}


@end
