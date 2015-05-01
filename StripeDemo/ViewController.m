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

@end
