/* 
 * 
 *	AlwaysiPodPlaySettings.m
 *	AlwaysiPodPlay's Settings bundle
 *	
 *	
 *	Always iPod Play
 *	Copyright (C) 2011  deVbug (devbug@devbug.me)
 *	
 *	This program is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation, either version 3 of the License.
 *	 
 *	This program is distributed in the hope that it will be useful,
 *	but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	GNU General Public License for more details.
 *	
 *	You should have received a copy of the GNU General Public License
 *	along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *	
 */
/*
 
 Preference.m
 Edit by r_plus.
	1. Replace MBProgressHUD to UIProgressHUD(PrivateAPI).
 
*/



#import <UIKit/UITextView2.h>
#import <Preferences/Preferences.h>

//#import "../MBProgressHUD/MBProgressHUD.h"
#import "GSAppListCell.h"
#import "UIProgressHUD.h"

#include <objc/runtime.h>

#define PREFERENCE_PATH @"/User/Library/Preferences/jp.r-plus.GrayScaleIcons.plist"
//#define HUD_TAG		998


extern NSInteger compareDisplayNames(NSString *a, NSString *b, void *context);
extern NSArray *applicationDisplayIdentifiers();



static PSListController *_selfSettingsController;


@interface GrayScaleIconsSettingsListController: PSListController {
}
@end

@implementation GrayScaleIconsSettingsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"GrayScaleIconsSettings" target:self] retain];
	}
	
	_selfSettingsController = self;
	
	return _specifiers;
}

-(void)github:(id)github
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/r-plus/GrayScaleIcons"]];
}

@end



@interface GSWhiteListController: PSViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableView *_tableView;
	NSMutableArray *_list;
	NSMutableString *_title;
	UIView *window;
	UIView *__view;
	UIProgressHUD *progressHUD;
}

- (id) initForContentSize:(CGSize)size;
- (id) view;
- (id)_tableView;
- (id) navigationTitle;
- (void) dealloc;

- (void)loadWhiteListView;
- (void)loadInstalledAppData;

- (int) numberOfSectionsInTableView:(UITableView *)tableView;
- (id) tableView:(UITableView *)tableView titleForHeaderInSection:(int)section;
- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(int)section;
- (id) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end



@implementation GSWhiteListController


- (id) initForContentSize:(CGSize)size {
	if ((self = [super initForContentSize:size]) != nil) {
		_list = nil;
		
		_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480-64) style:UITableViewStylePlain];
		[_tableView setDelegate:self];
		[_tableView setDataSource:self];
		
		__view = nil;
		window = [[UIApplication sharedApplication] keyWindow];
		if (window == nil) {
			__view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480-64)];
			[__view addSubview:_tableView];
			window = __view;
		}
		
		if(!_title)
			_title = [[NSMutableString alloc] init];
		
		[_title setString:@"Exclusion Apps"];
		
		if ([self respondsToSelector:@selector(navigationItem)])
			[[self navigationItem] setTitle:_title];
		
		[self loadWhiteListView];
	}
	
	return self;
}

- (void)loadWhiteListView
{
/*
	MBProgressHUD *HUD = nil;
	if ((HUD = (MBProgressHUD *)[window viewWithTag:HUD_TAG]) == nil) {
		HUD = [[MBProgressHUD alloc] initWithView:window];
		[window addSubview:HUD];
	}
	HUD.labelText = [[_selfSettingsController bundle] localizedStringForKey:@"LOAD_DATA" value:@"Loading Data" table:@"AlwaysiPodPlaySettings"];
	HUD.detailsLabelText = [[_selfSettingsController bundle] localizedStringForKey:@"PLZ_WAIT" value:@"Please wait..." table:@"AlwaysiPodPlaySettings"];
	HUD.labelFont = [UIFont fontWithName:@"Helvetica" size:24];
	HUD.detailsLabelFont = [UIFont fontWithName:@"Helvetica" size:18];
	HUD.tag = HUD_TAG;
	[HUD show:YES];
	[HUD release];
*/

	progressHUD = [[UIProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
	[progressHUD setText:@"Loading..."];
	[progressHUD show:YES];
//	[progressHUD showInView:window];//self.view];
	[progressHUD setAlpha:0.0f];
	CGAffineTransform affine = CGAffineTransformMakeScale (0.3, 0.3);
	[progressHUD setTransform: affine];
	[UIView beginAnimations: nil context: NULL];
	[UIView setAnimationDuration: 0.3];
	[progressHUD setAlpha:1.0f];
	affine = CGAffineTransformMakeScale (1.0, 1.0);
	[progressHUD setTransform: affine];
	[UIView commitAnimations];

	[self performSelector:@selector(loadInstalledAppData) withObject:nil afterDelay:0.1f];
/*
	NSThread *loadThread = [[NSThread alloc] initWithTarget:self selector:@selector(loadInstalledAppData) object:nil];
	[loadThread start];
	[loadThread release];
*/
}


- (void) loadInstalledAppData {
	[_list release];
	_list = nil;
	
	NSSet *set = [NSSet setWithArray:applicationDisplayIdentifiers()];
	NSArray *sortedArray = [[set allObjects] sortedArrayUsingFunction:compareDisplayNames context:NULL];
	
	_list = [sortedArray retain];

	[_tableView reloadData];
	
//	MBProgressHUD *HUD = (MBProgressHUD *)[window viewWithTag:HUD_TAG];
//	[HUD hide:YES];

	[UIView beginAnimations: nil context: NULL];
	[UIView setAnimationDuration: 0.3];
	[progressHUD setAlpha:0.0f];
	CGAffineTransform affine = CGAffineTransformMakeScale (1.5, 1.5);
	[progressHUD setTransform: affine];
	[UIView commitAnimations];
//	[progressHUD hide];
	[progressHUD release];
	progressHUD = nil;
}


- (id) view {
	if (__view)
		return __view;
	
	return _tableView;
}

- (id) _tableView {
	return _tableView;
}

- (id) navigationTitle {
	return _title;
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (id) tableView:(UITableView *)tableView titleForHeaderInSection:(int)section {
	return nil;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(int)section {
	if(!_list)
		return 0;
	
	return [_list count];
}

- (id) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	GSAppListCell *cell = (GSAppListCell *)[tableView dequeueReusableCellWithIdentifier:@"WhiteListCell"];
	if (!cell) 
		cell = [[[GSAppListCell alloc] initWithFrame:CGRectMake(0, 0, 100, 100) reuseIdentifier:@"WhiteListCell"] autorelease];
	
	cell.displayId = [_list objectAtIndex:indexPath.row];
	
	BOOL isWhiteList = NO;
	if ([[NSFileManager defaultManager] fileExistsAtPath:PREFERENCE_PATH]) {
		NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:PREFERENCE_PATH];
		
		if (data) {
			NSString *identifier = [_list objectAtIndex:indexPath.row];
			NSArray *whitelist = [data objectForKey:@"WhiteList"];
			
			if (whitelist != nil) {
				for (NSString *str in whitelist) {
					if ([identifier isEqualToString:str]) {
						isWhiteList = YES;
						break;
					}
				}
			}
		}
	}
	
	if (isWhiteList) {
		cell.blackListType = SNBlackListNormal;
	} else {
		cell.blackListType = SNBlackListNone;
	}
	
	if ([cell.displayId hasPrefix:@"com.apple.webapp"])
		cell.blackListType = SNBlackListForce;
	
	return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	GSAppListCell *cell = (GSAppListCell *)[tableView cellForRowAtIndexPath:indexPath];
	
	switch (cell.blackListType) {
		case SNBlackListNone:
			cell.blackListType = SNBlackListNormal;
			break;
		case SNBlackListForce:
			break;;
		case SNBlackListNormal:
		default:
			cell.blackListType = SNBlackListNone;
			break;
	}
	
	[tableView deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:YES];
	
	if (cell.blackListType == SNBlackListForce) return;
	
	NSString *identifier = [_list objectAtIndex:indexPath.row];
	NSMutableDictionary *data;
	if ([[NSFileManager defaultManager] fileExistsAtPath:PREFERENCE_PATH]) {
		data = [NSMutableDictionary dictionaryWithContentsOfFile:PREFERENCE_PATH];
	} else {
		data = [NSMutableDictionary dictionary];
	}
	
	NSMutableArray *whitelist = [[data objectForKey:@"WhiteList"] retain];
	if (whitelist == nil)
		whitelist = [[NSMutableArray alloc] init];
	
	if (cell.blackListType == SNBlackListNormal) {
		[whitelist addObject:identifier];
	} else {
		[whitelist removeObject:identifier];
	}
	
	[data setObject:whitelist forKey:@"WhiteList"];
	[whitelist release];
	
	
	[data writeToFile:PREFERENCE_PATH atomically:YES];
	
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("jp.r-plus.GrayScaleIcons.settingchanged"), NULL, NULL, true);
}

- (void) dealloc {
//	MBProgressHUD *HUD = (MBProgressHUD *)[window viewWithTag:HUD_TAG];
//	[HUD removeFromSuperview];
	
	[_tableView release];
	[_list release];
	[_title release];
	[__view release];
	
	[super dealloc];
}


@end


id $PSViewController$initForContentSize$(PSRootController *self, SEL _cmd, CGSize contentSize) {
	return [self init];
}

__attribute__((constructor))
static void aippInit() {
	if (![[PSViewController class] instancesRespondToSelector:@selector(initForContentSize:)])
		class_addMethod([PSViewController class], @selector(initForContentSize:), (IMP)$PSViewController$initForContentSize$, "@@:{ff}");
}



// vim:ft=objc
