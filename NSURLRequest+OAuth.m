#import "NSURLRequest+OAuth.h"
#import "OAuthCore.h"

@implementation NSURLRequest (OAuth)

@end

@implementation NSMutableURLRequest (OAuth)

- (void)setOAuthHeader
{
    [self setOAuthHeaderWithAccessToken:@""
                      accessTokenSecret:@""
                               verifier:nil];
}

- (void)setOAuthHeaderWithAccessToken:(NSString *)accessToken 
                    accessTokenSecret:(NSString *)accessTokenSecret
{
    [self setOAuthHeaderWithAccessToken:accessToken
                      accessTokenSecret:accessTokenSecret
                               verifier:nil];
}

- (void)setOAuthHeaderWithAccessToken:(NSString *)accessToken 
                    accessTokenSecret:(NSString *)accessTokenSecret
                             verifier:(NSString *)verifier
{
    NSString *header = OAuthorizationHeader(self.URL,
                                            self.HTTPMethod,
                                            self.HTTPBody,
                                            CONSUMER_KEY, CONSUMER_KEY_SECRET,
                                            accessToken, accessTokenSecret);
    if (verifier) {
        header = [header stringByAppendingFormat:@", oauth_verifier=%@", verifier];
    }
    [self setValue:header forHTTPHeaderField:@"Authorization"];
}

@end
