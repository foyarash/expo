//  Copyright © 2021 650 Industries. All rights reserved.

#import <EXUpdates/EXUpdatesSelectionPolicies.h>

#if __has_include(<EXUpdates/EXUpdates-Swift.h>)
#import <EXUpdates/EXUpdates-Swift.h>
#else
#import "EXUpdates-Swift.h"
#endif

@import EXManifests;

NS_ASSUME_NONNULL_BEGIN

/**
 * Utility methods used by multiple [SelectionPolicy] subclasses.
 */
@implementation EXUpdatesSelectionPolicies

+ (BOOL)doesUpdate:(EXUpdatesUpdate *)update matchFilters:(nullable NSDictionary *)filters
{
  if (!filters || !update.manifest.rawManifestJSON) {
    return YES;
  }
  
  NSDictionary *metadata = update.manifest.rawManifestJSON[@"metadata"];
  if (!metadata || ![metadata isKindOfClass:[NSDictionary class]]) {
    return YES;
  }
  
  // create lowercase copy for case-insensitive search
  NSMutableDictionary *metadataLCKeys = [NSMutableDictionary dictionaryWithCapacity:metadata.count];
  [metadata enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    if ([key isKindOfClass:[NSString class]]) {
      metadataLCKeys[((NSString *)key).lowercaseString] = obj;
    }
  }];
  
  __block BOOL passes = YES;
  [filters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    id valueFromManifest = metadataLCKeys[key];
    if (valueFromManifest) {
      passes = [obj isEqual:valueFromManifest];
    }
    
    // once an update fails one filter, break early; we don't need to check the rest
    if (!passes) {
      *stop = YES;
    }
  }];
  
  return passes;
}

@end

NS_ASSUME_NONNULL_END
