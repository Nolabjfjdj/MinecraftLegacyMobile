#import "LegacyEngineBridge.h"

#include "../../Engine/Core/LegacyEngineCore.hpp"

@implementation LegacyEngineBridge {
    minecraftlegacy::LegacyEngineCore core_;
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
