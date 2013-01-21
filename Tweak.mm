#import <notify.h>
#import <UIKit/UIKit.h>
#import <libactivator/libactivator.h>

#define kActivatorAction "jp.r-plus.actdescription"

static BOOL isActive = NO;

@interface UIView(Private)
- (id)recursiveDescription;
@end

@interface ActDescription : NSObject <LAListener>
@end

static void PrintDescription(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
  NSLog(@"%@", [[UIApplication sharedApplication].keyWindow recursiveDescription]);
}

static void WillEnterForegroundNotificationReceived(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
  if (!isActive) {
    isActive = YES;
    CFNotificationCenterRef darwin = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterAddObserver(darwin, NULL, PrintDescription, CFSTR(kActivatorAction), NULL, CFNotificationSuspensionBehaviorCoalesce);
  }
}

static void DidEnterBackgroundNotificationReceived(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
  if (isActive) {
    isActive = NO;
    CFNotificationCenterRef darwin = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterRemoveObserver(darwin, (const void *)PrintDescription, CFSTR(kActivatorAction), NULL);
  }
}

@implementation ActDescription
+ (void)load
{
  @autoreleasepool {
    if (LASharedActivator.runningInsideSpringBoard) {
      ActDescription *listener = [[ActDescription alloc] init];
      [LASharedActivator registerListener:listener forName:@kActivatorAction];
    } else {
      CFNotificationCenterRef local = CFNotificationCenterGetLocalCenter();
      CFNotificationCenterAddObserver(local, NULL, WillEnterForegroundNotificationReceived, (CFStringRef)UIApplicationDidFinishLaunchingNotification, NULL, CFNotificationSuspensionBehaviorCoalesce);
      CFNotificationCenterAddObserver(local, NULL, WillEnterForegroundNotificationReceived, (CFStringRef)UIApplicationWillEnterForegroundNotification, NULL, CFNotificationSuspensionBehaviorCoalesce);
      CFNotificationCenterAddObserver(local, NULL, DidEnterBackgroundNotificationReceived, (CFStringRef)UIApplicationDidEnterBackgroundNotification, NULL, CFNotificationSuspensionBehaviorCoalesce);
    }
  }
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event forListenerName:(NSString *)listenerName
{
  if ([listenerName isEqualToString:@kActivatorAction]) {
    notify_post(kActivatorAction);
    event.handled = YES;
  }
}
@end
