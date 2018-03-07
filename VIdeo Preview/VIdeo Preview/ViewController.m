//
//  ViewController.m
//  VIdeo Preview
//
//  Created by Hal Mueller on 2/27/18.
//  Copyright © 2018 Panopto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "PANRCaptureGraph.h"

#import "ViewController.h"
@interface ViewController ()

@property (weak) IBOutlet NSView *videoPreviewView;
@property (nonatomic, assign) NSInteger state;
@property (nonatomic, retain) PANRCaptureGraph *capture;

@end

@implementation ViewController

- (void)awakeFromNib
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.state = 0; // init
}

- (void)start
{
    self.capture = [[PANRCaptureGraph alloc] init];

    CALayer *previewLayer = nil;
    [self.capture getPreviewLayer:&previewLayer];
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        self.videoPreviewView.hidden = YES;
        
        if (previewLayer != nil) {
            previewLayer.frame = self.videoPreviewView.layer.bounds;
            [self.videoPreviewView.layer addSublayer:previewLayer];
            self.videoPreviewView.hidden = NO;
        }
    });
}

- (IBAction)doTheThing:(id)sender
{
    switch(self.state)
    {
        case 0:
            NSLog(@"Initializing capture graph and starting the graph.");
            [self start];
            self.state = 1;
            break;
            
        case 1:
            NSLog(@"No action from here");
            break;
            
        default:
            NSLog(@"Unexpected state.");
    }
}

@end
