//
//  VBViewController.m
//  AddressBookGrabber
//
//  Created by Vitaly Bergon 30.06.13.
//  Copyright (c) 2013 Vitaly Berg. All rights reserved.
//

#import "VBViewController.h"

#import "VBAddressBookGrabber.h"

@interface VBViewController ()

@property (strong, nonatomic) UIBarButtonItem *grabBarButtonItem;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIView *grantAccessView;

@end

@implementation VBViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupGrabBarButtonItem];
    [self checkAuthorizationStatus];
}

#pragma mark - Helpers 

- (void)setupGrabBarButtonItem {
    self.grabBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Grab" style:UIBarButtonItemStyleBordered target:self action:@selector(grabAction:)];
}

#pragma mark - IBActions

- (IBAction)grabAction:(id)sender {
    [self grabAddressBook];
}

#pragma mark - Content

- (void)checkAuthorizationStatus {
    self.grantAccessView.hidden = YES;
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted)
    {
        if ([self.textView.text length] == 0) {
            self.grantAccessView.hidden = NO;
        }
        
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        self.navigationItem.rightBarButtonItem = self.grabBarButtonItem;
    }
}

- (void)grabAddressBook {
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if (addressBook) {
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!granted) {
                    [self checkAuthorizationStatus];
                    return;
                }
                
                NSArray *people = [VBAddressBookGrabber grabAddressBook:addressBook];
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:people options:NSJSONWritingPrettyPrinted error:nil];
                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                self.textView.text = jsonString;
            });
        });
    }
}

@end
