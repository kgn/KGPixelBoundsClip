//
//  KGPixelBoundsClip.m
//  KGPixelBoundsClip
//
//  Created by David Keegan on 10/6/12.
//  Copyright (c) 2012 David Keegan. All rights reserved.
//

#import "KGPixelBoundsClip.h"

@interface KGPixelBoundsClip : NSObject
@property (nonatomic) CGRect rect;
@property (nonatomic) NSUInteger width;
@property (nonatomic) NSUInteger tolerance;
@property (strong, nonatomic) NSData *data;
@property (nonatomic) NSUInteger topLeftX, topLeftY, bottomRightX, bottomRightY;
@property (nonatomic) BOOL foundTopX, foundTopY, foundBottomRightX, foundBottomRightY;
@property (nonatomic) NSUInteger bitsOffset, bitsMultiplier;
@end

@implementation KGPixelBoundsClip

- (instancetype)initWithImage:(id)image andTolerance:(CGFloat)tolerance{
    if(!(self = [super init])){
        return nil;
    }
    self.tolerance = tolerance*255;

#if TARGET_OS_IPHONE
    CGImageRef imageRef = [(UIImage *)image CGImage];
#else
    CGImageRef imageRef = [(NSImage *)image CGImageForProposedRect:nil context:nil hints:nil];
#endif

    self.width = CGImageGetWidth(imageRef);
    self.bottomRightX = self.width;
    self.bottomRightY = CGImageGetHeight(imageRef);

    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
    self.bitsMultiplier = CGImageGetBitsPerPixel(imageRef)/8;
    switch(alphaInfo){
        case kCGImageAlphaNone:
        case kCGImageAlphaNoneSkipFirst:
        case kCGImageAlphaNoneSkipLast:
            return self;
            break;
        case kCGImageAlphaOnly:
        case kCGImageAlphaFirst:
        case kCGImageAlphaPremultipliedFirst:
            self.bitsOffset = 0;
            break;
        case kCGImageAlphaLast:
        case kCGImageAlphaPremultipliedLast:
            self.bitsOffset = 3;
            break;            
    }

    CGDataProviderRef provider = CGImageGetDataProvider(imageRef);
    self.data = CFBridgingRelease(CGDataProviderCopyData(provider));

//    NSLog(@"topLeft");
    [self findTopLeftPoint];
//    NSLog(@"bottomRight");
    [self findBottomRightPoint];

    return self;
}

- (BOOL)pixelIsOpaqueAtX:(NSUInteger)x andY:(NSUInteger)y{
//    NSLog(@"%lu, %lu", x, y);
    const uint8_t *bytes = [self.data bytes];
    NSUInteger pixelIndex = (y*self.width+x)*self.bitsMultiplier;
    NSUInteger alpha = bytes[pixelIndex+self.bitsOffset];
    if(alpha > 0){
        return (alpha >= self.tolerance);
    }
    return NO;
}

- (BOOL)rowContainsOpaquePixelInRowY:(NSUInteger)rowY fromX:(NSUInteger)fromX reversed:(BOOL)reversed{
    if(reversed){
        for(NSUInteger x = self.bottomRightX-1; x > self.topLeftX; --x){
            if([self pixelIsOpaqueAtX:x andY:rowY]){
                return YES;
            }
        }
    }else{
        for(NSUInteger x = fromX; x < self.bottomRightX; ++x){
            if([self pixelIsOpaqueAtX:x andY:rowY]){
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)rowContainsOpaquePixelInRowX:(NSUInteger)rowX fromY:(NSUInteger)fromY reversed:(BOOL)reversed{
    if(reversed){
        for(NSUInteger y = self.bottomRightY-1; y > self.topLeftY; --y){
            if([self pixelIsOpaqueAtX:rowX andY:y]){
                return YES;
            }
        }
    }else{
        for(NSUInteger y = fromY; y < self.bottomRightY; ++y){
            if([self pixelIsOpaqueAtX:rowX andY:y]){
                return YES;
            }
        }
    }
    return NO;
}

- (void)findTopLeftPoint{
    if(self.topLeftY >= self.bottomRightY || self.topLeftX >= self.bottomRightX){
        return;
    }

    if(!self.foundTopX){
        if([self rowContainsOpaquePixelInRowY:self.topLeftY fromX:self.topLeftX reversed:NO]){
            self.foundTopX = YES;
//            NSLog(@"found top left x: %lu", self.topLeftX);
        }else{
            self.topLeftY++;
        }
    }

    if(!self.foundTopY){
        if([self rowContainsOpaquePixelInRowX:self.topLeftX fromY:self.topLeftY reversed:NO]){
            self.foundTopY = YES;
//            NSLog(@"found top left y: %lu", self.topLeftY);
        }else{
            self.topLeftX++;
        }
    }

    if(!self.foundTopX || !self.foundTopY){
        [self findTopLeftPoint];
    }
}

- (void)findBottomRightPoint{
    if(self.topLeftY >= self.bottomRightY-1 || self.topLeftX >= self.bottomRightX-1){
        return;
    }

    if(!self.foundBottomRightY){
        if([self rowContainsOpaquePixelInRowY:self.bottomRightY-1 fromX:self.bottomRightX reversed:YES]){
            self.foundBottomRightY = YES;
//            NSLog(@"found bottom right y: %lu", self.bottomRightY);            
        }else{
            self.bottomRightY--;
        }
    }

    if(!self.foundBottomRightX){
        if([self rowContainsOpaquePixelInRowX:self.bottomRightX-1 fromY:self.bottomRightY reversed:YES]){
            self.foundBottomRightX = YES;
//            NSLog(@"found bottom right x: %lu", self.bottomRightX);  
        }else{
            self.bottomRightX--;
        }
    }

    if(!self.foundBottomRightY || !self.foundBottomRightX){
        [self findBottomRightPoint];
    }
}

- (CGRect)rect{
    CGRect clipRect = CGRectMake(self.topLeftX, self.topLeftY,
                                 self.bottomRightX-self.topLeftX,
                                 self.bottomRightY-self.topLeftY);
    if(clipRect.size.width <= 0){
        clipRect.origin.x = 0;
    }
    if(clipRect.size.height <= 0){
        clipRect.origin.y = 0;
    }

    return clipRect;
}

@end

#if TARGET_OS_IPHONE

@implementation UIImage(KGPixelBoundsClip)

- (CGRect)rectOfPixelBounds{
    return [self rectOfPixelBoundsWithTolerance:0];
}

- (CGRect)rectOfPixelBoundsWithTolerance:(CGFloat)tolerance{
    return [[[KGPixelBoundsClip alloc] initWithImage:self andTolerance:tolerance] rect];
}

- (UIImage *)imageClippedToPixelBounds{
    return [self imageClippedToPixelBoundsWithTolerance:0];
}

- (UIImage *)imageClippedToPixelBoundsWithTolerance:(CGFloat)tolerance{
    CGRect clipRect = [self rectOfPixelBoundsWithTolerance:tolerance];
    if(clipRect.size.width == 0 || clipRect.size.height == 0){
        return nil;
    }

    CGImageRef imageRef = [self CGImage];
    CGImageRef croppedImageRef = CGImageCreateWithImageInRect(imageRef, clipRect);
    UIImage *croppedImage = [[UIImage alloc] initWithCGImage:croppedImageRef
                                                       scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(croppedImageRef);
    return croppedImage;
}

@end

#else

@implementation NSImage(KGPixelBoundsClip)

- (CGRect)rectOfPixelBounds{
    return [self rectOfPixelBoundsWithTolerance:0];
}

- (CGRect)rectOfPixelBoundsWithTolerance:(CGFloat)tolerance{
    return [[[KGPixelBoundsClip alloc] initWithImage:self andTolerance:tolerance] rect];
}

- (NSImage *)imageClippedToPixelBounds{
    return [self imageClippedToPixelBoundsWithTolerance:0];
}

- (NSImage *)imageClippedToPixelBoundsWithTolerance:(CGFloat)tolerance{
    CGRect clipRect = [self rectOfPixelBoundsWithTolerance:tolerance];
    if(clipRect.size.width == 0 || clipRect.size.height == 0){
        return nil;
    }

    CGImageRef imageRef = [self CGImageForProposedRect:nil context:nil hints:nil];
    CGImageRef croppedImageRef = CGImageCreateWithImageInRect(imageRef, clipRect);
    NSImage *croppedImage = [[NSImage alloc] initWithCGImage:croppedImageRef size:NSZeroSize];
    CGImageRelease(croppedImageRef);
    return croppedImage;
}

@end

#endif
