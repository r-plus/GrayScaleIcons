/**
 * Name: Backgrounder
 * Type: iPhone OS SpringBoard extension (MobileSubstrate-based)
 * Description: allow applications to run in the background
 * Author: Lance Fetters (aka. ashikase)
 * Last-modified: 2010-06-21 00:16:38
 */
/**
 * Copyright (C) 2008-2010  Lance Fetters (aka. ashikase)
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * 3. The name of the author may not be used to endorse or promote
 *    products derived from this software without specific prior
 *    written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS
 * OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
 * IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

/**
 * AippAppListCell.m
 * 
 * edited by deVbug
 */

#import "GSAppListCell.h"


// SpringBoardServices
extern NSString * SBSCopyLocalizedApplicationNameForDisplayIdentifier(NSString *identifier);
extern NSString * SBSCopyIconImagePathForDisplayIdentifier(NSString *identifier);
extern NSArray * SBSCopyApplicationDisplayIdentifiers(BOOL activeOnly, BOOL unknown);


NSInteger compareDisplayNames(NSString *a, NSString *b, void *context)
{
	NSInteger ret;
	
	NSString *name_a = SBSCopyLocalizedApplicationNameForDisplayIdentifier(a);
	NSString *name_b = SBSCopyLocalizedApplicationNameForDisplayIdentifier(b);
	ret = [name_a caseInsensitiveCompare:name_b];
	[name_a release];
	[name_b release];
	
	return ret;
}

NSArray *applicationDisplayIdentifiers()
{
	// Get list of non-hidden applications
	NSArray *nonhidden = SBSCopyApplicationDisplayIdentifiers(NO, NO);
	
	// Get list of hidden applications (assuming LibHide is installed)
	NSArray *hidden = nil;
	NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/LibHide/hidden.plist"];
	id value = [[NSDictionary dictionaryWithContentsOfFile:filePath] objectForKey:@"Hidden"];
	if ([value isKindOfClass:[NSArray class]])
		hidden = (NSArray *)value;
	
	// Record list of valid identifiers
	NSMutableArray *identifiers = [NSMutableArray array];
	for (NSArray *array in [NSArray arrayWithObjects:nonhidden, hidden, nil]) {
		for (NSString *identifier in array) {
			// Filter out non-apps and apps that are not executed directly
			// FIXME: Should Categories folders be in this list? Categories
			//        folders are apps, but when used with CategoriesSB they are
			//        non-apps.
			if (identifier
				&& ![identifier hasPrefix:@"jp.ashikase.springjumps."]
				&& ![identifier isEqualToString:@"com.iptm.bigboss.sbsettings"]
				&& ![identifier hasPrefix:@"com.apple.webapp"])
				[identifiers addObject:identifier];
		}
	}
	
	// Clean-up
	[nonhidden release];
	
	return identifiers;
}


static BOOL isFirmware3x = NO;
static NSData * (*SBSCopyIconImagePNGDataForDisplayIdentifier)(NSString *identifier) = NULL;


@implementation GSAppListCell

@synthesize displayId, blackListType;

+ (void)initialize
{
	// Determine firmware version
	isFirmware3x = [[[UIDevice currentDevice] systemVersion] hasPrefix:@"3"];
	if (!isFirmware3x) {
		// Firmware >= 4.0
		SBSCopyIconImagePNGDataForDisplayIdentifier = dlsym(RTLD_DEFAULT, "SBSCopyIconImagePNGDataForDisplayIdentifier");
	}
}

- (void)setDisplayId:(NSString *)identifier
{
	if (![displayId isEqualToString:identifier]) {
		[displayId release];
		displayId = [identifier copy];
		
		NSString *displayName = SBSCopyLocalizedApplicationNameForDisplayIdentifier(identifier);
		self.textLabel.text = displayName;
		[displayName release];
		
		UIImage *icon = nil;
		if (isFirmware3x) {
			// Firmware < 4.0
			NSString *iconPath = SBSCopyIconImagePathForDisplayIdentifier(identifier);
			if (iconPath != nil) {
				icon = [UIImage imageWithContentsOfFile:iconPath];
				[iconPath release];
			}
		} else {
			// Firmware >= 4.0
			if (SBSCopyIconImagePNGDataForDisplayIdentifier != NULL) {
				NSData *data = (*SBSCopyIconImagePNGDataForDisplayIdentifier)(identifier);
				if (data != nil) {
					icon = [UIImage imageWithData:data];
					[data release];
				}
			}
		}
		self.imageView.image = icon;
		
		blackListType = SNBlackListNone;
	}
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	CGSize size = self.bounds.size;
	self.imageView.frame = CGRectMake(4.0f, 4.0f, size.height - 8.0f, size.height - 8.0f);
	self.imageView.contentMode = UIViewContentModeScaleAspectFit;
	
	switch (blackListType) {
		case SNBlackListNormal:
			self.accessoryType = UITableViewCellAccessoryCheckmark;
			self.textLabel.textColor = [UIColor colorWithRed:81/255.0 green:102/255.0 blue:145/255.0 alpha:1];
			break;
		case SNBlackListForce:
			self.accessoryType = UITableViewCellAccessoryNone;
			self.textLabel.textColor = [UIColor colorWithRed:181/255.0 green:181/255.0 blue:181/255.0 alpha:1];
			break;
		case SNBlackListNone:
		default:
			self.accessoryType = UITableViewCellAccessoryNone;
			self.textLabel.textColor = [UIColor blackColor];
			break;
	}
}

@end


