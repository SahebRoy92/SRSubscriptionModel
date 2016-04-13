# SRSubscriptionModel

This is a class for performing and checking Auto Renewable subscription in iOS.


**Step - 1**

You got to give your subscription plan identifier's in SRSubscriptionModel.m NSString constants.
"SRFirstSubscription" and "SRSecondSubscription".

If you have more than one, then you can add them as separate constants and overwrite the `shareKit` method in the SRSubscriptionModel.m file, but that is not recommended. Just add more NSString constants and keep adding those constants in the `shareKit` method , here - 

`manager.subscriptionPlans = [NSSet setWithObjects:SRFirstSubscription,SRSecondSubscription, nil]`

**Step - 2**

Just call this method in AppDelegate.m `applicationDidBeginLaunchingWithOption` 

 --- `[SRSubscriptionModel shareKit]` 
 
 This wil load your current products and all purchases if any.
 
 **Added functionalities**
 
 To make purchase use -- 
 `[[SRSubscriptionModel shareKit]makePurchase:@"YOUR_PRODUCT_IDENTIFIER"]`
 To restore purchase use -- 
 `[SRSubscriptionModel shareKit]restoreSubscriptions]`
 
 **IMPORTANT** 
 Just add your View Controller to listen to these Notifications to know whether purchase is cancelled, purchase, failed, restored, products loaded, subscription checks.

      
 `kSRProductPurchasedNotification`  -  Product Purchased
 
 `kSRProductUpdatedNotification`    -  Product Updated
 
 `kSRProductRestoredNotification`   -  Product is restored
 
 `kSRProductFailedNotification`     -  Failed product purchase or restoration
 
 `kSRProductLoadedNotification`     -  Application Loaded Products from Apple servers
 
`kSRSubscriptionResultNotification` -  Application has loaded result of the current subscription , whether its active or not 
 
 **To know details of the current product use**
 
 `[SRSubscriptionModel shareKit].currentProduct` - This is a NSDictionary which will return the details of the product of the CurrentPlan.
 
 **To know in short if current plan is active or not use**
 
 `[SRSubscriptionModel shareKit].currentIsActive` -  This is a boolean value which will return if current plan is active or not (cancelled will fall under the NO category).
 
 
 A lot of more refinement is left, will update more along the way.
This is inspired from MKStoreKit.
