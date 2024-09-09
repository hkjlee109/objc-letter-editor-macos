#import "LetterEditorTextField.h"

@implementation LetterEditorTextField

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (BOOL)becomeFirstResponder {
    if([super becomeFirstResponder]) {
        NSTextView* textField = (NSTextView*)[self currentEditor];
        if([textField respondsToSelector: @selector(setInsertionPointColor:)]) {
            [textField setInsertionPointColor: [NSColor clearColor]];
        }
        return YES;
    }
    return NO;
}


- (void)keyDown:(NSEvent *)event {
    [super keyDown:event];
    NSLog(@"keyDown");
}

@end
