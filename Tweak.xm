%hook SBApplicationIcon
- (id)generateIconImage:(int)image { return %orig(4); }
%end