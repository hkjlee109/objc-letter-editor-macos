#import <Cocoa/Cocoa.h>
#import "LetterEditorTextField.h"

NS_ASSUME_NONNULL_BEGIN

@interface LetterEditorViewController : NSViewController

@property (nonatomic, strong) LetterEditorTextField* textField;

- (void)activate;
- (void)deactivate;

@end

NS_ASSUME_NONNULL_END
