//
//  main.m
//  KGPixelBoundsClip
//
//  Created by David Keegan on 10/5/12.
//  Copyright (c) 2012 David Keegan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KGPixelBoundsClip.h"

int main(int argc, const char * argv[]){
    @autoreleasepool{
        NSArray *arguments = [[NSProcessInfo processInfo] arguments];
        [arguments enumerateObjectsUsingBlock:^(NSString *imagePath, NSUInteger idx, BOOL *stop){
            if(idx == 0){
                return;
            }
            
            NSImage *image = [[NSImage alloc] initWithContentsOfFile:imagePath];

            NSDate *now = [NSDate date];
            NSRect clipRect = [image rectOfPixelBounds];
            NSTimeInterval secondsBetween = [[NSDate date] timeIntervalSinceDate:now];
            NSLog(@"'%@' cliprect found in %f seconds: {%f, %f, %f, %f}",
                  [imagePath lastPathComponent], secondsBetween,
                  clipRect.origin.x, clipRect.origin.y, clipRect.size.width, clipRect.size.height);

            NSString *outputImagePath = [NSString stringWithFormat:@"%@_clipped.png",[imagePath stringByDeletingPathExtension]];
            [[NSFileManager defaultManager] removeItemAtPath:outputImagePath error:nil];
            NSImage *clippedImage = [image imageClippedToPixelBounds];
            if(clippedImage){
                NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:[clippedImage TIFFRepresentation]];
                NSData *imageData = [imageRep representationUsingType:NSPNGFileType properties:nil];
                [imageData writeToFile:outputImagePath atomically:NO];
            }else{
                NSLog(@"No data to write after clipping '%@'", [imagePath lastPathComponent]);
            }
        }];
    }
    return 0;
}

