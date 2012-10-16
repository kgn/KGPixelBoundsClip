//
//  AppDelegate.m
//  KGPixelBoundsClipIOS
//
//  Created by David Keegan on 10/6/12.
//  Copyright (c) 2012 David Keegan. All rights reserved.
//

#import "AppDelegate.h"
#import "KGPixelBoundsClip.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.view.backgroundColor = [UIColor whiteColor];

    UIImage *image = [UIImage imageNamed:@"dial"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[image imageClippedToPixelBounds]];
    imageView.backgroundColor = [UIColor redColor];
    [viewController.view addSubview:imageView];

    UIImage *image2 = [UIImage imageNamed:@"shape"];
    UIImageView *imageView2 = [[UIImageView alloc] initWithImage:[image2 imageClippedToPixelBounds]];
    imageView2.frame = (CGRect){imageView2.frame.origin.x, CGRectGetMaxY(imageView.frame), imageView2.frame.size};
    imageView2.backgroundColor = [UIColor redColor];
    [viewController.view addSubview:imageView2];
    
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
