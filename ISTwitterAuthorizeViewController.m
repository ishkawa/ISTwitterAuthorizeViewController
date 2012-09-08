#import "ISTwitterAuthorizeViewController.h"
#import "ISNetworkOperation.h"
#import "NSURLRequest+OAuth.h"
#import "NSDictionary+URLQuery.h"

#define REQUEST_TOKEN_URL   @"https://api.twitter.com/oauth/request_token"
#define AUTHORIZE_URL       @"https://api.twitter.com/oauth/authorize"
#define ACCESS_TOKEN_URL    @"https://api.twitter.com/oauth/access_token"

@implementation ISTwitterAuthorizeViewController

@synthesize webView = _webView;
@synthesize indicatorView = _indicatorView;
@synthesize screenShot = _screenShot;

#pragma mark - view life cycle

- (void)loadView
{
    [super loadView];

    self.webView = [[[UIWebView alloc] init] autorelease];
    self.webView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.webView.delegate = self;
    self.webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
    [self.view addSubview:self.webView];
    
    self.navigationItem.title = @"Login";
    self.navigationItem.leftBarButtonItem =
    [[[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                      style:UIBarButtonItemStylePlain
                                     target:self
                                     action:@selector(dismiss)] autorelease];
    
    self.indicatorView = [[[UIActivityIndicatorView alloc] init] autorelease];
    self.indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    self.indicatorView.frame = CGRectMake(0, 0, 20, 20);
    self.navigationItem.rightBarButtonItem = 
    [[[UIBarButtonItem alloc] initWithCustomView:self.indicatorView] autorelease];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadAuthorizePage];
}

- (void)dealloc
{
    [_webView release], _webView = nil;
    [_indicatorView release], _indicatorView = nil;
    [super dealloc];
}

#pragma mark - action

- (void)loadAuthorizePage
{
    [self.indicatorView startAnimating];
    NSURL *URL = [NSURL URLWithString:REQUEST_TOKEN_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setOAuthHeader];
    
    [ISNetworkClient sendRequest:request
                         handler:^(NSHTTPURLResponse *response, id object, NSError *error) {
                             if (error) {
                                 NSLog(@"error: %@", error);
                                 return;
                             }
                             NSString *string = [[[NSString alloc] initWithData:object encoding:NSUTF8StringEncoding] autorelease];
                             NSDictionary *dictionary = [NSDictionary dictionaryWithURLQuery:string];
                             NSString *token = [dictionary objectForKey:@"oauth_token"];
                             NSString *URLString = [AUTHORIZE_URL stringByAppendingFormat:@"?oauth_token=%@", token];
                             NSURL *URL = [NSURL URLWithString:URLString];
                             NSURLRequest *request = [NSURLRequest requestWithURL:URL];
                             [self.webView loadRequest:request];
                         }];
}

- (void)verifyAccessToken:(NSString *)accessToken verifier:(NSString *)verifier
{
    [self.indicatorView startAnimating];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:ACCESS_TOKEN_URL]];
    [request setOAuthHeaderWithAccessToken:accessToken
                         accessTokenSecret:@""
                                  verifier:verifier];
    
    [ISNetworkClient sendRequest:request
                         handler:^(NSHTTPURLResponse *response, id object, NSError *error) {
                             [self.indicatorView stopAnimating];
                             if (error) {
                                 NSLog(@"error: %@", error);
                                 return;
                             }
                             NSString *string = [[[NSString alloc] initWithData:object encoding:NSUTF8StringEncoding] autorelease];
                             NSDictionary *dictionary = [NSDictionary dictionaryWithURLQuery:string];
                             [self registerUserWithDictionary:dictionary];
                         }];
}

- (void)registerUserWithDictionary:(NSDictionary *)dictionary
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *accounts = [defaults objectForKey:@"twitter_accounts"];
    if (![accounts isKindOfClass:[NSArray class]]) {
        accounts = [NSArray array];
    }
    NSMutableDictionary *account = [NSMutableDictionary dictionary];
    [account setValue:[dictionary objectForKey:@"user_id"] forKey:@"user_id"];
    [account setValue:[dictionary objectForKey:@"screen_name"] forKey:@"screen_name"];
    [account setValue:[dictionary objectForKey:@"oauth_token"] forKey:@"oauth_token"];
    [account setValue:[dictionary objectForKey:@"oauth_token_secret"] forKey:@"oauth_token_secret"];
    [defaults setObject:[accounts arrayByAddingObject:account] forKey:@"twitter_accounts"];
    [defaults synchronize];
    [self dismiss];
}

- (void)dismiss
{
    [self.indicatorView stopAnimating];
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - web view delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([request.URL.host isEqualToString:CALLBACK_HOST]) {
        NSDictionary *dictionary = [NSDictionary dictionaryWithURLQuery:request.URL.query];
        [self verifyAccessToken:[dictionary objectForKey:@"oauth_token"]
                       verifier:[dictionary objectForKey:@"oauth_verifier"]];
        return NO;
    }
    [self.indicatorView startAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.indicatorView stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.indicatorView stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
