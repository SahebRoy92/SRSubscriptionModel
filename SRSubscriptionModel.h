/*
  SRSubscriptionModel.h
  

  Created by Saheb Roy on 24/09/15.
  Copyright (c) 2015 OrderOfTheLight. All rights reserved.
  
  // Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE. 


*/
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
extern NSString *const kSRProductLoadedNotification;
extern NSString *const kSRSubscriptionResultNotification;

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
