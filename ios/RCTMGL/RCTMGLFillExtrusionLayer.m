//
//  RCTMGLFillExtrusionLayer.m
//  RCTMGL
//
//  Created by Nick Italiano on 9/15/17.
//  Copyright © 2017 Mapbox Inc. All rights reserved.
//

#import "RCTMGLFillExtrusionLayer.h"
#import "RCTMGLStyle.h"
#import <React/RCTLog.h>

@implementation RCTMGLFillExtrusionLayer

- (void)updateFilter:(NSPredicate *)predicate
{
    @try {
        ((MGLFillExtrusionStyleLayer *) self.styleLayer).predicate = predicate;
    }
    @catch (NSException* exception) {
        RCTLogError(@"Invalid predicate: %@ on layer %@ - Name: %@ reason: %@", predicate, self, exception.name, exception.reason);
    }
}

- (void)setSourceLayerID:(NSString *)sourceLayerID
{
    _sourceLayerID = sourceLayerID;
    
    if (self.styleLayer != nil) {
        ((MGLFillExtrusionStyleLayer*) self.styleLayer).sourceLayerIdentifier = _sourceLayerID;
    }
}

- (void)addedToMap
{
    NSPredicate *filter = [self buildFilters];
    if (filter != nil) {
        [self updateFilter:filter];
    }
}

- (MGLFillExtrusionStyleLayer*)makeLayer:(MGLStyle*)style
{
    MGLSource *source = [style sourceWithIdentifier:self.sourceID];
    MGLFillExtrusionStyleLayer *layer = [[MGLFillExtrusionStyleLayer alloc] initWithIdentifier:self.id source:source];
    layer.sourceLayerIdentifier = _sourceLayerID;
    return layer;
}

- (void)addStyles
{
    RCTMGLStyle *style = [[RCTMGLStyle alloc] initWithMGLStyle:self.style];
    style.bridge = self.bridge;
    [style fillExtrusionLayer:(MGLFillExtrusionStyleLayer*)self.styleLayer withReactStyle:self.reactStyle];
}

@end
