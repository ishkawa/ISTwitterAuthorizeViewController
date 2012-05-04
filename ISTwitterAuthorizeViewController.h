#import <UIKit/UIKit.h>

@interface ISTwitterAuthorizeViewController : UIViewController <UIWebViewDelegate>

@property (retain, nonatomic) UIWebView *webView;
@property (retain, nonatomic) UIActivityIndicatorView *indicatorView;
@property (retain, nonatomic) UIImage* screenShot;

- (void)dismiss;

@end
