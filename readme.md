KGPixelBoundsClip is an `NSImage` category that provides methods to find the pixel bounds of an image and create a new image clipped to those bounds.

There are two sets of methods, the first returns the pixel bounds of an image as a rect. The second uses these methods to create a new image clipped to the pixel bounds.

A tolerance can be specified, this value defines how transparent a pixel can be before it is clipped. The default is 0.

``` obj-c
- (NSRect)rectOfPixelBounds;
- (NSRect)rectOfPixelBoundsWithTolerance:(CGFloat)tolerance;

- (NSImage *)imageClippedToPixelBounds;
- (NSImage *)imageClippedToPixelBoundsWithTolerance:(CGFloat)tolerance;
```

The times listed below are the amount of time it took to find the pixel bounds of the test images. This list is maintained here to track the speed as the algorithm progressed and to make sure that the found bounds is correct.

```
'shape.png' cliprect found in 0.255439 seconds: {81.000000, 85.000000, 388.000000, 314.000000}
'empty.png' cliprect found in 0.343827 seconds: {0.000000, 0.000000, 0.000000, 0.000000}
'button.png' cliprect found in 0.035322 seconds: {0.000000, 19.000000, 512.000000, 485.000000}
'rose.png' cliprect found in 0.014576 seconds: {0.000000, 0.000000, 512.000000, 512.000000}
```

The test project is also a very useful command line tool that can be used to clip an image.