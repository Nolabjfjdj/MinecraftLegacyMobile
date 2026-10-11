#include "LegacyEngineCore.hpp"

#include <cassert>

int main() {
    minecraftlegacy::LegacyEngineCore core;

    assert(!core.isRunning());
    assert(core.frameCount() == 0);

    core.advanceFrame();
    assert(core.frameCount() == 0);

    core.start();
    assert(core.isRunning());

    core.advanceFrame();
    core.advanceFrame();
    assert(core.frameCount() == 2);

    core.stop();
    assert(!core.isRunning());

    core.advanceFrame();
    assert(core.frameCount() == 2);

    core.start();
    core.advanceFrame();
    assert(core.frameCount() == 3);

    core.stop();
    assert(!core.isRunning());

    return 0;
}
