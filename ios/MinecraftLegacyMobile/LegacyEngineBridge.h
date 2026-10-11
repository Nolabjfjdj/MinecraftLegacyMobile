#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LegacyEngineBridge : NSObject

- (NSString *)statusMessage;
- (NSInteger)frameCount;
- (BOOL)isRunning;
- (void)start;
- (void)stop;
- (void)advanceFrame;

@end

NS_ASSUME_NONNULL_END
