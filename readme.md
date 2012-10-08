KGPixelBoundsClip is an `NSImage` and `UIImage` category that provides methods to find the pixel bounds of an image and create a new image clipped to those bounds.

There are two sets of methods, the first returns the pixel bounds of an image as a rect. The second uses these methods to create a new image clipped to the pixel bounds.

A tolerance can be specified, this value defines how transparent a pixel can be before it is clipped. The default is 0.

# Category Interface

``` obj-c
- (CGRect)rectOfPixelBounds;
- (CGRect)rectOfPixelBoundsWithTolerance:(CGFloat)tolerance;

- (UI/NSImage *)imageClippedToPixelBounds;
- (UI/NSImage *)imageClippedToPixelBoundsWithTolerance:(CGFloat)tolerance;
```

# Results

<img style="background-color:grey" src="https://raw.github.com/kgn/KGPixelBoundsClip/master/TestProject/shape@2x.png" />

<img style="background-color:grey" src="https://raw.github.com/kgn/KGPixelBoundsClip/master/TestProject/shape@2x_clipped.png" />

# Testing

The test project contains a very useful command line tool that can be used to clip an image, and an example iPhone app that displays the clipped image.


The times listed below are the amount of time it took to find the pixel bounds of the test images. This list is maintained here to track the speed as the algorithm progressed and to make sure that the found bounds is correct.

```
'shape@2x.png' cliprect found in 0.020373 seconds: {81.000000, 85.000000, 388.000000, 314.000000}
'empty.png' cliprect found in 0.039311 seconds: {0.000000, 0.000000, 0.000000, 0.000000}
'button.png' cliprect found in 0.006170 seconds: {0.000000, 19.000000, 512.000000, 485.000000}
'rose.png' cliprect found in 0.012595 seconds: {0.000000, 0.000000, 512.000000, 512.000000}
'small.png' cliprect found in 0.000176 seconds: {1.000000, 1.000000, 3.000000, 3.000000}
```