//
//  ViewController.m
//  HTTPTools
//
//  Created by Hawk on 2019/7/17.
//  Copyright © 2019 Hawk. All rights reserved.
//

#import "ViewController.h"
#define LAST_URL @"LAST_URL"
#define LAST_POST_BODY @"LAST_POST_BODY"
#define LAST_POST_SWITCH @"LAST_POST_SWITCH"

@interface ViewController (){
    NSURLSessionDataTask *task;
    UIAlertController *alert;
}
@property (strong,nonatomic) IBOutlet UITextField *url_view;
@property (strong,nonatomic) IBOutlet UITextView *body_view;
@property (strong,nonatomic) IBOutlet UITextView *received_view;
@property (nonatomic) IBOutlet UISwitch *post_switch;

@end

@implementation ViewController
@synthesize url_view;
@synthesize body_view;
@synthesize received_view;
@synthesize post_switch;

-(IBAction)send:(id)sender{
    [url_view resignFirstResponder];
    [body_view resignFirstResponder];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url_view.text]];
    [request setTimeoutInterval:10.f];
    if (post_switch.on){
        [request setHTTPMethod:@"POST"];
        NSData *data = [body_view.text dataUsingEncoding:NSUTF8StringEncoding];
        if (nil == data){
            alert = [UIAlertController alertControllerWithTitle:@"Post Body Error" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alert addAction:cancel];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        NSString *bodyData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[NSData dataWithBytes:[bodyData UTF8String] length:strlen([bodyData UTF8String])]];
    }
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setValue:url_view.text forKey:LAST_URL];
    [user setValue:body_view.text forKey:LAST_POST_BODY];
    [user setValue:[NSNumber numberWithBool:post_switch.on] forKey:LAST_POST_SWITCH];
    [user synchronize];
    
    task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error){
                self->received_view.text = [NSString stringWithFormat:@"%@",error];
            }else{
                self->received_view.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
            [self->alert dismissViewControllerAnimated:YES completion:nil];
        });
    }];
    [task resume];
    
    alert = [UIAlertController alertControllerWithTitle:@"Running" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cannel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self->task cancel];
    }];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
    return;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSString *url_string = [[NSUserDefaults standardUserDefaults] valueForKey:LAST_URL];
    if (nil == url_string){
        url_string = @"http://172.16.0.83:8787/Services/ServiceHandler.ashx";
    }
    url_view.text = url_string;
    
    post_switch.on = [[[NSUserDefaults standardUserDefaults] valueForKey:LAST_POST_SWITCH] boolValue];
    
    NSString *body_string = [[NSUserDefaults standardUserDefaults] valueForKey:LAST_POST_BODY];
    if (nil == body_string){
        body_string = @"{ \n \"id\" : \"get_ecgs_by_group\",\n \"method\" : \"get_ecgs_by_group\", \n \"params\" : [\n 1,\n 0,\n \"vhadmin\" \n ] \n }\n";
    }
    body_view.text = body_string;
}


@end
