//
//  VBAddressBookGrabber.h
//  AddressBookGrabber
//
//  Created by Vitaly Berg on 07.07.13.
//  Copyright (c) 2013 Vitaly Berg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

// Custom property for person record identifier
extern const ABPropertyID kABPersonIDProperty; 

@interface VBAddressBookGrabber : NSObject

// Property identifier wrapper NSNumber (@[@(kABPersonFirstNameProperty), ...])
@property (strong, nonatomic) NSArray *grabbingProperties;

// Property name by property identifier wrapped with NSNumber (@{@(kABPersonFirstNameProperty): @"FirstName", ...})
@property (strong, nonatomic) NSDictionary *propertyNames;

// If not nil date will be formatter to string
@property (strong, nonatomic) NSDateFormatter *dateFormatter; 

- (NSArray *)grabAddressBook:(ABAddressBookRef)addressBook;

// Custom kABPersonIDProperty included
+ (NSArray *)allProperties;

// Custom kABPersonIDProperty included as 'PersonID'
+ (NSDictionary *)localizedPropertyNames; 

@end
