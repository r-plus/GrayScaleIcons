@interface SBApplicationIcon : NSObject
- (id)applicationBundleID;
@end

static NSArray *exceptApplication;

%hook SBApplicationIcon

- (id)generateIconImage:(int)image
{
	for (NSString *appID in exceptApplication) //WhiteList
		if ([[self applicationBundleID] isEqualToString:appID])
			return %orig;
	
	if (image!=2) //except small icon. ( e.g. spotlight )
		return %orig;

	return %orig(4);
}

%end

static void LoadSettings()
{	
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/jp.r-plus.GrayScaleIcons.plist"];
	exceptApplication = [dict objectForKey:@"WhiteList"];
	[exceptApplication retain];
	id tmp = [dict objectForKey:@"Enabled"];
	BOOL isGrayScale = tmp ? [tmp boolValue] : YES;
	if (isGrayScale)
		%init;
}

%ctor
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	LoadSettings();
	[pool release];
}