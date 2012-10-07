//
//  KGPixelBoundsClip.h
//  KGPixelBoundsClip
//
//  Created by David Keegan on 10/6/12.
//  Copyright (c) 2012 David Keegan. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE

#import <UIKit/UIKit.h>

@interface UIImage(KGPixelBoundsClip)

- (CGRect)rectOfPixelBounds;
- (CGRect)rectOfPixelBoundsWithTolerance:(CGFloat)tolerance;

- (UIImage *)imageClippedToPixelBounds;
- (UIImage *)imageClippedToPixelBoundsWithTolerance:(CGFloat)tolerance;

@end

#else

#import <AppKit/AppKit.h>

@interface NSImage(KGPixelBoundsClip)

- (NSRect)rectOfPixelBounds;
- (NSRect)rectOfPixelBoundsWithTolerance:(CGFloat)tolerance;

- (NSImage *)imageClippedToPixelBounds;
- (NSImage *)imageClippedToPixelBoundsWithTolerance:(CGFloat)tolerance;

@end

#endif