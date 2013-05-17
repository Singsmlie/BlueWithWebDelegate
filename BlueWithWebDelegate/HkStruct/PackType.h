//
//  PackType.h
//  BlueWithWebDelegate
//
//  Created by hekun on 13-5-6.
//
//

typedef enum{
    PackTypeVoice,
    PackTypeStart,
    PackTypeBounce,
    PackTypeScore,
    PackTypeTalking,
    PackTypeEndTalking
}PackType;

typedef enum {
    BTMyShapeUndetermined = 0,
    BTMyShapeX,
    BTMyShapeO
}BTMyShape;

typedef enum{
    BTGameNotOver,
    BTGameOverXWins,
    BTGameOverOWins,
    BTGameOverTie

}BTGameOverStatus;