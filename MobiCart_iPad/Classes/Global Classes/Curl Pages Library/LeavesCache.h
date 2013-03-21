//
//  LeavesCache.h
//  Reader
//
//  Created by Mobicart on 5/12/10.
//  Copyright Mobicart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LeavesView.h"


@protocol LeavesViewDataSource;

@interface LeavesCache : NSObject {
	NSMutableDictionary *pageCache;
	id<LeavesViewDataSource> dataSource;
	CGSize pageSize;
}

@property (assign) CGSize pageSize;
@property (assign) id<LeavesViewDataSource> dataSource;

- (id) initWithPageSize:(CGSize)aPageSize;
- (CGImageRef) cachedImageForPageIndex:(NSUInteger)pageIndex;
- (void) precacheImageForPageIndex:(NSUInteger)pageIndex;
- (void) minimizeToPageIndex:(NSUInteger)pageIndex viewMode:(LeavesViewMode)viewMode;
- (void) flush;

@end
