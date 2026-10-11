#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LegacyEngineBridge : NSObject

- (NSString *)statusMessage;
- (NSInteger)frameCount;
- (BOOL)isRunning;
- (void)start;
- (void)stop;
- (void)advanceFrame;
- (NSData *)meshVertexData;
- (NSData *)meshIndexData;
- (NSUInteger)meshVertexCount;
- (NSUInteger)meshIndexCount;

@end

NS_ASSUME_NONNULL_END
