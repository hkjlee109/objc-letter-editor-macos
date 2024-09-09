#import "LetterEditorViewController.h"

@interface LetterEditorViewController () <NSTextFieldDelegate>

@end

@implementation LetterEditorViewController {
    NSString* _charToSend;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.view.wantsLayer = true;
    self.view.layer.cornerRadius = 12;
    self.view.layer.masksToBounds = YES;
    self.view.layer.backgroundColor = [[NSColor colorWithCalibratedRed:68.0/255 green:68.0/255 blue:68.0/255 alpha:0.9] CGColor];
//    self.view.layer.backgroundColor = [[NSColor colorWithCalibratedRed:239.0/255 green:66.0/255 blue:58.0/255 alpha:0.9] CGColor];

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

- (void)keyDown:(NSEvent *)event {
    [super keyDown:event];
    NSLog(@"keyDown");
}

- (void)controlTextDidChange:(NSNotification *)obj {
    if(_textField.stringValue.length > 0) {
        _charToSend = [NSString stringWithFormat:@"%X", [_textField.stringValue characterAtIndex:[_textField.stringValue length] - 1]];
        _textField.stringValue = @"";
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self->_textField.stringValue.length == 0) {
                self.view.hidden = YES;
                return;
            }
            
            NSLog(@"# Finalize %@", self->_charToSend);
        });
    }
}

@end
