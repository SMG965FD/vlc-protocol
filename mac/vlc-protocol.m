// https://www.cocoawithlove.com/2010/09/minimalist-cocoa-programming.html
#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
@end

@implementation AppDelegate

- (void)handleAppleEvent:(NSAppleEventDescriptor *)event withReplyEvent: (NSAppleEventDescriptor *)replyEvent {
  // Get input data
  NSString *input = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
  NSString *url;
  if ([input hasPrefix:@"vlc://"]) {
    url = [input substringFromIndex:6];
  }
  else if ([input hasPrefix:@"vlc:"]) {
    url = [input substringFromIndex:4];
  }
  else {
    // invalid input
    [NSApp terminate:nil];
    return;
  }

  // Only allow urls starting with http:// or https://
  if (![url hasPrefix:@"http://"] && ![url hasPrefix:@"https://"]) {
    // protocol not allowed
    [NSApp terminate:nil];
    return;
  }

  // Launch VLC
  NSWorkspace *ws = [NSWorkspace sharedWorkspace];
  NSURL *app = [NSURL fileURLWithPath:@"/Applications/VLC.app"];
  NSArray *arguments = [NSArray arrayWithObjects: @"--open", url, nil];
  NSWorkspaceOpenConfiguration *config = [NSWorkspaceOpenConfiguration alloc];
  [config setArguments:arguments];
  [config setCreatesNewApplicationInstance:YES];
  [ws openApplicationAtURL:app configuration:config completionHandler:^(NSRunningApplication* app, NSError* error) {
    if (error) {
      NSLog(@"Failed to open VLC: %@", error.localizedDescription);
    }
    exit(1);
  }];
  [NSThread sleepForTimeInterval: 10];

  // Close this program
  [NSApp terminate:nil];
}

@end

int main() {
  // Make sure the shared application is created
  [NSApplication sharedApplication];

  AppDelegate *appDelegate = [AppDelegate new];
  NSAppleEventManager *sharedAppleEventManager = [NSAppleEventManager new];
  [sharedAppleEventManager setEventHandler:appDelegate
                               andSelector:@selector(handleAppleEvent:withReplyEvent:)
                             forEventClass:kInternetEventClass
                                andEventID:kAEGetURL];

  [NSApp run];
  return 0;
}
