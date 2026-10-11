#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LegacyEngineBridge : NSObject

- (NSString *)statusMessage;
- (NSInteger)frameCount;
- (void)advanceFrame;

@end

NS_ASSUME_NONNULL_END
