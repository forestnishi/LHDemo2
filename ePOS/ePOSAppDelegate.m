//
//  ePOSAppDelegate.m
//  ePOS
//
//  Created by komatsu on 2014/06/13.
//  Copyright (c) 2014年 iWare. All rights reserved.
//

#import "ePOSAppDelegate.h"
#import "ePosSkinManager.h"
#import "ePOSUserDefault.h"
#import "ePOSAgent.h"
#import "ePOSViewController.h"

@implementation ePOSAppDelegate
{
    UIBackgroundTaskIdentifier _bgTask;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setDefaultParam];
    
    ePOSSkinManager *skinManager = [ePOSSkinManager sharedSkinManager];
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    skinManager.skinType = [[def objectForKey:ePOSDefaultSkinTypeKey] integerValue];
    skinManager.language = [[def objectForKey:ePOSDefaultLanguageKey] integerValue];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    UIApplication*	app = [UIApplication sharedApplication];
	NSAssert(_bgTask == UIBackgroundTaskInvalid, nil);
	
	_bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
		dispatch_async(dispatch_get_main_queue(), ^{
			if (_bgTask != UIBackgroundTaskInvalid) {
				[app endBackgroundTask:_bgTask];
				_bgTask = UIBackgroundTaskInvalid;
			}
		});
	}];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		
        __block NSTimeInterval interval = 60. * 1.;
        NSDate *startDate = [NSDate date];
		while(_bgTask != UIBackgroundTaskInvalid) {
            @autoreleasepool {
                [NSThread sleepForTimeInterval:2.];
                if ( [[NSDate date] timeIntervalSinceDate:startDate] > interval ) {
                    interval = 60. * 60.;
                    DEBUG_LOG(@"Timeout message");
                    [self disconnect];
                }
            }
		}
        

		dispatch_async(dispatch_get_main_queue(), ^{
			if (_bgTask != UIBackgroundTaskInvalid) {
                DEBUG_LOG(@"End background ----------------------------");
                ePOSAgent *agent = [ePOSAgent sharedAgent];
                [agent disconnectCompletion:nil];

				[app endBackgroundTask:_bgTask];
				_bgTask = UIBackgroundTaskInvalid;
				
			}
		});
	});
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    UIApplication*	app = [UIApplication sharedApplication];
	if (_bgTask != UIBackgroundTaskInvalid) {
		[app endBackgroundTask:_bgTask];
		_bgTask = UIBackgroundTaskInvalid;
	}
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self disconnect];
}

#pragma mark - private
- (void)setDefaultParam
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *ipAddress = [def objectForKey:ePOSDefaultIPAddressKey];
    if(ipAddress.length == 0) {
        ipAddress = @"TCP:192.168.12.135";
        [def setObject:ipAddress forKey:ePOSDefaultIPAddressKey];
    }
    NSString *printerID = [def objectForKey:ePOSDefaultPrinterIDKey];
    if(printerID.length == 0) {
        printerID = @"local_printer";
        [def setObject:printerID forKey:ePOSDefaultPrinterIDKey];
    }
    NSString *displayID = [def objectForKey:ePOSDefaultDisplayIDKey];
    if(displayID.length == 0) {
        displayID = @"local_display";
        [def setObject:displayID forKey:ePOSDefaultDisplayIDKey];
    }
    NSString *scannerID = [def objectForKey:ePOSDefaultScannerIDKey];
    if(scannerID.length == 0) {
        scannerID = @"local_scanner";
        [def setObject:scannerID forKey:ePOSDefaultScannerIDKey];
    }
    NSNumber *num = [def objectForKey:ePOSDefaultSkinTypeKey];
    if(num == nil) {
        [def setObject:@(ePOSSkinTypeBlack) forKey:ePOSDefaultSkinTypeKey];
    }
    num = [def objectForKey:ePOSDefaultLanguageKey];
    if(num == nil) {
        [def setObject:@(ePOSLanguageEnglish) forKey:ePOSDefaultLanguageKey];
    }
    
    num = [def objectForKey:ePOSDefaultValidPrinterKey];
    if(num == nil) {
        [def setObject:@(YES) forKey:ePOSDefaultValidPrinterKey];
    }
    num = [def objectForKey:ePOSDefaultValidScannerKey];
    if(num == nil) {
        [def setObject:@(YES) forKey:ePOSDefaultValidScannerKey];
    }
    num = [def objectForKey:ePOSDefaultValidDisplayKey];
    if(num == nil) {
        [def setObject:@(YES) forKey:ePOSDefaultValidDisplayKey];
    }
    num = [def objectForKey:ePOSDefaultValidKeyboardKey];
    if(num == nil) {
        [def setObject:@(NO) forKey:ePOSDefaultValidKeyboardKey];
    }

    num = [def objectForKey:ePOSDefaultPaperWidthKey];
    if(num == nil) {
        [def setObject:@(80) forKey:ePOSDefaultPaperWidthKey];
    }
    
    num = [def objectForKey:ePOSDefaultPrintColumnKey];
    if(num == nil) {
        [def setObject:@(42) forKey:ePOSDefaultPrintColumnKey];
    }
    
    [self copyPreset];
}

- (void)disconnect
{
    ePOSViewController *controller = (ePOSViewController *)self.window.rootViewController;
    [controller disconnect];

}


- (void)copyPreset
{
    NSArray *documentPathList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = documentPathList.lastObject;
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *presetPath = [documentPath stringByAppendingPathComponent:@"Preset.plist"];
    if(![fileManager fileExistsAtPath:presetPath]) {
        NSString *oritinalPath = [[NSBundle mainBundle] pathForResource:@"Preset" ofType:@"plist"];

        NSError *error;
        [fileManager copyItemAtPath:oritinalPath toPath:presetPath error:&error];
    }
}



@end
