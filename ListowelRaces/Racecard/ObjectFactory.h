//
//  ObjectFactory.h
//  ListowelSwift
//
//  Created by Jack McAuliffe on 30/03/2016.
//  Copyright © 2016 Jack McAuliffe. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Firebase;
#define __NON_NULL nonnull

@interface ObjectFactory : NSObject


@property(strong, nonatomic) NSObject* model;

@property(strong, nonatomic) Class modelClass;

- (instancetype)initWithClass:(Class)modelC;

- (id)createFromSnapshot:(FIRDataSnapshot*)snapShot;

@end
