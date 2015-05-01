//
//  ViewController.m
//  StripeDemo
//
//  Created by Michael Vilabrera on 4/30/15.
//  Copyright (c) 2015 Giving Tree. All rights reserved.
//

#import "ViewController.h"

#import <Stripe.h>
#import "Constant.h"
#import <ApplePayStubs.h>
#import <PassKit/PassKit.h>
#import <Stripe+ApplePay.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    PKPaymentRequest *paymentRequest = [Stripe paymentRequestWithMerchantIdentifier:APPLE_MERCHANT_ID];
    
    // configure merchant request
    NSString *label = @"Cool New Gizmo";
    NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:@"5.00"];
    paymentRequest.paymentSummaryItems = @[[PKPaymentSummaryItem summaryItemWithLabel:label amount:amount]];
    
    if ([Stripe canSubmitPaymentRequest:paymentRequest]) {
        // ...
        NSLog(@"so far so good");
#if DEBUG
        STPTestPaymentAuthorizationViewController *paymentController;
        paymentController = [[STPTestPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
        paymentController.delegate = self;
#else
        PKPaymentAuthorizationViewController *paymentController;
        paymentController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
        paymentController.delegate = self;
#endif
        [self presentViewController:paymentController animated:YES completion:nil];
    }
    else {
        // use different credit card option
        NSLog(@"Try something else");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --Payment Methods--
- (void) paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                        didAuthorizePayment:(PKPayment *)payment
                                 completion:(void (^)(PKPaymentAuthorizationStatus))completion
{
    [self handlePaymentAuthorizationWithPayment:payment completion:completion];
}

- (void)handlePaymentAuthorizationWithPayment:(PKPayment *)payment
                                   completion:(void (^)(PKPaymentAuthorizationStatus))completion
{
    [[STPAPIClient sharedClient] createTokenWithPayment:payment
                                             completion:^(STPToken *token, NSError *error) {
                                                 [self createBackendChargeWithToken:token completion:completion];
                                             }];
}

- (void) createBackendChargeWithToken:(STPToken *)token completion:(void(^)(PKPaymentAuthorizationStatus))completion
{
    NSURL *url = [NSURL URLWithString:@"https://example.com/token"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    NSString *body = [NSString stringWithFormat:@"stripeToken=%@", token.tokenId];
    request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            completion(PKPaymentAuthorizationStatusFailure);
        }
        else {
            completion(PKPaymentAuthorizationStatusSuccess);
        }
    }];
}

@end
