//
//  KGPixelBoundsClip.m
//  KGPixelBoundsClip
//
//  Created by David Keegan on 10/6/12.
//  Copyright (c) 2012 David Keegan. All rights reserved.
//

#import "KGPixelBoundsClip.h"

@interface KGPixelBoundsClip : NSObject
@property (nonatomic) unsigned char *rawData;
@property (nonatomic) NSUInteger topLeftX, topLeftY;
@property (nonatomic) NSUInteger bottomRightX, bottomRightY;
@property (nonatomic) CGFloat tolerance;
@property (nonatomic) CGRect rect;
@property (nonatomic) NSUInteger width;
- (id)initWithImage:(id)image andTolerance:(CGFloat)tolerance;
@end

@implementation KGPixelBoundsClip

- (id)initWithImage:(id)image andTolerance:(CGFloat)tolerance{
    if(!(self = [super init])){
        return nil;
    }
    self.tolerance = tolerance;

#if TARGET_OS_IPHONE
    CGImageRef imageRef = [(UIImage *)image CGImage];
#else
    CGImageRef imageRef = [(NSImage *)image CGImageForProposedRect:nil context:nil hints:nil];
#endif
    self.width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bytesPerPixel = 4;
    NSUInteger bitsPerComponent = 8;    
    self.rawData = malloc(height*self.width*bytesPerPixel);
    NSUInteger bytesPerRow = bytesPerPixel*self.width;
    CGContextRef context = CGBitmapContextCreate(self.rawData, self.width, height,
												 bitsPerComponent, bytesPerRow, colorSpace,
												 kCGImageAlphaPremultipliedLast|kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);

    CGContextDrawImage(context, CGRectMake(0, 0, self.width, height), imageRef);
    CGContextRelease(context);

    self.bottomRightX = self.width-1;
    self.bottomRightY = height-1;

    [self findTopLeftPoint];
    [self findBottomRightPoint];

    return self;
}

- (void)dealloc{
    free(self.rawData);
}

- (BOOL)pixelIsOpaqueAtX:(NSUInteger)x andY:(NSUInteger)y{
    NSUInteger pixelIndex = (y*self.width+x)*4;
    CGFloat alpha = (CGFloat)self.rawData[pixelIndex+3]/255;
    if(alpha > 0){
        return (alpha >= self.tolerance);
    }
    return NO;
}

- (BOOL)rowContainsOpaquePixelInRowY:(NSUInteger)rowY fromX:(NSUInteger)fromX reversed:(BOOL)reversed{
    if(reversed){
        for(NSUInteger x = self.bottomRightX; x > self.topLeftX; --x){
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
        for(NSUInteger y = self.bottomRightY; y > self.topLeftY; --y){
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
    if(self.topLeftY >= self.bottomRightY){
        return;
    }
    if(self.topLeftX >= self.bottomRightX){
        return;
    }

    BOOL foundY = [self rowContainsOpaquePixelInRowY:self.topLeftY fromX:self.topLeftX reversed:NO];
    BOOL foundX = [self rowContainsOpaquePixelInRowX:self.topLeftX fromY:self.topLeftY reversed:NO];

    if(!foundY){
        self.topLeftY++;
    }
    if(!foundX){
        self.topLeftX++;
    }

    if(!foundX || !foundY){
        [self findTopLeftPoint];
    }
}

- (void)findBottomRightPoint{
    if(self.topLeftY >= self.bottomRightY){
        return;
    }
    if(self.topLeftX >= self.bottomRightX){
        return;
    }

    BOOL foundY = [self rowContainsOpaquePixelInRowY:self.bottomRightY fromX:self.bottomRightX reversed:YES];
    BOOL foundX = [self rowContainsOpaquePixelInRowX:self.bottomRightX fromY:self.bottomRightY reversed:YES];

    if(!foundY){
        self.bottomRightY--;
    }
    if(!foundX){
        self.bottomRightX--;
    }

    if(!foundX || !foundY){
        [self findBottomRightPoint];
    }
}

- (CGRect)rect{
    CGRect clipRect = CGRectMake(self.topLeftX, self.topLeftY,
                                 self.bottomRightX-self.topLeftX,
                                 self.bottomRightY-self.topLeftY);
    if(clipRect.size.width > 0){
        clipRect.size.width++;
    }else{
        clipRect.origin.x = 0;
    }
    if(clipRect.size.height > 0){
        clipRect.size.height++;
    }else{
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
