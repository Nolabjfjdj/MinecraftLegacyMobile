#import "LegacyEngineBridge.h"

#include <cstdint>

namespace {

class LegacyEngineCore {
public:
    void start() {
        running_ = true;
    }

    void stop() {
        running_ = false;
    }

    bool isRunning() const {
        return running_;
    }

    void advanceFrame() {
        if (running_) {
            ++frameCount_;
        }
    }

    std::uint64_t frameCount() const {
        return frameCount_;
    }

private:
    bool running_ = false;
    std::uint64_t frameCount_ = 0;
};

}

@implementation LegacyEngineBridge {
    LegacyEngineCore core_;
}

- (NSString *)statusMessage {
    if (core_.isRunning()) {
        return @"Noyau C++ initialisé. Le moteur Minecraft n’est pas encore intégré.";
    }

    return @"Noyau C++ arrêté. Le moteur Minecraft n’est pas encore intégré.";
}

- (NSInteger)frameCount {
    return static_cast<NSInteger>(core_.frameCount());
}

- (BOOL)isRunning {
    return core_.isRunning();
}

- (void)start {
    core_.start();
}

- (void)stop {
    core_.stop();
}

- (void)advanceFrame {
    core_.advanceFrame();
}

@end
