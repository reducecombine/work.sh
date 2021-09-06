// https://raw.githubusercontent.com/alt-jero/McSpaces/master/spaceID.m

// Detect UUID of currently visible Mission Control Space
// Platform: MacOS High Sierra (Others: YMMV)
// Language: Objective C
// To Compile:
// gcc -o spaceID spaceID.m -framework Foundation -framework Carbon

// Why is one Import and one Include? I have no idea, but it works.
#import <Foundation/Foundation.h>
#include <Carbon/Carbon.h>

// So this is where we do the header stuff. Added value?
// Compiler knows that that our interface is an NSObject.
// Really? That's all this does? Seems that way...
@interface SpacesTool : NSObject
+ (NSString *)activeSpaceIdentifier;
@end

// Tell them what you're about to tell them...
// Then tell 'em what you've got to say...
// Then tell them what you just told them...
@implementation SpacesTool
// Here I learned about classes...
// http://blog.teamtreehouse.com/beginners-guide-objective-c-classes-objects

// This method is adapted from an article by https://github.com/ianyh
// Article: http://ianyh.com/blog/identifying-spaces-in-mac-os-x/
// Adaptation: defaults read com.apple.spaces says it should be:
// dictionaryForKey:@"SpacesDisplayConfiguration" but in previous versions
// of macOS it was probably "SpacesConfiguration".
+ (NSString *)activeSpaceIdentifier {
  [[NSUserDefaults standardUserDefaults] removeSuiteNamed:@"com.apple.spaces"];
  [[NSUserDefaults standardUserDefaults] addSuiteNamed:@"com.apple.spaces"];

  NSArray *spaceProperties = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"SpacesDisplayConfiguration"][@"Space Properties"];
  NSMutableDictionary *spaceIdentifiersByWindowNumber = [NSMutableDictionary dictionary];

  for (NSDictionary *spaceDictionary in spaceProperties) {
    NSArray *windows = spaceDictionary[@"windows"];
    for (NSNumber *window in windows) {
      if (spaceIdentifiersByWindowNumber[window]) {
        spaceIdentifiersByWindowNumber[window] = [spaceIdentifiersByWindowNumber[window] arrayByAddingObject:spaceDictionary[@"name"]];
      } else {
        spaceIdentifiersByWindowNumber[window] = @[ spaceDictionary[@"name"] ];
      }
    }
  }

  CFArrayRef windowDescriptions = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
  NSString *activeSpaceIdentifier = nil;

  for (NSDictionary *dictionary in (__bridge NSArray *)windowDescriptions) {
    NSNumber *windowNumber = dictionary[(__bridge NSString *)kCGWindowNumber];
    NSArray *spaceIdentifiers = spaceIdentifiersByWindowNumber[windowNumber];
    //printf ("%u\n", (int) spaceIdentifiers.count);
    //for (NSString *s in spaceIdentifiers) {
    //  printf("vemv %s vemv\n", [s UTF8String]);
    //}
    if (spaceIdentifiers.count == 1) {
      activeSpaceIdentifier = spaceIdentifiers[0];
    }
  }

  CFRelease(windowDescriptions);

  return activeSpaceIdentifier;
}

// End Implementation
@end

// Adapted from: http://www.informit.com/articles/article.aspx?p=1315356
int main (int argc, const char * argv[])
{
  // Why this? SWIM is apparently smarter than me...
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

  // Here I figured out how NSLog works with the %@ thing to display whatever :D
  // https://stackoverflow.com/questions/8705303/dereferencing-a-pointer-in-objective-c
  //NSLog (@"%@", [SpacesTool activeSpaceIdentifier]);
  // https://stackoverflow.com/questions/3487226/is-it-possible-to-nslog-without-the-time-and-date-stamps-and-the-automatic-ne
  printf ("XXX%sXXX\n", [[SpacesTool activeSpaceIdentifier] UTF8String]);


  // To get rid of the dirt!
  [pool drain];

  // Exit code! :D
  return 0;
}
