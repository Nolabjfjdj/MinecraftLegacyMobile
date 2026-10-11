#pragma once

#include <cstdint>

namespace minecraftlegacy {

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
