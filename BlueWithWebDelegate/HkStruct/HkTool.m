//
//  HkTool.m
//  BlueWithWebDelegate
//
//  Created by kevin on 13-5-7.
//
//

#import "HkTool.h"

@implementation HkTool


#pragma mark 生成新的UUID
+ (NSString *)GetUUIDString
{
	CFUUIDRef theUUID = CFUUIDCreate(NULL);
	CFStringRef string = CFUUIDCreateString(NULL, theUUID);
	CFRelease(theUUID);
	return [(NSString *)string autorelease];
	//CFUUIDGetUUIDBytes(CFUUIDRef uuid);
}

+ (BOOL)ExecuteJavascriptToWebView:(UIWebView *)webview JS:(NSString *)jsprotocol
{
    if (!webview || ([jsprotocol length] == 0 && [jsprotocol isEqualToString:@""])) {
        return NO;
    }
    /*
     Return Value
     The result of running script or nil if it fails.
     */
   //jsprotocol = [HkTool replaceHTMLSpeCharcter:jsprotocol];
    NSString *isExecute = [webview stringByEvaluatingJavaScriptFromString:jsprotocol];
    if (isExecute == nil)
        return NO;
    return YES;
}

#pragma mark 替换HTML 中特殊字符 交给javascript时使用 （换行符号，单引号，双引号 \r \n）
/*
 这方法使用必须使用于要执行的内容
 且方法是由' 包括参数 例  
 
 NSString *js = [NSString StringWithFormat:@"Boy's iPhone"];
 js = [HkTool replaceHTMLSpeCharcter:js];
 NSString *name = [HkTool replaceHTMLSpeCharcter:self.title];
 NSString *js = [NSString stringWithFormat:@"setHtml('%@')",name];
 
 */
+ (NSString *)replaceHTMLSpeCharcter:(NSString *)orgstr{
    
    NSString *tempstr = [orgstr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    tempstr = [tempstr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    tempstr = [tempstr stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
    tempstr = [tempstr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    tempstr = [tempstr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    return tempstr;
    
}
@end
