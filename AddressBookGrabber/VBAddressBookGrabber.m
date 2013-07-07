//
//  VBAddressBookGrabber.m
//  AddressBookGrabber
//
//  Created by Vitaly Berg on 07.07.13.
//  Copyright (c) 2013 Vitaly Berg. All rights reserved.
//

#import "VBAddressBookGrabber.h"

const ABPropertyID kABPersonIDProperty = 0xBE76;

@implementation VBAddressBookGrabber

- (NSArray *)grabAddressBook:(ABAddressBookRef)addressBook {
    NSArray *people = (__bridge_transfer id)ABAddressBookCopyArrayOfAllPeople(addressBook);
    NSMutableArray *grabbedPeople = [NSMutableArray array];
    
    for (id item in people) {
        ABRecordRef person = (__bridge ABRecordRef)item;
        NSDictionary *grabbedPerson = [self gragPerson:person];
        if (grabbedPerson) {
            [grabbedPeople addObject:grabbedPerson];
        }
    }
    
    return grabbedPeople;
}

- (NSDictionary *)gragPerson:(ABRecordRef)person {
    NSMutableDictionary *grabbedPerson = [NSMutableDictionary dictionary];
    
    NSString *personIDPropertyName = [self propertyNameForProperty:kABPersonIDProperty];
    if (personIDPropertyName) {
        grabbedPerson[personIDPropertyName] = [@(ABRecordGetRecordID(person)) stringValue];
    }
    
    NSDictionary *grabbedProperties = [self grabProperties:self.grabbingProperties fromPerson:person];
    [grabbedPerson addEntriesFromDictionary:grabbedProperties];
    
    return [grabbedPerson count] > 0 ? grabbedPerson : nil;
}

- (NSDictionary *)grabProperties:(NSArray *)properties fromPerson:(ABRecordRef)person {
    NSMutableDictionary *grabbedProperties = [NSMutableDictionary dictionary];
    for (NSNumber *property in properties) {
        if ([property integerValue] == kABPersonIDProperty) {
            continue;
        }
        
        id value = [self grabProperty:[property integerValue] fromPerson:person];
        NSString *propertyName = [self propertyNameForProperty:[property integerValue]];
        if (value && propertyName) {
            grabbedProperties[propertyName] = value;
        }
    }
    return grabbedProperties;
}

- (id)grabProperty:(ABPropertyID)property fromPerson:(ABRecordRef)person {    
    if (ABPersonGetTypeOfProperty(property) & kABMultiValueMask) {
        return [self grabMultiValueProperty:property fromPerson:person];
    } else {
        id value = (__bridge_transfer id)ABRecordCopyValue(person, property);
        value = [self normilizeValue:value];
        return value;
    }
}

- (NSArray *)grabMultiValueProperty:(ABPropertyID)property fromPerson:(ABRecordRef)person {
    ABMultiValueRef multiValue = ABRecordCopyValue(person, property);
    if (!multiValue) {
        return nil;
    }
    
    CFIndex count = ABMultiValueGetCount(multiValue);
    if (count == 0) {
        CFRelease(multiValue);
        return nil;
    }
    
    NSMutableArray *grabbedMultiValue = [NSMutableArray array];
    
    for (CFIndex i = 0; i < count; i++) {
        id value = (__bridge_transfer id)ABMultiValueCopyValueAtIndex(multiValue, i);
        value = [self normilizeValue:value];
        [grabbedMultiValue addObject:value];
    }
    
    CFRelease(multiValue);
    
    return [grabbedMultiValue count] > 0 ? grabbedMultiValue : nil;
}

- (id)normilizeValue:(id)value {
    if ([value isKindOfClass:[NSDate class]] && self.dateFormatter) {
        return [self.dateFormatter stringFromDate:value];
    } else {
        return value;
    }
}

- (NSString *)propertyNameForProperty:(ABPropertyID)property {
    return self.propertyNames[@(property)];
}

+ (NSArray *)allProperties {
    return @[
        @(kABPersonIDProperty),
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
        @(kABPersonBirthdayProperty),
        @(kABPersonNoteProperty),
        @(kABPersonCreationDateProperty),
        @(kABPersonModificationDateProperty),
        @(kABPersonAddressProperty),
        @(kABPersonDateProperty),
        @(kABPersonKindProperty),
        @(kABPersonPhoneProperty),
        @(kABPersonInstantMessageProperty),
        @(kABPersonURLProperty),
        @(kABPersonRelatedNamesProperty),
        @(kABPersonSocialProfileProperty),
    ];
}

+ (NSDictionary *)localizedPropertyNames {
    NSArray *allProperties = [self allProperties];
    NSMutableDictionary *names = [NSMutableDictionary dictionary];
    
    for (NSNumber *property in allProperties) {
        if ([property integerValue] == kABPersonIDProperty) {
            names[property] = @"PersonID";
        } else {
            names[property] = (__bridge_transfer id)ABPersonCopyLocalizedPropertyName([property integerValue]);
        }
    }
    
    return names;
}

@end
