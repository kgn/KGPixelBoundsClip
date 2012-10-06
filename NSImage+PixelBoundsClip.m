//
//  NSImage+PixelBoundsClip.m
//  KGPixelBoundsClip
//
//  Created by David Keegan on 10/5/12.
//  Copyright (c) 2012 David Keegan. All rights reserved.
//

#import "NSImage+PixelBoundsClip.h"

@implementation NSImage(PixelBoundsClip)

- (NSRect)rectOfPixelBounds{
    NSBitmapImageRep *bitmapImage = [[NSBitmapImageRep alloc] initWithData:[self TIFFRepresentation]];
    NSInteger width = [bitmapImage pixelsWide];
    NSInteger height = [bitmapImage pixelsHigh];

    NSRect clipRect = CGRectZero;
    clipRect.origin.x = clipRect.size.width = round(width*0.5);
    clipRect.origin.y = clipRect.size.height = round(height*0.5);
    for(NSUInteger x = 0; x < width; ++x){
        for(NSUInteger y = 0; y < height; ++y){
            CGFloat red, green, blue, alpha;
            NSColor *color = [bitmapImage colorAtX:x y:y];
            [color getRed:&red green:&green blue:&blue alpha:&alpha];
            if(alpha > 0){
                if(x < clipRect.origin.x){
                    clipRect.origin.x = x;
                }else if(x > clipRect.size.width){
                    clipRect.size.width = x;
                }

                if(y < clipRect.origin.y){
                    clipRect.origin.y = y;
                }else if(y > clipRect.size.height){
                    clipRect.size.height = y;
                }
            }
        }
    }

    clipRect.size.width -= clipRect.origin.x;
    clipRect.size.height -= clipRect.origin.y;
    if(clipRect.size.width > 0){
        clipRect.size.width++;
    }
    if(clipRect.size.height > 0){
        clipRect.size.height++;
    }

    return clipRect;
}

- (NSImage *)imageClippedToPixelBounds{
    NSRect clipRect = [self rectOfPixelBounds];
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
