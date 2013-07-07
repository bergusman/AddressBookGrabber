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
    [self authorizateAndGrab];
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

- (void)authorizateAndGrab {
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(NULL, ^(bool granted, CFErrorRef error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!granted) {
                    [self checkAuthorizationStatus];
                    return;
                }
                
                [self grabAddressBook];
            });
        });
    } else {
        [self grabAddressBook];
    }
}

- (void)grabAddressBook {
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    VBAddressBookGrabber *addressBookGrabber = [[VBAddressBookGrabber alloc] init];
    addressBookGrabber.grabbingProperties = [VBAddressBookGrabber allProperties];
    addressBookGrabber.propertyNames = [VBAddressBookGrabber localizedPropertyNames];
    addressBookGrabber.dateFormatter = [[NSDateFormatter alloc] init];
    addressBookGrabber.dateFormatter.dateStyle = NSDateFormatterFullStyle;
    
    NSArray *people = [addressBookGrabber grabAddressBook:addressBook];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:people options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    self.textView.text = jsonString;
}

@end
