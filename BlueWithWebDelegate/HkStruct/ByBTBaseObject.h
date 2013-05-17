//
//  ByBTBaseObject.h
//  BlueWithWebDelegate
//
//  Created by kevin on 13-5-7.
//
//

#import <Foundation/Foundation.h>

#import <GameKit/GameKit.h>

#import "PackType.h"

typedef void(^BTBaseConnectDidStartBlock)(NSString *cpeerid,NSString *cdisplayname);//开始连接
typedef void(^BTBaseDidDisConnectBlock) (NSString *callbackinfo);//断开连接
typedef void(^BTBaseConnectChangeStateBlock) (GKPeerConnectionState state);//连接状态改变
typedef void(^BTBaseDidReceiveMsgFromPeerBlock) (NSData *data,NSString *peer,GKSession *inSession,NSString *context);//从peer接受到信息
typedef void(^BTBasepeerPickerControllerDidCancel) (NSString *info);

@interface ByBTBaseObject : NSObject<GKPeerPickerControllerDelegate,GKSessionDelegate>

{
    /*GKSession对象用于表现两个蓝牙设备之间连接的一个会话，你也可以使用它在两个设备之间发送和接收数据。*/
    
    /*蓝牙对接窗口控制器*/
    
    GKPeerPickerController *_gkpeerPickerController;//蓝牙设备对接选择列表
    GKPeerPickerConnectionType *_gkpeerPickerConnectType;//蓝牙连接模式
    GKSession *_currentSession;//当前会话
    
    
    
    NSString *_myUUID;
    NSString *_oppSiteUUID;//对接设备UUID
    
    
    BTMyShape _myShape;
    BTGameOverStatus _btGameStatus;
    
}


@property (nonatomic, strong) BTBaseConnectDidStartBlock btBaseConnectDidStartBlock;
@property (nonatomic, strong) BTBaseDidDisConnectBlock   btBaseDidDisConnectBlock;
@property (nonatomic, strong) BTBaseConnectChangeStateBlock btBaseConnectChangeStateBlock;
@property (nonatomic, strong) BTBaseDidReceiveMsgFromPeerBlock btBaseDidReceiveMsgFromPeerBlock;
@property (nonatomic, strong) BTBasepeerPickerControllerDidCancel btBasepeerPickerControllerDidCancel;

@property (nonatomic,copy) NSString *myUUID;
@property (nonatomic,copy) NSString *oppSiteUUID;

@property BTMyShape myShape;
@property BTGameOverStatus btGameStatus;

//单例模式
+ (ByBTBaseObject *)Instance;

//从控制器传递过来 //开始启动蓝牙设备选择器
- (void)showPeerPickControllerFromViewController:(UIViewController *)currentViewController;

//用户主动断开连接
- (void)disconnect;

/*－－－－－－－－－－－－－－－－－－－－－－－－
 senddata 方法
 peerID为设备ID数组，nsstring 类型
 如果peerID 为空 则默认向所有peer连接发送数据
 否则则向指定的peerid数组发送数据
 －－－－－－－－－－－－－－－－－－－－－－－－*/
- (void)sendDataToPeers:(NSMutableData *)data WithPeerID:(NSArray *)peerID;//发送一个数据包

@end
