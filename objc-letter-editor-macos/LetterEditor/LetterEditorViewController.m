#import <Carbon/Carbon.h>
#import "LetterEditorViewController.h"

@interface LetterEditorViewController () <NSTextFieldDelegate>

@end

@implementation LetterEditorViewController {
    id _eventMonitor;
    NSString* _charToSend;
    NSSet* _keysToBypass;
    NSUInteger _currentLength;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _keysToBypass = [NSSet setWithObjects:@(kVK_Return),
                                          @(kVK_Space),
                                          @(kVK_Delete),
                                          @(kVK_Escape),
                                          @(kVK_Return),
                     nil];
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.view.wantsLayer = true;
    self.view.layer.cornerRadius = 25;
    self.view.layer.masksToBounds = YES;
//    self.view.layer.backgroundColor = [[NSColor colorWithCalibratedRed:68.0/255 green:68.0/255 blue:68.0/255 alpha:0.9] CGColor];
        self.view.layer.backgroundColor = [[NSColor colorWithCalibratedRed:239.0/255 green:66.0/255 blue:58.0/255 alpha:0.9] CGColor];
    
    _textField = [[LetterEditorTextField alloc] initWithFrame:CGRectZero];
    _textField.translatesAutoresizingMaskIntoConstraints = NO;
    _textField.delegate = self;
    _textField.bezeled = NO;
    _textField.editable = YES;
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
        
        // Should fire _keysToBypass at the end.
        
//        NSLog(@"# LetterEditorViewController monitor: %lu", (unsigned long)self->_textField.stringValue.length);
        
//        if(self->_textField.stringValue.length == 0) {
//            if([sself->_keysToBypass containsObject:@(event.keyCode)]) {
//                NSLog(@"# flush send this keycode to remote.");
//                
//                self.view.hidden = YES;
//                return nil;
//            }
//        }
           
//        if(event.type == NSEventTypeKeyDown) {
            sself.view.hidden = NO;
            if(sself.textField.currentEditor == nil) {
                [sself.textField becomeFirstResponder];
            }
            
            return event;
//        }
        
        return event;
        //            if(event.type == NSEventTypeKeyDown) {
        //                sself->_letterEditorViewController.view.hidden = NO;
        //
        //                if(sself->_letterEditorViewController.textField.currentEditor == nil) {
        //                    [sself->_letterEditorViewController.textField becomeFirstResponder];
        //                }
        //
        //                return event;
        //            }
        
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
        NSLog(@"Deleting...!");
        _textField.stringValue = @"";
    }
    
    _currentLength = _textField.stringValue.length;
    
    if(_textField.stringValue.length > 0) {
        _charToSend = [NSString stringWithFormat:@"%X", [_textField.stringValue characterAtIndex:[_textField.stringValue length] - 1]];
        NSLog(@"# %@", _textField.stringValue);
//        _textField.stringValue = @"";
        
//        unichar unichar = [_textField.stringValue characterAtIndex:[_textField.stringValue length] - 1];
//        
//        NSLog(@"## %C", unichar);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"# current length: %d", _textField.stringValue.length);
            
            if(self->_currentLength == self->_textField.stringValue.length) {
                self->_textField.stringValue = @"";
                self->_currentLength = 0;
            }
        });
        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSLog(@"# Length later. %d", [_textField.stringValue length]);
//            if(self->_textField.stringValue.length == 0) {
////                self.view.hidden = YES;
////                return;
//            }
//            
//            NSLog(@"# Finalize. %@", self->_charToSend);
//        });
    }
}

@end
