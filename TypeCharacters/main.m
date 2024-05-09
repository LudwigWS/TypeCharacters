//
//  main.m
//  TypeCharacters
//
//  Created by Matthew Davis on 2/10/20.
//
//  LINK: https://apple.stackexchange.com/questions/288536/is-it-possible-to-keystroke-special-characters-in-applescript/289046#289046

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Carbon/Carbon.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc > 1) {
            NSString *theString = [NSString stringWithUTF8String:argv[1]];
            NSUInteger len = [theString length];
            NSUInteger n, i = 0;
            CGEventRef keyEvent = CGEventCreateKeyboardEvent(nil, 0, true);
            unichar uChars[20];
            while (i < len) {
                n = i + 20;
                if (n>len){n=len;}
                [theString getCharacters:uChars range:NSMakeRange(i, n-i)];
                CGEventKeyboardSetUnicodeString(keyEvent, n-i, uChars);
                CGEventPost(kCGHIDEventTap, keyEvent); // key down
                CGEventSetType(keyEvent, kCGEventKeyUp);
                CGEventPost(kCGHIDEventTap, keyEvent); // key up (type 20 characters maximum)
                CGEventSetType(keyEvent, kCGEventKeyDown);
                i = n;
                [NSThread sleepForTimeInterval:0.004]; // wait 4/1000 of second, 0.002 it's OK on my computer, I use 0.004 to be safe, increase it If you still have issues
            }
            CFRelease(keyEvent);
        } else {
            @autoreleasepool {
                    char buffer[1024]; // A buffer to store input lines
                    while (fgets(buffer, sizeof(buffer), stdin)) {
                        NSString *lineString = [NSString stringWithUTF8String:buffer];
                        lineString = [lineString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]; // Trim newlines

                        CGEventSourceRef source = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
                        for (int i = 0; i < [lineString length]; i++) {
                            UniChar c = [lineString characterAtIndex:i];
                            CGEventRef keyDown = CGEventCreateKeyboardEvent(source, 0, true);
                            CGEventRef keyUp = CGEventCreateKeyboardEvent(source, 0, false);
                            CGEventKeyboardSetUnicodeString(keyDown, 1, &c);
                            CGEventKeyboardSetUnicodeString(keyUp, 1, &c);
                            CGEventPost(kCGHIDEventTap, keyDown);
                            CGEventPost(kCGHIDEventTap, keyUp);
                            CFRelease(keyDown);
                            CFRelease(keyUp);
                            [NSThread sleepForTimeInterval:0.004];
                        }
                        // After each line, send an enter key event to simulate the end of the line
                        UniChar enter = '\n';
                        CGEventRef keyDownEnter = CGEventCreateKeyboardEvent(source, kVK_Return, true);
                        CGEventRef keyUpEnter = CGEventCreateKeyboardEvent(source, kVK_Return, false);
                        CGEventKeyboardSetUnicodeString(keyDownEnter, 1, &enter);
                        CGEventKeyboardSetUnicodeString(keyUpEnter, 1, &enter);
                        CGEventPost(kCGHIDEventTap, keyDownEnter);
                        CGEventPost(kCGHIDEventTap, keyUpEnter);
                        CFRelease(keyDownEnter);
                        CFRelease(keyUpEnter);

                        [NSThread sleepForTimeInterval:0.004];
                        CFRelease(source);
                    }
                }
                return 0;
            
        }
    }
    return 0;
}


// Alternative Implementatoin
//#import <Foundation/Foundation.h>
//int main(int argc, const char * argv[]) {
//    @autoreleasepool {
//        if (argc > 1) {
//            NSString *theString = [NSString stringWithUTF8String:argv[1]];
//            UniChar uChar;
//            CGEventRef keyEvent = CGEventCreateKeyboardEvent(nil, 0, true);
//            for (int i = 0; i < [theString length]; i++)
//            {
//                uChar = [theString characterAtIndex:i];
//                CGEventKeyboardSetUnicodeString(keyEvent, 1, &uChar);
//                CGEventPost(kCGHIDEventTap, keyEvent); // key down
//                CGEventSetType(keyEvent, kCGEventKeyUp);
//                CGEventPost(kCGHIDEventTap, keyEvent); // key up (type the character)
//                CGEventSetType(keyEvent, kCGEventKeyDown);
//                [NSThread sleepForTimeInterval:0.001]; // wait 1/1000 of second, no need of this line on my computer, I use 0.001 to be safe, increase it If you still have issues
//            }
//            CFRelease(keyEvent);
//        }
//    }
//    return 0;
//}
