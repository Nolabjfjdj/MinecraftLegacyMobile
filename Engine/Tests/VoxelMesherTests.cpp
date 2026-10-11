#include "LegacyVoxelWorld.hpp"
#include "VoxelMesher.hpp"

#include <cassert>
#include <cstdint>

int main() {
    using minecraftlegacy::BlockType;
    using minecraftlegacy::LegacyVoxelWorld;
    using minecraftlegacy::VoxelMesher;

    LegacyVoxelWorld world;
    VoxelMesher mesher;
    const auto terrainMesh = mesher.build(world);

    assert(!terrainMesh.isEmpty());
    assert(terrainMesh.vertices.size() % 4 == 0);
    assert(terrainMesh.indices.size() % 6 == 0);
    assert(terrainMesh.triangleCount() == terrainMesh.indices.size() / 3);

    for (const std::uint32_t index : terrainMesh.indices) {
        assert(index < terrainMesh.vertices.size());
    }

    for (const auto& vertex : terrainMesh.vertices) {
        assert(vertex.blockType != static_cast<std::uint8_t>(BlockType::Air));
        const float normalLength =
            vertex.normalX * vertex.normalX +
            vertex.normalY * vertex.normalY +
            vertex.normalZ * vertex.normalZ;
        assert(normalLength == 1.0F);
    }

    LegacyVoxelWorld singleBlock;
    for (int y = 0; y < LegacyVoxelWorld::Height; ++y) {
        for (int z = 0; z < LegacyVoxelWorld::Depth; ++z) {
            for (int x = 0; x < LegacyVoxelWorld::Width; ++x) {
                singleBlock.setBlock(x, y, z, BlockType::Air);
            }
        }
    }

    assert(singleBlock.setBlock(4, 5, 6, BlockType::Stone));
    const auto cubeMesh = mesher.build(singleBlock);
    assert(cubeMesh.vertices.size() == 24);
    assert(cubeMesh.indices.size() == 36);
    assert(cubeMesh.triangleCount() == 12);

    singleBlock.setBlock(5, 5, 6, BlockType::Dirt);
    const auto twoBlockMesh = mesher.build(singleBlock);
    assert(twoBlockMesh.vertices.size() == 40);
    assert(twoBlockMesh.indices.size() == 60);
    assert(twoBlockMesh.triangleCount() == 20);

    singleBlock.setBlock(4, 5, 6, BlockType::Air);
    singleBlock.setBlock(5, 5, 6, BlockType::Air);
    assert(mesher.build(singleBlock).isEmpty());

    return 0;
}
