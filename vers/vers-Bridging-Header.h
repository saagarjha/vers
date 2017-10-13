//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

CFDictionaryRef _CFCopySystemVersionDictionary();
CFStringRef ASI_CopyFormattedSerialNumber();

@interface SDBuildInfo
+ (BOOL)currentBuildIsSeed;
@end

@interface DVTToolsVersion
- (NSString *)name;
@end

@interface DVTBuildVersion
- (NSString *)name;
@end

@interface DVTToolsInfo
@property(readonly) unsigned long long toolsBetaVersion;
@property(readonly) BOOL isBeta;
@property(readonly) DVTBuildVersion *toolsBuildVersion;
@property(readonly) DVTToolsVersion *toolsVersion;
+ (DVTToolsInfo *)toolsInfo;
@end

NS_ASSUME_NONNULL_END
