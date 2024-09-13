#import <Cocoa/Cocoa.h>
#import "LetterEditorTextField.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PostEventAction) {
    PostEventActionDiscard,
    PostEventActionSendToHost,
    PostEventActionSendToRemote
};

@interface LetterEditorViewController : NSViewController

@property (nonatomic, strong) LetterEditorTextField* textField;

- (void)activate;
- (void)deactivate;
- (PostEventAction)processEvent:(NSEvent*)event;

@end

NS_ASSUME_NONNULL_END
