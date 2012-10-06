//
//  main.m
//  KGPixelBoundsClip
//
//  Created by David Keegan on 10/5/12.
//  Copyright (c) 2012 David Keegan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSImage+PixelBoundsClip.h"

int main(int argc, const char * argv[]){
    @autoreleasepool{
        NSString *imagePath = @"/Users/dkeegan/Desktop/KGPixelBoundsClip/shape.png";
        NSImage *image = [[NSImage alloc] initWithContentsOfFile:imagePath];

        NSDate *now = [NSDate date];
        NSImage *clippedImage = [image imageClippedToPixelBounds];
        NSTimeInterval secondsBetween = [[NSDate date] timeIntervalSinceDate:now];
        NSLog(@"Converted in %f seconds", secondsBetween);

        NSData *imageData = [clippedImage TIFFRepresentation];
        NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
        imageData = [imageRep representationUsingType:NSPNGFileType properties:nil];
        [imageData writeToFile:@"/Users/dkeegan/Desktop/KGPixelBoundsClip/shape_clipped.png" atomically:NO];
    }
    return 0;
}

