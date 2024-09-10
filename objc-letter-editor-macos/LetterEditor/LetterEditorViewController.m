#import <Carbon/Carbon.h>
#import "LetterEditorViewController.h"

@interface LetterEditorViewController () <NSTextFieldDelegate>

@end

@implementation LetterEditorViewController {
    id _eventMonitor;
    NSString* _charToSend;
    NSSet* _editHelperKeys;
    NSUInteger _currentLength;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _editHelperKeys = [NSSet setWithObjects:@(kVK_Return),
                                            @(kVK_Delete),
                                            @(kVK_Escape),
                                            @(kVK_Escape),
                                            @(kVK_LeftArrow),
                                            @(kVK_RightArrow),
                                            @(kVK_DownArrow),
                                            @(kVK_UpArrow),
                       nil];
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.view.wantsLayer = true;
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
    
    __weak LetterEditorViewController *wself = self;
    _eventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyDown | NSEventMaskKeyUp | NSEventMaskFlagsChanged handler:^NSEvent *(NSEvent *event) {
        
        LetterEditorViewController* sself = wself;
        if(!sself) return event;
        
        if(sself.view.hidden && [sself->_editHelperKeys containsObject:@(event.keyCode)]) {
            NSLog(@"No string.. Transmit helper key.");
            return nil;
        }
        
        if(event.type == NSEventTypeKeyDown) {
            sself.view.hidden = NO;
            if(sself.textField.currentEditor == nil) {
                [sself.textField becomeFirstResponder];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Transmit helper key.");
        });
        
        return event;
        
        return nil;
    }];
}

- (void)deactivate {
    if(_eventMonitor) {
        [NSEvent removeMonitor:_eventMonitor];
        _eventMonitor = nil;
    }
}

- (void)controlTextDidChange:(NSNotification *)obj {
    NSLog(@"# controlTextDidChange: %d", _textField.stringValue.length);

    if(_textField.stringValue.length < _currentLength) {
        _textField.stringValue = @"";
        self.view.hidden = YES;
    }
    
    _currentLength = _textField.stringValue.length;
    
    if(_textField.stringValue.length > 0) {
//        _charToSend = [NSString stringWithFormat:@"%hu", [_textField.stringValue characterAtIndex:[_textField.stringValue length] - 1]];
//        NSLog(@"# %@, _charToSend: %@", _textField.stringValue, _charToSend);
  
        NSString* lastChar = [_textField.stringValue substringFromIndex:[_textField.stringValue length] - 1];
        NSLog(@"# %@: Send this: %@", _textField.stringValue, lastChar);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self->_currentLength == self->_textField.stringValue.length) {
                self->_textField.stringValue = @"";
                self.view.hidden = YES;
                self->_currentLength = 0;
            }
        });
    }
}

@end
