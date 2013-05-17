//
//  HkTool.h
//  BlueWithWebDelegate
//
//  Created by kevin on 13-5-7.
//
//

#import <Foundation/Foundation.h>

@interface HkTool : NSObject
+ (NSString *)GetUUIDString;
/*返回值 YES javascript 执行成功  NO 执行失败*/
+ (BOOL)ExecuteJavascriptToWebView:(UIWebView *)webview JS:(NSString *)jsprotocol;

+ (NSString *)replaceHTMLSpeCharcter:(NSString *)orgstr;
@end
