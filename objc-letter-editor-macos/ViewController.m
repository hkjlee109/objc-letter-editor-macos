#import <Carbon/Carbon.h>
#import "ViewController.h"

#import "LetterEditorViewController.h"

@implementation ViewController {
    id _eventMonitor;
    NSString* _currentKeyboardId;
    
    LetterEditorViewController* _letterEditorViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(keyboardSelectionDidChange:)
               name:NSTextInputContextKeyboardSelectionDidChangeNotification
             object:nil
    ];
    
    __weak ViewController *wself = self;
    _eventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyDown | NSEventMaskKeyUp | NSEventMaskFlagsChanged handler:^NSEvent *(NSEvent *event) {
        
        ViewController* sself = wself;
        if(!sself) return event;
        
        if([sself->_currentKeyboardId isEqualToString:@"com.apple.keylayout.2SetHangul"]) {

            if(event.type == NSEventTypeKeyDown) {
                sself->_letterEditorViewController.view.hidden = NO;

                if(sself->_letterEditorViewController.textField.currentEditor == nil) {
                    [sself->_letterEditorViewController.textField becomeFirstResponder];
                }

                return event;
            }
        }

        return nil;
    }];
    
    _letterEditorViewController = [LetterEditorViewController new];
    _letterEditorViewController.view.hidden = YES;
    [self addChildViewController:_letterEditorViewController];
    [self.view addSubview:_letterEditorViewController.view];
    
    [NSLayoutConstraint activateConstraints:@[
        [_letterEditorViewController.view.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [_letterEditorViewController.view.bottomAnchor  constraintEqualToAnchor:self.view.bottomAnchor constant:-20],
    ]];
    
    [self refresh];
}

- (void)dealloc {
    if(_eventMonitor) {
        [NSEvent removeMonitor:_eventMonitor];
        _eventMonitor = nil;
    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

- (void)keyboardSelectionDidChange:(NSNotification*)notification {
    [self refresh];
}

- (void)refresh {
    TISInputSourceRef source = TISCopyCurrentKeyboardLayoutInputSource();
    if(source == nil) {
        return;
    }

    CFStringRef sourceId = (CFStringRef)TISGetInputSourceProperty(source, kTISPropertyInputSourceID);

    if([_currentKeyboardId isEqualToString:(__bridge id)(sourceId)]) {
        CFRelease(source);
        return;
    }
    
    _currentKeyboardId = [(__bridge NSString *)(sourceId) copy];
    
    if(![_currentKeyboardId isEqualToString:@"com.apple.keylayout.2SetHangul"]) {
        _letterEditorViewController.view.hidden = YES;
    }
    
    CFRelease(source);
}

@end
