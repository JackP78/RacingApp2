//
//  ObjectFactory.m
//  ListowelSwift
//
//  Created by Jack McAuliffe on 30/03/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

#import "ObjectFactory.h"

@implementation ObjectFactory

- (instancetype)initWithClass:(Class)modelC {
    self = [super init];
    if (self != nil) {
        self.modelClass = modelC;
    }
    return self;
}

- (id)createFromSnapshot:(FIRDataSnapshot *)snapShot {
    id model = [[self.modelClass alloc] init];
    [model setValuesForKeysWithDictionary:snapShot.value];
    return model;
}

@end
