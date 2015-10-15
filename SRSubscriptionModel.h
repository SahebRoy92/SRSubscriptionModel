//
//  SRSubscriptionModel.h
//  
//
//  Created by Saheb Roy on 24/09/15.
//  Copyright (c) 2015 OrderOfTheLight. All rights reserved.
//

#define userDefault [NSUserDefaults standardUserDefaults]

#import <Foundation/Foundation.h>

extern NSString *const kStoreKitSecret;
extern NSString *const kSubscriptionActive;
extern NSString *const kAppReceipt;
extern NSString *const kSubscriptionProduct;


/* Notification externs*/
extern NSString *const kSRProductPurchasedNotification;
extern NSString *const kSRProductUpdatedNotification;
extern NSString *const kSRProductRestoredNotification;
extern NSString *const kSRProductFailedNotification;

extern NSString *const SRFirstSubscription;
extern NSString *const SRSecondSubscription;

@interface SRSubscriptionModel : NSObject

@property (nonatomic,strong) NSMutableDictionary *currentProduct;
@property (nonatomic,strong) NSSet *subscriptionPlans;
@property (nonatomic,assign) BOOL currentIsActive;
@property (nonatomic,strong) NSArray *availableProducts;


+(instancetype)shareKit;
-(void)loadProducts;
-(void)makePurchase:(NSString *)productIdentifier;
-(void)restoreSubscriptions;

@end
