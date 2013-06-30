//
//  VBAddressBookGrabber.h
//  AddressBookGrabber
//
//  Created by Vitaly Berg on 30.06.13.
//  Copyright (c) 2013 Vitaly Berg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface VBAddressBookGrabber : NSObject

+ (NSArray *)grabAddressBook:(ABAddressBookRef)addressBook;

@end
