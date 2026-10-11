#import "LegacyEngineBridge.h"

#include <cstdint>

namespace {

class LegacyEngineCore {
public:
    void advanceFrame() {
        ++frameCount_;
    }

    std::uint64_t frameCount() const {
        return frameCount_;
    }

private:
    std::uint64_t frameCount_ = 0;
};

}

@implementation LegacyEngineBridge {
    LegacyEngineCore core_;
}

- (NSString *)statusMessage {
    return @"Pont natif C++ compilé. Le moteur Minecraft n’est pas encore intégré.";
}

- (NSInteger)frameCount {
    return static_cast<NSInteger>(core_.frameCount());
}

- (void)advanceFrame {
    core_.advanceFrame();
}

@end
