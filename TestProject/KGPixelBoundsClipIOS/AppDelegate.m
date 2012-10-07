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

    UIImage *image = [UIImage imageNamed:@"shape"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[image imageClippedToPixelBounds]];
    imageView.backgroundColor = [UIColor redColor];
    [viewController.view addSubview:imageView];
    
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
