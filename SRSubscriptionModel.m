//
//  SRSubscriptionModel.m
//
//  Created by Saheb Roy on 24/09/15.
//  Copyright (c) 2015 OrderOfTheLight. All rights reserved.
//


#define userDef(parameter) [[NSUserDefaults standardUserDefaults]objectForKey:parameter]


#import "SRSubscriptionModel.h"
#import <StoreKit/StoreKit.h>
#import "AppController.h"


NSString *const kSandboxServer = @"https://sandbox.itunes.apple.com/verifyReceipt";
NSString *const kStoreKitSecret = @"YOUR_ITUNES_STOREKIT_SECRET";
NSString *const kItunesLiveServer = @"https://buy.itunes.apple.com/verifyReceipt";
NSString *const kSubscriptionActive = @"com.SahebRoy92.SM.existing_subscription_isactive";
NSString *const kAppReceipt = @"com.SahebRoy92.SM.existing_app_reciept";
NSString *const kSubscriptionProduct = @"com.SahebRoy92.SM.existing_subscription_product";



 NSString *const kSRProductPurchasedNotification = @"com.SahebRoy92.SRSubscriptionModel.PurchaseNotification";
 NSString *const kSRProductUpdatedNotification = @"com.SahebRoy92.SRSubscriptionModel.UpdatedNotification";
 NSString *const kSRProductRestoredNotification = @"com.SahebRoy92.SRSubscriptionModel.RestoredNotification";
 NSString *const kSRProductFailedNotification = @"com.SahebRoy92.SRSubscriptionModel.FailedNotification";



NSString *const SRFirstSubscription = @"com.YOUR_FIRST_SUBSCRIPTION_PLAN_PRODUCT_IDENTIFIER";
NSString *const SRSecondSubscription = @"com.YOUR_SECOND_SUBSCRIPTION_PLAN_PRODUCT_IDENTIFIER";


@interface SRSubscriptionModel()<SKPaymentTransactionObserver,SKProductsRequestDelegate>
@property (nonatomic,strong) NSString *latestReceipt;
@end

@implementation SRSubscriptionModel{
    NSMutableDictionary *payLoad;

}

+(instancetype)shareKit{
    static SRSubscriptionModel *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

            manager = [[SRSubscriptionModel alloc]init];
            manager.currentProduct = [[NSMutableDictionary alloc]init];
            manager.subscriptionPlans = [NSSet setWithObjects:SRFirstSubscription,SRSecondSubscription, nil];
        
            [[SKPaymentQueue defaultQueue]addTransactionObserver:manager];
            [manager startProductRequest];
            [manager loadProducts];
        
        
        
    });
    return manager;
}

-(void)loadProducts{
 NSError *error;
    _currentIsActive = NO;
    
    if(!userDef(kAppReceipt)){
        NSURL *recieptURL  = [[NSBundle mainBundle]appStoreReceiptURL];
        NSError *recieptError ;
        BOOL isPresent = [recieptURL checkResourceIsReachableAndReturnError:&recieptError];

        if(!isPresent){
            SKReceiptRefreshRequest *ref = [[SKReceiptRefreshRequest alloc]init];
            ref.delegate = self;
            [ref start];
            
            return;
        }
        
        NSData *recieptData = [NSData dataWithContentsOfURL:recieptURL];
        if(!recieptData){
            return;
        }
       
        payLoad = [NSMutableDictionary dictionaryWithObject:[recieptData base64EncodedStringWithOptions:0] forKey:@"receipt-data"];
    }
    else {
        [payLoad setObject:userDef(kAppReceipt) forKey:@"receipt-data"];
    }
    
    
    [payLoad setObject:kStoreKitSecret forKey:@"password"];
    
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:payLoad options:0 error:&error];
    
    NSMutableURLRequest *sandBoxReq = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kSandboxServer]];
    [sandBoxReq setHTTPMethod:@"POST"];
    [sandBoxReq setHTTPBody:requestData];
    
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:sandBoxReq completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if(!error){
            NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            _latestReceipt = [jsonResponse objectForKey:@"latest_receipt"];
            
            
            if([jsonResponse objectForKey:@"latest_receipt_info"]){
                NSArray *array = [jsonResponse objectForKey:@"latest_receipt_info"];
                NSDictionary *latestDetails = [array lastObject];
                
                if([latestDetails objectForKey:@"cancellation_date_ms"]){
                    _currentIsActive = NO;
                }
                [_currentProduct setObject:[latestDetails objectForKey:@"product_id"] forKey:@"product"];
                [_currentProduct setObject:[latestDetails objectForKey:@"expires_date_ms"] forKey:@"expiry_time"];
                _currentIsActive = [self calculateCurrentSubscriptionActive];
                [_currentProduct setObject:[NSNumber numberWithBool:_currentIsActive] forKey:@"active"];
                [userDefault setObject:_currentProduct forKey:kSubscriptionProduct];
                [userDefault setBool:_currentIsActive forKey:kSubscriptionActive];
                NSLog(@"Product active -- %hhd",_currentIsActive);
                

            }
            else {
                
                // no purchase done, first time user!
            }
            
        }
        
    }] resume];
    
    
}


#pragma mark - Restore

-(void)restoreSubscriptions{
    [[SKPaymentQueue defaultQueue]restoreCompletedTransactions];
}

-(void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error{
    //Fail restoring!
    NSLog(@"Restoration of subscription failed!");
}

-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue{
    //restored!
   NSLog(@"Subscriptions restored");
    
}



#pragma mark - Transaction Observers

-(void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads{
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
                
            case SKPaymentTransactionStatePurchasing:
                break;
                
            case SKPaymentTransactionStateDeferred:{
                [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStateFailed:{
                [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStatePurchased:{
                NSLog(@"PURCHASED!");
                [self saveProductPurchaseWithProduct:transaction];
                break;
            }
            case SKPaymentTransactionStateRestored: {
                NSLog(@"RESTORED");
                [self postRestoredNotification:transaction];
                break;

            }
        }
    }
}



/************* CHECK IF CURRENT SUBSCRIPTION ACTIVE OR NOT! ****************/

-(BOOL)calculateCurrentSubscriptionActive{
    NSString *str = [_currentProduct objectForKey:@"expiry_time"];
    long long currentExpTime = [str longLongValue]/1000;
    long currentTimeStamp = [[NSDate date] timeIntervalSince1970];
    NSLog(@"%ld",currentTimeStamp);
    
    return (currentExpTime > currentTimeStamp) ? YES : NO;
    
}



/************ CALL THIS TO FETCH ALL OBJECTS IN THE IN APP ****************/

-(void)startProductRequest{
    SKProductsRequest *productRequest = [[SKProductsRequest alloc]initWithProductIdentifiers:_subscriptionPlans];
    productRequest.delegate = self;
    [productRequest start];
}

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    
    NSLog(@"%@",response.products);
    _availableProducts = response.products;

}


-(void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    
}


-(void)requestDidFinish:(SKRequest *)request{
    NSLog(@"REQUEST DID FINISH");
}

/************ BUY SUBSCRIPTION ****************/

-(void)makePurchase:(NSString *)productIdentifier{
    
    if(_availableProducts.count == 0){
        [self startProductRequest];
        return;
    }
    
    [_availableProducts enumerateObjectsUsingBlock:^(SKProduct *thisProduct, NSUInteger idx, BOOL *stop) {
        if ([thisProduct.productIdentifier isEqualToString:productIdentifier]) {
            *stop = YES;
            SKPayment *payment = [SKPayment paymentWithProduct:thisProduct];
            [[SKPaymentQueue defaultQueue] addPayment:payment];
        }
    }];
}


/************ SAVE PRODUCT INFO WHEN SUBSCRIPTION IS OVER AND AGAIN USER BOUGHT ****************/

-(void)saveProductPurchaseWithProduct:(SKPaymentTransaction *)transaction{
    [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
    [self postNotificationPurchased:transaction.payment.productIdentifier];
}




-(void)postNotificationPurchased:(NSString *)identifier{
    NSDictionary *obj = @{@"product":identifier};
    self.currentIsActive = YES;
    self.currentProduct = obj;
    [[NSNotificationCenter defaultCenter]postNotificationName:kSRProductPurchasedNotification object:obj];
}

-(void)postRestoredNotification:(SKPaymentTransaction *)transaction{
    [[SKPaymentQueue defaultQueue]finishTransaction:transaction];
    [[NSNotificationCenter defaultCenter]postNotificationName:kSRProductRestoredNotification object:nil];
}

@end
