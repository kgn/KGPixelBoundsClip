//
//  NSImage+PixelBoundsClip.m
//  KGPixelBoundsClip
//
//  Created by David Keegan on 10/5/12.
//  Copyright (c) 2012 David Keegan. All rights reserved.
//

#import "NSImage+PixelBoundsClip.h"

@interface KGPixelBoundsClip : NSObject
@property (nonatomic) NSRect rect;
- (id)initWithImage:(NSImage *)image andTolerance:(CGFloat)tolerance;
@end

@implementation NSImage(PixelBoundsClip)

- (NSRect)rectOfPixelBounds{
    return [self rectOfPixelBoundsWithTolerance:0];
}

- (NSRect)rectOfPixelBoundsWithTolerance:(CGFloat)tolerance{
    return [[[KGPixelBoundsClip alloc] initWithImage:self andTolerance:tolerance] rect];
}

- (NSImage *)imageClippedToPixelBounds{
    return [self imageClippedToPixelBoundsWithTolerance:0];
}

- (NSImage *)imageClippedToPixelBoundsWithTolerance:(CGFloat)tolerance{
    NSRect clipRect = [self rectOfPixelBoundsWithTolerance:tolerance];
    if(clipRect.size.width == 0 || clipRect.size.height == 0){
        return nil;
    }
    
    CGImageRef imageRef = [self CGImageForProposedRect:nil context:nil hints:nil];
    CGImageRef croppedImageRef = CGImageCreateWithImageInRect(imageRef, clipRect);
    CGImageRelease(imageRef), imageRef = nil;
    NSImage *croppedImage = [[NSImage alloc] initWithCGImage:croppedImageRef size:NSZeroSize];
    CGImageRelease(croppedImageRef), croppedImageRef = nil;
    return croppedImage;
}

@end

@interface KGPixelBoundsClip()
@property (strong, nonatomic) NSBitmapImageRep *bitmapImage;
@property (nonatomic) NSUInteger topLeftX, topLeftY;
@property (nonatomic) NSUInteger bottomRightX, bottomRightY;
@property (nonatomic) CGFloat tolerance;
@end

@implementation KGPixelBoundsClip

- (id)initWithImage:(NSImage *)image andTolerance:(CGFloat)tolerance{
    if(!(self = [super init])){
        return nil;
    }
    self.tolerance = tolerance;
    self.bitmapImage = [[NSBitmapImageRep alloc] initWithData:[image TIFFRepresentation]];
    self.bottomRightX = [self.bitmapImage pixelsWide]-1;
    self.bottomRightY = [self.bitmapImage pixelsHigh]-1;
    [self findTopLeftPoint];
    [self findBottomRightPoint];
    return self;
}

- (BOOL)pixelIsOpaqueAtX:(NSUInteger)x andY:(NSUInteger)y{
    CGFloat red, green, blue, alpha;
    NSColor *color = [self.bitmapImage colorAtX:x y:y];
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    return (alpha > self.tolerance);
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

- (NSRect)rect{
    NSRect clipRect = NSMakeRect(self.topLeftX, self.topLeftY,
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
