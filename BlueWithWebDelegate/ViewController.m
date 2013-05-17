//
//  ViewController.m
//  BlueWithWebDelegate
//
//  Created by hekun on 13-5-6.
//
//

#import "ViewController.h"
#import "PackType.h"
#import "HkTool.h"

@interface ViewController ()

/*接受js传过来的命令*/
- (void)JSAction:(NSString *)event;

/*发送蓝牙数据*/
- (void)SendBlueMsg:(NSString *)content ToPeerID:(NSArray *)peerid;

@end

@implementation ViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"无连接";
    
    UIBarButtonItem *disconnectBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(disConnectBlue:)];
    [self.navigationItem setLeftBarButtonItem:disconnectBtn];
    [disconnectBtn release];
    
    
    
    
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"webdelegate" ofType:@"html"];
    fullWebview = [[UIWebView alloc]initWithFrame:self.view.frame];
    [fullWebview loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:filePath]]];
    [fullWebview setDelegate:self];
    
    [self.view addSubview:fullWebview];
    
    
	// Do any additional setup after loading the view, typically from a nib.
}
#pragma mark
#pragma mark ConfigByBTBaseObjectBlock 
- (void)configByBTBaseObjectBlock
{
    [[ByBTBaseObject Instance]setBtBaseConnectDidStartBlock:^(NSString *cpeerid,NSString *cdisplayname){
        self.title = [NSString stringWithFormat:@"%@已连接",cdisplayname];
        NSString *name = [HkTool replaceHTMLSpeCharcter:self.title];
        NSString *js = [NSString stringWithFormat:@"setHtml('%@')",name];
        
        if (![HkTool ExecuteJavascriptToWebView:fullWebview JS:js]) {
            NSLog(@"Js execute failed!function is  [at line %d in %@]", __LINE__, [[NSString stringWithUTF8String:__FILE__] lastPathComponent]);
        }
        if (![HkTool ExecuteJavascriptToWebView:fullWebview JS:@"setStartBlueEnable('no')"]) {
            NSLog(@"Js execute failed!function is  [at line %d in %@]", __LINE__, [[NSString stringWithUTF8String:__FILE__] lastPathComponent]);
        }
    }];
    [[ByBTBaseObject Instance]setBtBaseDidDisConnectBlock:^(NSString *callbackinfo){
        
        NSLog(@"blue tooth did disconnect! info is [%@]",callbackinfo);
        self.title = @"无连接";
       
        NSString *js = [NSString stringWithFormat:@"setHtml('%@')",self.title];
        if (![HkTool ExecuteJavascriptToWebView:fullWebview JS:js]) {
            NSLog(@"Js execute failed!function is  [at line %d in %@]", __LINE__, [[NSString stringWithUTF8String:__FILE__] lastPathComponent]);
        }
        if (![HkTool ExecuteJavascriptToWebView:fullWebview JS:@"setStartBlueEnable('yes')"]) {
            NSLog(@"Js execute failed!function is  [at line %d in %@]", __LINE__, [[NSString stringWithUTF8String:__FILE__] lastPathComponent]);
        }


    }];
    [[ByBTBaseObject Instance]setBtBasepeerPickerControllerDidCancel:^(NSString *info){
        NSLog(@"The PickerVC did cancel By User! %@",info);
        NSString *js = [NSString stringWithFormat:@"setHtml('%@')",info];
        
         if (![HkTool ExecuteJavascriptToWebView:fullWebview JS:js]) {
            NSLog(@"Js execute failed!function is  [at line %d in %@]", __LINE__, [[NSString stringWithUTF8String:__FILE__] lastPathComponent]);
        }
      
    }];
    [[ByBTBaseObject Instance]setBtBaseDidReceiveMsgFromPeerBlock:^(NSData *data,NSString *peer,GKSession *inSession,NSString *context){
            /*
             Session 
             peer
             data dictionary 格式数据包 cmd  content 
             context
             */
        //处理数据执行JS到uiwebview 解析这里的content
        NSString *executejs = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        [HkTool ExecuteJavascriptToWebView:fullWebview JS:executejs];
        [executejs release];

    }];
    [[ByBTBaseObject Instance]setBtBaseConnectChangeStateBlock:^(GKPeerConnectionState state){
         NSLog(@"状态改变");
    }];
}
/*开始链接*/
- (void)connectBlueToOtherDevice:(id)sender
{
    
    //[self.navigationItem.rightBarButtonItem setEnabled:NO];
    [[ByBTBaseObject Instance]showPeerPickControllerFromViewController:self];
    /*配置回调方法*/
    [self configByBTBaseObjectBlock];
   
}
/*断开链接*/
- (void)disConnectBlue:(id)sender
{
    [[ByBTBaseObject Instance]disconnect];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark WebviewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeOther) {
        NSLog(@"request [%@]",[request URL]);
        /*这里要判断类型接受javascript传递过来的数据*/
        /*直接调用sendmsg 需要将字符串转换成NSdata*/
        //[[ByBTBaseObject Instance] sendDataToPeers:<#(NSMutableData *)#> WithPeerID:<#(NSArray *)#>];
        //[self JSAction:[[request URL]absoluteString]];
    }else if (navigationType == UIWebViewNavigationTypeLinkClicked){
        NSLog(@"link is [%@]",[request URL]);
        return NO;
    }else{
        return NO;
    }
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidStartLoad");
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad");
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
//    NSLog(@"didFailLoadWithError");
//    if (error) {
//        NSLog(@"%@",error);
//    }
}


#pragma mark 
#pragma mark JSAction
/*处理JS返回的命令*/
- (void)JSAction:(NSString *)event
{
    
    NSArray *taskprotocol = [event  componentsSeparatedByString:@":"];
    NSString *task = [taskprotocol objectAtIndex:1];
    task = [task stringByReplacingOccurrencesOfString:@"//" withString:@""];
    NSLog(@"%@",task);
    if ([task isEqualToString:@"KeyUpFromJS"]) {
        
    }else if ([task isEqualToString:@"KeyDownFromJS"]){
        
    }else if ([task isEqualToString:@"TouchStartFromJS"]){
        
        
        
    }else if ([task isEqualToString:@"TouchEndFromJS"]){
        
        
    }else if ([task isEqualToString:@"DOMSubtreeModified"]){
        
        
    }else if ([task isEqualToString:@"DOMScrollDidEnd"]){
        
    }else if ([task isEqualToString:@"PasteFromJS"]){
        
    }else if([task isEqualToString:@"DOMContentLoaded"]){
        
               
    }else if([task isEqualToString:@"JSImageOnLoad"]){
        
    }else if([task isEqualToString:@"BlurFromJS"]){
        
    }else if([task isEqualToString:@"FocusFromJS"]){
        
    }else if([task isEqualToString:@"StartBlueTooth"]){
          //开启蓝牙
         [self connectBlueToOtherDevice:nil];
    }else{
       
    }
}

- (void)passDataToJS:(NSString *)content
{
    BOOL isSuccess = [HkTool ExecuteJavascriptToWebView:fullWebview JS:content];
    if (isSuccess) {
        NSLog(@"js执行成功");
    }else{
        NSLog(@"js执行失败");
    }
}
- (void)SendBlueMsg:(NSString *)content ToPeerID:(NSArray *)peerid
{
    if (content == nil) 
        return;
    /*
     peerID 为nil则向所有peer发送
     否则针对peerid 发送
     
     */
    /*这里发送xml数据或者 json数据 utf8编码*/
    NSData *sdata = [content dataUsingEncoding:NSUTF8StringEncoding];
    [[ByBTBaseObject Instance]sendDataToPeers:(NSMutableData *)sdata WithPeerID:peerid];
    
    
       
    
}

- (void)dealloc
{
    
    fullWebview.delegate = nil;
    [fullWebview release];
    [super dealloc];
}
@end
