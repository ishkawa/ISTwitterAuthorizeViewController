#import <Foundation/Foundation.h>

@interface NSURLRequest (OAuth)

@end

@interface NSMutableURLRequest (OAuth)

- (void)setOAuthHeader;
- (void)setOAuthHeaderWithAccessToken:(NSString *)accessToken 
                    accessTokenSecret:(NSString *)accessTokenSecret;

- (void)setOAuthHeaderWithAccessToken:(NSString *)accessToken 
                    accessTokenSecret:(NSString *)accessTokenSecret
                             verifier:(NSString *)verifier;

@end
