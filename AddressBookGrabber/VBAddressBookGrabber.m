//
//  VBAddressBookGrabber.m
//  AddressBookGrabber
//
//  Created by Vitaly Berg on 30.06.13.
//  Copyright (c) 2013 Vitaly Berg. All rights reserved.
//

#import "VBAddressBookGrabber.h"

@implementation VBAddressBookGrabber

+ (NSArray *)grabAddressBook:(ABAddressBookRef)addressBook {
    NSMutableArray *grabbedPeople = [NSMutableArray array];
    
    NSArray *people = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
    for (id item in people) {
        id person = [self grabPerson:(__bridge ABRecordRef)item];
        [grabbedPeople addObject:person];
    }
    
    return grabbedPeople;
}

+ (id)grabPerson:(ABRecordRef)person {
    NSMutableDictionary *grabbedPerson = [NSMutableDictionary dictionary];
    
    NSArray *properties = [self allProperties];
    
    for (NSNumber *property in properties) {
        id value = [self grapProperty:[property integerValue] fromPerson:person];
        if (value) {
            NSString *valueKey = (__bridge_transfer NSString *)ABPersonCopyLocalizedPropertyName([property integerValue]);
            if (!valueKey) {
                NSLog(@"ups");
            }
            grabbedPerson[valueKey] = value;
        }
    }
    
    return grabbedPerson;
}

+ (id)grapProperty:(ABPropertyID)property fromPerson:(ABRecordRef)person {
    if (ABPersonGetTypeOfProperty(property) & kABMultiValueMask) {
        ABMultiValueRef multiValue = ABRecordCopyValue(person, property);
        id grabbedMultiValue = [self grabMultiValue:multiValue];
        CFRelease(multiValue);
        return grabbedMultiValue;
    } else {
        id value = (__bridge_transfer id)ABRecordCopyValue(person, property);
        return value;
    }
}

+ (id)grabMultiValue:(ABMultiValueRef)multiValue {
    NSArray *values = (__bridge_transfer NSArray *)ABMultiValueCopyArrayOfAllValues(multiValue);
    if ([values count] == 0) {
        return nil;
    } else {
        return values;
    }
}

+ (NSArray *)allProperties {
    return @[
        @(kABPersonFirstNameProperty),
        @(kABPersonLastNameProperty),
        @(kABPersonMiddleNameProperty),
        @(kABPersonPrefixProperty),
        @(kABPersonSuffixProperty),
        @(kABPersonNicknameProperty),
        @(kABPersonFirstNamePhoneticProperty),
        @(kABPersonLastNamePhoneticProperty),
        @(kABPersonMiddleNamePhoneticProperty),
        @(kABPersonOrganizationProperty),
        @(kABPersonJobTitleProperty),
        @(kABPersonDepartmentProperty),
        @(kABPersonEmailProperty),
        //@(kABPersonBirthdayProperty),
        @(kABPersonNoteProperty),
        //@(kABPersonCreationDateProperty),
        //@(kABPersonModificationDateProperty),
        @(kABPersonAddressProperty),
        //@(kABPersonDateProperty),
        @(kABPersonKindProperty),
        @(kABPersonPhoneProperty),
        @(kABPersonInstantMessageProperty),
        @(kABPersonURLProperty),
        @(kABPersonRelatedNamesProperty),
        @(kABPersonSocialProfileProperty)
    ];
}

@end
