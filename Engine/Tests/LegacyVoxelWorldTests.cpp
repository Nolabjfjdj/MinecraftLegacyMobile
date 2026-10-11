#include "LegacyVoxelWorld.hpp"

#include <cassert>

int main() {
    using minecraftlegacy::BlockType;
    using minecraftlegacy::LegacyVoxelWorld;

    LegacyVoxelWorld world;
    assert(world.solidBlockCount() > 0);

    const int surface = world.surfaceHeightAt(8, 8);
    assert(surface >= 0);
    assert(world.getBlock(8, surface, 8) == BlockType::Grass);
    assert(world.getBlock(8, surface - 1, 8) == BlockType::Dirt);
    assert(world.getBlock(8, 0, 8) == BlockType::Stone);
    assert(world.getBlock(8, surface + 1, 8) == BlockType::Air);

    assert(world.getBlock(-1, surface, 8) == BlockType::Air);
    assert(world.getBlock(8, LegacyVoxelWorld::Height, 8) == BlockType::Air);
    assert(world.surfaceHeightAt(-1, 8) == -1);

    const auto before = world.solidBlockCount();
    assert(world.setBlock(8, surface, 8, BlockType::Air));
    assert(world.getBlock(8, surface, 8) == BlockType::Air);
    assert(world.solidBlockCount() == before - 1);

    assert(!world.setBlock(-1, 0, 0, BlockType::Stone));
    assert(!world.setBlock(0, LegacyVoxelWorld::Height, 0, BlockType::Stone));

    LegacyVoxelWorld sameSeed;
    assert(sameSeed.surfaceHeightAt(8, 8) == surface);
    assert(sameSeed.getBlock(8, surface, 8) == BlockType::Grass);

    LegacyVoxelWorld otherSeed(12345U);
    assert(otherSeed.surfaceHeightAt(8, 8) != surface);

    return 0;
}
