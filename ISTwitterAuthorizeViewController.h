#import <UIKit/UIKit.h>

@interface ISTwitterAuthorizeViewController : UIViewController <UIWebViewDelegate>

@property (retain, nonatomic) UIWebView *webView;
@property (retain, nonatomic) UIActivityIndicatorView *indicatorView;
@property (retain, nonatomic) UIImage* screenShot;

- (void)loadAuthorizePage;
- (void)verifyAccessToken:(NSString *)accessToken verifier:(NSString *)verifier;
- (void)registerUserWithDictionary:(NSDictionary *)dictionary;
- (void)dismiss;

@end
