// Forward declaration
@protocol PANRCaptureGraphDelegate;


@interface PANRCaptureGraph : NSObject

-(instancetype) init;

-(BOOL) getPreviewLayer:(CALayer * __autoreleasing *) outPreviewLayer;

@end
