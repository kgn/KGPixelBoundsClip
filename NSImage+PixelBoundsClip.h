//
//  NSImage+PixelBoundsClip.h
//  KGPixelBoundsClip
//
//  Created by David Keegan on 10/5/12.
//  Copyright (c) 2012 David Keegan. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface NSImage(PixelBoundsClip)

- (NSRect)rectOfPixelBounds;
- (NSImage *)imageClippedToPixelBounds;

@end
