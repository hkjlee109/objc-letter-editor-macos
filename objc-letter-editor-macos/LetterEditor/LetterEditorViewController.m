#import <Carbon/Carbon.h>
#import "LetterEditorViewController.h"

@interface LetterEditorViewController () <NSTextFieldDelegate>

@end

@implementation LetterEditorViewController {
    NSSet* _breakKeys;
    NSSet* _conditionalBreakKeys;
    NSSet* _characterKeys;
    NSUInteger _currentLength;
}

NSArray* characterKeyCodes = @[
    @(kVK_ANSI_Grave),
    @(kVK_ANSI_1),
    @(kVK_ANSI_2),
    @(kVK_ANSI_3),
    @(kVK_ANSI_4),
    @(kVK_ANSI_5),
    @(kVK_ANSI_6),
    @(kVK_ANSI_7),
    @(kVK_ANSI_8),
    @(kVK_ANSI_9),
    @(kVK_ANSI_0),
    @(kVK_ANSI_Minus),
    @(kVK_ANSI_Equal),
    
    @(kVK_ANSI_Q),
    @(kVK_ANSI_W),
    @(kVK_ANSI_E),
    @(kVK_ANSI_R),
    @(kVK_ANSI_T),
    @(kVK_ANSI_Y),
    @(kVK_ANSI_U),
    @(kVK_ANSI_I),
    @(kVK_ANSI_O),
    @(kVK_ANSI_P),
    @(kVK_ANSI_LeftBracket),
    @(kVK_ANSI_RightBracket),
    @(kVK_ANSI_Backslash),
    
    @(kVK_ANSI_A),
    @(kVK_ANSI_S),
    @(kVK_ANSI_D),
    @(kVK_ANSI_F),
    @(kVK_ANSI_G),
    @(kVK_ANSI_H),
    @(kVK_ANSI_J),
    @(kVK_ANSI_K),
    @(kVK_ANSI_L),
    @(kVK_ANSI_Semicolon),
    @(kVK_ANSI_Quote),

    @(kVK_ANSI_Z),
    @(kVK_ANSI_X),
    @(kVK_ANSI_C),
    @(kVK_ANSI_V),
    @(kVK_ANSI_B),
    @(kVK_ANSI_N),
    @(kVK_ANSI_M),
    @(kVK_ANSI_Comma),
    @(kVK_ANSI_Period),
    @(kVK_ANSI_Slash),
];

- (void)viewDidLoad {
    [super viewDidLoad];

    _breakKeys = [NSSet setWithObjects:
                  @(kVK_Return),
                  @(kVK_Escape),
//                  @(kVK_LeftArrow),
//                  @(kVK_RightArrow),
//                  @(kVK_DownArrow),
//                  @(kVK_UpArrow),
                  @(kVK_F1),
                  @(kVK_F2),
                  @(kVK_F3),
                  @(kVK_F4),
                  @(kVK_F5),
                  nil];
    
    _conditionalBreakKeys = [NSSet setWithObjects:@(kVK_Delete), nil];
    
    
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.view.wantsLayer = true;
    self.view.alphaValue = 0;
    self.view.layer.cornerRadius = 25;
    self.view.layer.masksToBounds = YES;
    self.view.layer.backgroundColor = [[NSColor colorWithCalibratedRed:239.0/255 green:66.0/255 blue:58.0/255 alpha:0.9] CGColor];
    
    _textField = [[LetterEditorTextField alloc] initWithFrame:CGRectZero];
    _textField.translatesAutoresizingMaskIntoConstraints = NO;
    _textField.delegate = self;
    _textField.bezeled = NO;
    _textField.editable = YES;
    _textField.maximumNumberOfLines = 1;
    _textField.focusRingType = NSFocusRingTypeNone;
    _textField.alignment = NSTextAlignmentCenter;
    _textField.backgroundColor = [NSColor clearColor];
    
    [self setupConstraints];
}

- (void)setupConstraints {
    [self.view addSubview:_textField];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.view.widthAnchor constraintEqualToConstant:50],
        [self.view.heightAnchor constraintEqualToConstant:50],
        [_textField.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [_textField.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [_textField.widthAnchor constraintEqualToConstant:20],
    ]];
}

- (void)activate {
    NSLog(@"# LetterEditorViewController activate");
    
    if(self.textField.currentEditor == nil) {
        [self.textField becomeFirstResponder];
    }
    
/*
    __weak LetterEditorViewController *wself = self;
    _eventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyDown | NSEventMaskKeyUp | NSEventMaskFlagsChanged handler:^NSEvent *(NSEvent *event) {
        
        LetterEditorViewController* sself = wself;
        if(!sself) return event;
        
        if([sself->_breakKeys containsObject:@(event.keyCode)]) {
            [sself endEditorIfNeeded];
            [sself forwardEvent:event];
            return nil;
        }
        
        if([sself->_conditionalBreakKeys containsObject:@(event.keyCode)] && ![sself isEditing]) {
            [sself forwardEvent:event];
            return nil;
        }
        
        if(event.type == NSEventTypeKeyDown) {
            // Delayed display to prevent flickering. eg. When number is entered from nothing.
            dispatch_async(dispatch_get_main_queue(), ^{
                [sself startEditor];
            });
        }
        
        return event;
    }];
 */
}

- (void)deactivate {
    self.view.alphaValue = 0;
    [self.textField resignFirstResponder];
}

- (NSEvent*)processEvent:(NSEvent*)event {
    if([self->_breakKeys containsObject:@(event.keyCode)]) {
        [self endEditorIfNeeded];
        [self forwardEvent:event];
        return nil;
    }
    
    if([self->_conditionalBreakKeys containsObject:@(event.keyCode)] && ![self isEditing]) {
        [self forwardEvent:event];
        return nil;
    }
    
    if(event.type == NSEventTypeKeyDown) {
        // Delayed display to prevent flickering. eg. When number is entered from nothing.
        dispatch_async(dispatch_get_main_queue(), ^{
            [self startEditor];
        });
    }
    
    return event;
}

- (BOOL)isEditing {
    return (_currentLength != [_textField.stringValue length]);
}

- (void)forwardEvent:(NSEvent*)event{
    NSLog(@"# Forwarding event 0x%02x %lu", event.keyCode, (unsigned long)event.type);
}

- (void)startEditor {
    self.view.alphaValue = 1;
}

- (void)endEditor {
    NSLog(@"# terminateEditor");
    self->_textField.stringValue = @"";
    self->_currentLength = 0;
    self.view.alphaValue = 0;
}

- (void)endEditorIfNeeded {
    if([self isEditing]) {
        [self endEditor];
    }
}

- (void)transmitString:(NSString*)string {
    NSLog(@"## %@ %d", string, [string length]);
    NSUInteger len = [string length];
    unichar unichars[len + 1];

    [string getCharacters:unichars range:NSMakeRange(0, len)];

    for(int i = 0; i < len; i++) {
        NSLog(@"# Transmit: %x", unichars[i]);
    }
}

- (void)controlTextDidChange:(NSNotification *)obj {
    NSLog(@"# controlTextDidChange: %lu", (unsigned long)_textField.stringValue.length);

    // When the string got shorter. eg. by backspace key.
    if(_textField.stringValue.length < _currentLength) {
        [self endEditor];
        return;
    }
    
    if(_textField.stringValue.length > 0) {
        [self transmitString:[_textField.stringValue substringFromIndex:_currentLength]];
        self->_textField.alphaValue = 0;
        
        // Some character ends editing. eg. 한!
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_textField.alphaValue = 1;
            if(![self isEditing]) {
                [self endEditor];
            }
        });
    }
    
    _currentLength = _textField.stringValue.length;
}

@end
