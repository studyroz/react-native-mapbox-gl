//
//  RCTMGLRasterSource.m
//  RCTMGL
//
//  Created by Nick Italiano on 9/25/17.
//  Copyright © 2017 Mapbox Inc. All rights reserved.
//

#import "RCTMGLRasterSource.h"

@implementation RCTMGLRasterSource

- (nullable MGLSource*)makeSource
{
    if (self.url != nil) {
        NSURL *url = [NSURL URLWithString:self.url];
        if (self.tileSize != nil) {
            return [[MGLRasterTileSource alloc] initWithIdentifier:self.id configurationURL:url tileSize:[self.tileSize floatValue]];
        }
        return [[MGLRasterTileSource alloc] initWithIdentifier:self.id configurationURL:url];
    }
    return [[MGLRasterTileSource alloc] initWithIdentifier:self.id tileURLTemplates:self.tileUrlTemplates options:[self getOptions]];
}

- (NSDictionary<MGLTileSourceOption,id> *)getOptions {
    NSMutableDictionary<MGLTileSourceOption, id> *options = [[NSMutableDictionary alloc] initWithDictionary:[super getOptions]];
    
    if (self.tileSize != nil) {
        options[MGLTileSourceOptionTileSize] = _tileSize;
    }
    
    if (self.sourceBounds != nil && self.sourceBounds.count == 2 && self.sourceBounds[0].count == 2 && self.sourceBounds[1].count == 2) {
        CLLocationCoordinate2D ne;
        ne.longitude = self.sourceBounds[0][0].doubleValue;
        ne.latitude = self.sourceBounds[0][1].doubleValue;
        CLLocationCoordinate2D sw;
        sw.longitude = self.sourceBounds[1][0].doubleValue;
        sw.latitude = self.sourceBounds[1][1].doubleValue;
        
        MGLCoordinateBounds bounds;
        bounds.ne = ne;
        bounds.sw = sw;
        options[MGLTileSourceOptionCoordinateBounds] = [NSValue valueWithMGLCoordinateBounds:bounds];
    }
    
    return options;
}

@end
