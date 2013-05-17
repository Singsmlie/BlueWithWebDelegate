//
//  ByBTBaseObject.m
//  BlueWithWebDelegate
//
//  Created by kevin on 13-5-7.
//
//

#import "ByBTBaseObject.h"

#import "HkTool.h"

#import "JSONKit.h"

//Singleton
static ByBTBaseObject *mainBTBaseObject = nil;

@interface ByBTBaseObject(privateMethods)

- (void)realRelease;
- (void)sendMyUUIDToOppsite;//向对接设备发送我的UUID

@end

@implementation ByBTBaseObject

@synthesize btBaseConnectChangeStateBlock;
@synthesize btBaseConnectDidStartBlock;
@synthesize btBaseDidDisConnectBlock;
@synthesize btBaseDidReceiveMsgFromPeerBlock;
@synthesize btBasepeerPickerControllerDidCancel;


@synthesize myShape = _myShape;
@synthesize myUUID = _myUUID;
@synthesize btGameStatus = _btGameStatus;
@synthesize oppSiteUUID = _oppSiteUUID;

static NSString *bCmd = @"cmd";
static NSString *bContent = @"content";

#pragma mark 
#pragma mark Singleton Methods
//get the singleton
+ (ByBTBaseObject *)Instance
{
    @synchronized(self){
        if (!mainBTBaseObject) {
            mainBTBaseObject = [[[self alloc]init]autorelease];
        }
        return mainBTBaseObject;
    }
}
//这里确保在别处调用alloc 也只是返回静态单例变量 不在初始化新对象
+ (id)allocWithZone:(NSZone *)zone{
    @synchronized(self){
        if(!mainBTBaseObject){
            mainBTBaseObject = [super allocWithZone:zone]; 
        }
        return mainBTBaseObject;
    }
    return nil;
}
- (id)retain{
    return self;
}
- (unsigned)retainCount{
    return 1;
}
- (oneway void)release{
    
}
- (id)autorelease{
    return self;
}
- (void)realRelease{
    [super release];
}


#pragma mark Object init
- (id)init
{
    self = [super init];
    if (self) {
        /*default is GKPeerPickerConnectionTypeNearby you can set it other before the method
         showPeerPickControllerFromViewController:*/
        _gkpeerPickerConnectType = GKPeerPickerConnectionTypeNearby;
        [self setMyUUID:[HkTool GetUUIDString]];
        NSLog(@"self uuid is %@",self.myUUID);
    }
    return self;
}
/*show the peerpick in the window */
- (void)showPeerPickControllerFromViewController:(UIViewController *)currentViewController
{
    if (_gkpeerPickerController == nil) {
        _gkpeerPickerController = [[GKPeerPickerController alloc]init];
    }
    _gkpeerPickerController.connectionTypesMask = _gkpeerPickerConnectType;
    _gkpeerPickerController.delegate = self;
    [_gkpeerPickerController show];
}
/*disconnect 用户手动断开连接*/
- (void)disconnect
{
    [_currentSession disconnectFromAllPeers];
    if (self.btBaseDidDisConnectBlock) {
        self.btBaseDidDisConnectBlock(@"dis connect!");
    }
}
/*发送消息接口
 data 为nsutf8 nstring 编码
 
 
 */
- (void)sendDataToPeers:(NSMutableData *)data WithPeerID:(NSArray *)peerID
{
    if (!data){
        NSLog(@"The send Data could not be nil!");
        return;
    }
    
    if (_currentSession) {
        if (peerID) 
            [_currentSession sendData:data toPeers:peerID withDataMode:GKSendDataReliable error:nil];
        else
            [_currentSession sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];
    }
}
/*暂时不用*/
- (void)sendMyUUIDToOppsite{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         @"0",bCmd,
                         self.myUUID,bContent,nil];
    NSString *msg = [[NSString alloc]initWithData:[dic JSONData] encoding:NSUTF8StringEncoding];
    NSData *tmd = [msg dataUsingEncoding:NSUTF8StringEncoding];
    [self sendDataToPeers:(NSMutableData *)tmd WithPeerID:nil];
    [msg release];
}


#pragma mark
#pragma mark GKPeerPickerController Delegate

/* Notifies delegate that a connection type was chosen by the user.
 */
- (void)peerPickerController:(GKPeerPickerController *)picker didSelectConnectionType:(GKPeerPickerConnectionType)type
{
    switch (type) {
        case GKPeerPickerConnectionTypeNearby:
        {
            NSLog(@"蓝牙 附近");
        }
            break;
        case GKPeerPickerConnectionTypeOnline:
        {
            NSLog(@"联网 ");
            [_gkpeerPickerController dismiss];
        }
            break;
        default:
            break;
    }
}

/* Notifies delegate that the connection type is requesting a GKSession object.
 
 You should return a valid GKSession object for use by the picker. If this method is not implemented or returns 'nil', a default GKSession is created on the delegate's behalf.
 */
- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type
{
    if (_currentSession == nil) {
        /*这里生成一个唯一的uudi字符串，为sessionid表识
         displayname: A string identifying the user to display to other peers. If nil, the session uses the device name.
         
         */
        //NSString *sessionid = [HkTool GetUUIDString];
        _currentSession = [[GKSession alloc]initWithSessionID:@"HQBY" displayName:nil sessionMode:GKSessionModePeer];
    }
    _currentSession.delegate = self;
    return _currentSession;
}

/* Notifies delegate that the peer was connected to a GKSession.
 */
- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session
{
    
    NSLog(@"did connect success! session id is [%@] peerID is [%@] conndisplayname is [%@]",session.sessionID,peerID,[session displayNameForPeer:peerID]);
    
    /*
     已经建立链接
     设备表识 peerid 已经连接到当前的gksession 以sessionid
     displayname 对方设备显示名称
     
     这里要关闭pickerVC
     */
    _gkpeerPickerController.delegate = nil;
    [_gkpeerPickerController dismiss];
    [_gkpeerPickerController release];
    _gkpeerPickerController = nil;
    
    if (self.btBaseConnectDidStartBlock) {
        self.btBaseConnectDidStartBlock(session.peerID,[session displayNameForPeer:peerID]);
    }
    
    
    
    /*设置好delegate 方法会调用 receiveData:fromPeer:inSession:context:*/
    [_currentSession setDataReceiveHandler:self withContext:nil];
    //发送自己的deviceUUID
    //[self sendMyUUIDToOppsite];
    
    
}

/* Notifies delegate that the user cancelled the picker.
 取消蓝牙选择器
 */
- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker
{
    
    if (self.btBasepeerPickerControllerDidCancel!=nil) {
        btBasepeerPickerControllerDidCancel(@"peerPicker did cancel and gkpeerPicker will dismiss and release to nil!");
    }
    [_gkpeerPickerController setDelegate:nil];
    [_gkpeerPickerController release];
    _gkpeerPickerController = nil;
}

#pragma mark
#pragma mark GKSession Delegate

/* Indicates a state change for the given peer.
 */
- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
    if (self.btBaseConnectChangeStateBlock) {
        self.btBaseConnectChangeStateBlock(state);
    }
    /*连接成功回调给控制器 用block 或者delegate 要判断block 与delegate 是否为nil*/
    switch (state) {
        case GKPeerStateConnected:
        {
           
            NSLog(@"链接成功！");
            
        }
            break;
        case GKPeerStateDisconnected:
        {
            
           
            if (self.btBaseDidDisConnectBlock) {
                self.btBaseDidDisConnectBlock([NSString stringWithFormat:@"device peerID [%@] 断开  displayname is [%@]",peerID,[session displayNameForPeer:peerID]]);
            }
            [_currentSession release];
            _currentSession = nil;
            
            NSLog(@"链接断开！");
            
        }
            break;
            
        case GKPeerStateAvailable:
        {
            
            NSLog(@"GKPeerStateAvailable！sessionid is [%@]  ;peerid is [%@]状态可用",session.sessionID,peerID);
        }
            break;
            
        case GKPeerStateUnavailable:
        {
            NSLog(@"GKPeerStateAvailable！sessionid is [%@]  ;peerid is [%@]状态不可用",session.sessionID,peerID);
        }
            break;
            
        case GKPeerStateConnecting:
        {
           
            NSLog(@"GKPeerStateConnecting！");
        }
            break;
        default:
            break;
    }
    
}

/* Indicates a connection request was received from another peer.
 
 Accept by calling -acceptConnectionFromPeer:
 Deny by calling -denyConnectionFromPeer:
 */
- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
    
    NSLog(@"didReceiveConnectionRequestFromPeer peerID is [%@]; sessionID is[%@]",peerID,session.sessionID);
    NSLog(@"function is  [at line %d in %@]", __LINE__, [[NSString stringWithUTF8String:__FILE__] lastPathComponent]);
}

/* Indicates a connection error occurred with a peer, which includes connection request failures, or disconnects due to timeouts.
 */
- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
    /*这里是连接某个设备失败时调用
     拒绝连接也会调用 ErrorCode ＝ 30502；
     
     */
    NSLog(@"connect with PeerFailed!error is [%@]; sessionid is[%@];peerid is [%@]",error,session.sessionID,peerID);
    NSLog(@"function is  [at line %d in %@]", __LINE__, [[NSString stringWithUTF8String:__FILE__] lastPathComponent]);
}

/* 
 Indicates an error occurred with the session such as failing to make available.
 */
- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
    NSLog(@"session didFailWithError: [%@]; sessionid is %@",error,session.sessionID);
}


//方法功能 接收数据
- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context
{
    NSLog(@"从sessionid[%@],peerid[%@],peeridDisplayName[%@];收到数据，回调Block处理数据",session.sessionID,peer,[session displayNameForPeer:peer]);
    
    if (self.btBaseDidReceiveMsgFromPeerBlock) {
        self.btBaseDidReceiveMsgFromPeerBlock(data,peer,session,context);
    }

}


- (void)dealloc{
    [_gkpeerPickerController release];
    _gkpeerPickerController = nil;
    
    self.btBaseConnectDidStartBlock = nil;
    self.btBaseDidReceiveMsgFromPeerBlock = nil;
    self.btBaseConnectChangeStateBlock = nil;
    self.btBaseDidDisConnectBlock = nil;
    self.btBasepeerPickerControllerDidCancel=nil;
    
    self.oppSiteUUID = nil;
    self.myUUID = nil;
    
    [super dealloc];
}
@end
