#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "PANRCaptureGraph.h"


@interface PANRCaptureGraph()  <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;
@property (nonatomic, strong) dispatch_queue_t videoDeliveryQueue;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preview;
@property (nonatomic, assign) SInt32 numVideoSamples;

@end


@implementation PANRCaptureGraph

-(instancetype) init
{
    self = [super init];
    self.numVideoSamples = 0;

    _session = [[AVCaptureSession alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onSessionRuntimeErrorNotification:)
                                                 name:AVCaptureSessionRuntimeErrorNotification
                                               object:_session];
    
    [self setupScreen];

    [self.session startRunning];

    return self;
}

-(BOOL) setupScreen
{
    AVCaptureScreenInput *input = nil;

    // The first display returned by CGGetActiveDisplayList is guaranteed to be the main display.
    CGDirectDisplayID displays[10];
    uint32_t numberOfDisplays;
    CGError result = CGGetActiveDisplayList(sizeof(displays), displays, &numberOfDisplays);
    if (result != noErr || numberOfDisplays < 1)
    {
        NSLog(@"Failed to query display informaiton.");
        return NO;
    }
    CGDirectDisplayID primaryDisplayId = displays[0];
    
    if(!CGDisplayIsActive(primaryDisplayId))
    {
        NSLog(@"Error: display is not active.");
        return NO;
    }
    
    input = [[AVCaptureScreenInput alloc] initWithDisplayID:primaryDisplayId];
    if (input == nil)
    {
        NSLog(@"Error: input is nil.");
        return NO;
    }

    if (![_session canAddInput:input])
    {
        NSLog(@"Error: input cannot be added.");
        return NO;
    }
    [_session addInput:input];

    _videoDeliveryQueue = dispatch_queue_create("com.panopto.PANRCaptureGraph.videoDeliveryQueue", DISPATCH_QUEUE_SERIAL);
    if (_videoDeliveryQueue == nil)
    {
        NSLog(@"Error: _videoDeliveryQueue in nil.");
        return NO;
    }
    
    _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    if (_videoOutput == nil)
    {
        NSLog(@"Error: _videoOutput in nil.");
        return NO;
    }
    [_videoOutput setSampleBufferDelegate:self queue:_videoDeliveryQueue];
    
    if (![_session canAddOutput:_videoOutput])
    {
        NSLog(@"Error: output cannot be added.");
        return NO;
    }
    [_session addOutput:_videoOutput];
    
    return YES;
}

-(void) dealloc
{
    NSLog(@"PANRCaptureGraph -dealloc:");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(BOOL) getPreviewLayer:(CALayer * __autoreleasing *) outPreviewLayer
{
    if (!self.preview)
    {
        self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    }
    
    *outPreviewLayer = self.preview;
    if (self.preview == nil)
    {
        return NO;
    }
    return YES;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    // This is the callback where AVFoundation capture graph sends captured vidoe samples.
    // In real application, we further send these samples to encoding pipeline.
    // This test app simply counts the number of arrived samples and logs once in each 30th sample.
    
    self.numVideoSamples++;
    if (self.numVideoSamples % 30 == 1)
    {
        NSLog(@"Video sample %d arrived.", self.numVideoSamples);
    }
}


// Runtime error notification
-(void) onSessionRuntimeErrorNotification:(NSNotification *) notification
{
    NSError *error = [notification.userInfo valueForKey:AVCaptureSessionErrorKey];
    NSLog(@"onSessionRuntimeErrorNotification: %@, %@, %@", error.localizedDescription, error.localizedFailureReason, error.localizedRecoverySuggestion);
}

@end
