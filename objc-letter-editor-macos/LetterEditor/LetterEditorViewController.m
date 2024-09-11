#import <Carbon/Carbon.h>
#import "LetterEditorViewController.h"

@interface LetterEditorViewController () <NSTextFieldDelegate>

@end

@implementation LetterEditorViewController {
    id _eventMonitor;
    NSString* _charToSend;
    NSSet* _editHelperKeys;
    NSSet* _terminateKeys;
    NSUInteger _currentLength;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _editHelperKeys = [NSSet setWithObjects:@(kVK_Return),
                       @(kVK_Delete),
                       @(kVK_Escape),
                       @(kVK_LeftArrow),
                       @(kVK_RightArrow),
                       @(kVK_DownArrow),
                       @(kVK_UpArrow),
                       nil];
    
    _terminateKeys = [NSSet setWithObjects:@(kVK_Return),
                                           @(kVK_Escape),
                                           @(kVK_LeftArrow),
                                           @(kVK_RightArrow),
                                           @(kVK_DownArrow),
                                           @(kVK_UpArrow),
                                           @(kVK_F1),
                                           @(kVK_F2),
                                           @(kVK_F3),
                                           @(kVK_F4),
                                           @(kVK_F5),
                       nil];
    
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

- (void)dealloc {
    if(_eventMonitor) {
        [NSEvent removeMonitor:_eventMonitor];
        _eventMonitor = nil;
    }
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
    
    if(_eventMonitor) {
        return;
    }
    
    if(self.textField.currentEditor == nil) {
        [self.textField becomeFirstResponder];
    }
    
    __weak LetterEditorViewController *wself = self;
    _eventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyDown | NSEventMaskKeyUp | NSEventMaskFlagsChanged handler:^NSEvent *(NSEvent *event) {
        
        LetterEditorViewController* sself = wself;
        if(!sself) return event;
        
        if([sself->_terminateKeys containsObject:@(event.keyCode)]) {
            [sself endEditorIfNeeded];
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
}

- (void)deactivate {
    if(_eventMonitor) {
        [NSEvent removeMonitor:_eventMonitor];
        _eventMonitor = nil;
    }
    
    self.view.alphaValue = 0;
    [self.textField resignFirstResponder];
}

- (BOOL)isEditing {
    return (_currentLength != [_textField.stringValue length]);
}

- (void)transmitCharacter {
    NSString* c = [_textField.stringValue substringFromIndex:[_textField.stringValue length] - 1];
    NSLog(@"# %@: Send this: %@", _textField.stringValue, c);
}

- (void)forwardEvent:(NSEvent*)event{
    NSLog(@"# Forwarding event 0x%02x %d", event.keyCode, event.type);
}

- (void)startEditor {
    NSLog(@"# startEditor");
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


- (void)controlTextDidChange:(NSNotification *)obj {
    NSLog(@"# controlTextDidChange: %lu", (unsigned long)_textField.stringValue.length);

    // When the string got shorter. eg. by backspace key.
    if(_textField.stringValue.length < _currentLength) {
        [self endEditor];
    }
    
    _currentLength = _textField.stringValue.length;
    
    if(_textField.stringValue.length > 0) {
        [self transmitCharacter];
        
        // Some character ends editing. eg. 한!
        dispatch_async(dispatch_get_main_queue(), ^{
            if(![self isEditing]) {
                [self endEditor];
            }
        });
    }
}

@end
