//
//  MGLSnapshotModule.m
//  RCTMGL
//
//  Created by Nick Italiano on 12/1/17.
//  Copyright © 2017 Mapbox Inc. All rights reserved.
//

#import "MGLSnapshotModule.h"
#import "RCTMGLUtils.h"
#import "RNMBImageUtils.h"
@import Mapbox;

@implementation MGLSnapshotModule

RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

RCT_EXPORT_METHOD(takeSnap:(NSDictionary *)jsOptions
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MGLMapSnapshotOptions *options = [self _getOptions:jsOptions];
        __block MGLMapSnapshotter *snapshotter = [[MGLMapSnapshotter alloc] initWithOptions:options];

        [snapshotter startWithCompletionHandler:^(MGLMapSnapshot * _Nullable snapshot, NSError * _Nullable err) {         
            if (err != nil) {
                reject(@"takeSnap", @"Could not create snapshot", err);
                snapshotter = nil;
                return;
            }
            
            NSString *result = nil;
            if ([jsOptions[@"writeToDisk"] boolValue]) {
                result = [RNMBImageUtils createTempFile:snapshot.image];
            } else {
                result = [RNMBImageUtils createBase64:snapshot.image];
            }
            
            NSNumber *width = jsOptions[@"width"];
            NSNumber *height = jsOptions[@"height"];
            CLLocationCoordinate2D northeastLatLng = [snapshot coordinateForPoint:CGPointMake(width.floatValue, 0)];
            CLLocationCoordinate2D southwestLatLng = [snapshot coordinateForPoint:CGPointMake(0, height.floatValue)];
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setValue:result forKey:@"imageResult"];
            [dic setValue:@(southwestLatLng.longitude) forKey:@"southwestLongitude"];
            [dic setValue:@(southwestLatLng.latitude) forKey:@"southwestLatitude"];
            [dic setValue:@(northeastLatLng.longitude) forKey:@"northeastLongitude"];
            [dic setValue:@(northeastLatLng.latitude) forKey:@"northeastLatitude"];
            
            resolve(dic);
            snapshotter = nil;
        }];
    });
}

- (MGLMapSnapshotOptions *)_getOptions:(NSDictionary *)jsOptions
{
    MGLMapCamera *camera = [[MGLMapCamera alloc] init];
    
    camera.pitch = [jsOptions[@"pitch"] doubleValue];
    camera.heading = [jsOptions[@"heading"] doubleValue];
    
    if (jsOptions[@"centerCoordinate"] != nil) {
        camera.centerCoordinate = [RCTMGLUtils fromFeature:jsOptions[@"centerCoordinate"]];
    }
    
    NSNumber *width = jsOptions[@"width"];
    NSNumber *height = jsOptions[@"height"];
    CGSize size = CGSizeMake([width doubleValue], [height doubleValue]);
    
    NSURL *styleURL = [NSURL URLWithString:jsOptions[@"styleURL"]];
    if (jsOptions[@"styleJson"] != nil) {
        styleURL = [[NSURL fileURLWithPath: NSTemporaryDirectory()] URLByAppendingPathComponent:@"styleJson.json"];
        if ([jsOptions[@"styleJson"] isKindOfClass:[NSString class]]) {
            [jsOptions[@"styleJson"] writeToURL:styleURL atomically:true encoding:NSUTF8StringEncoding error:nil];
        }
    }
    MGLMapSnapshotOptions *options = [[MGLMapSnapshotOptions alloc] initWithStyleURL:styleURL
                                                                   camera:camera
                                                                   size:size];

    if (jsOptions[@"zoomLevel"] != nil) {
        options.zoomLevel = [jsOptions[@"zoomLevel"] doubleValue];
    }
    
    if (jsOptions[@"bounds"] != nil) {
        options.coordinateBounds = [RCTMGLUtils fromFeatureCollection:jsOptions[@"bounds"]];
    }

    return options;
}

@end
