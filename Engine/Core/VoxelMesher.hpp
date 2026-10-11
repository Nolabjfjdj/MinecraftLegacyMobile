#pragma once

#include "LegacyVoxelWorld.hpp"

#include <array>
#include <cstdint>
#include <vector>

namespace minecraftlegacy {

struct VoxelMeshVertex {
    float x;
    float y;
    float z;
    float normalX;
    float normalY;
    float normalZ;
    std::uint8_t blockType;
};

struct VoxelMesh {
    std::vector<VoxelMeshVertex> vertices;
    std::vector<std::uint32_t> indices;

    bool isEmpty() const {
        return indices.empty();
    }

    std::size_t triangleCount() const {
        return indices.size() / 3;
    }
};

class VoxelMesher {
public:
    VoxelMesh build(const LegacyVoxelWorld& world) const {
        VoxelMesh mesh;

        for (int y = 0; y < LegacyVoxelWorld::Height; ++y) {
            for (int z = 0; z < LegacyVoxelWorld::Depth; ++z) {
                for (int x = 0; x < LegacyVoxelWorld::Width; ++x) {
                    const BlockType block = world.getBlock(x, y, z);
                    if (block == BlockType::Air) {
                        continue;
                    }

                    for (const Face& face : Faces) {
                        const int nx = x + face.neighborX;
                        const int ny = y + face.neighborY;
                        const int nz = z + face.neighborZ;
                        if (world.getBlock(nx, ny, nz) != BlockType::Air) {
                            continue;
                        }
                        appendFace(mesh, x, y, z, block, face);
                    }
                }
            }
        }

        return mesh;
    }

private:
    struct Face {
        int neighborX;
        int neighborY;
        int neighborZ;
        float normalX;
        float normalY;
        float normalZ;
        std::array<std::array<float, 3>, 4> corners;
    };

    static constexpr std::array<Face, 6> Faces{{
        { 1, 0, 0, 1, 0, 0, {{{1,0,0},{1,1,0},{1,1,1},{1,0,1}}}},
        {-1, 0, 0,-1, 0, 0, {{{0,0,1},{0,1,1},{0,1,0},{0,0,0}}}},
        { 0, 1, 0, 0, 1, 0, {{{0,1,1},{1,1,1},{1,1,0},{0,1,0}}}},
        { 0,-1, 0, 0,-1, 0, {{{0,0,0},{1,0,0},{1,0,1},{0,0,1}}}},
        { 0, 0, 1, 0, 0, 1, {{{1,0,1},{1,1,1},{0,1,1},{0,0,1}}}},
        { 0, 0,-1, 0, 0,-1, {{{0,0,0},{0,1,0},{1,1,0},{1,0,0}}}}
    }};

    static void appendFace(
        VoxelMesh& mesh,
        int x,
        int y,
        int z,
        BlockType block,
        const Face& face
    ) {
        const auto first = static_cast<std::uint32_t>(mesh.vertices.size());
        const auto blockValue = static_cast<std::uint8_t>(block);

        for (const auto& corner : face.corners) {
            mesh.vertices.push_back({
                static_cast<float>(x) + corner[0],
                static_cast<float>(y) + corner[1],
                static_cast<float>(z) + corner[2],
                face.normalX,
                face.normalY,
                face.normalZ,
                blockValue
            });
        }

        mesh.indices.insert(mesh.indices.end(), {
            first, first + 1, first + 2,
            first, first + 2, first + 3
        });
    }
};

}
