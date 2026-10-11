#pragma once

#include <cstddef>
#include <cstdint>
#include <vector>

namespace minecraftlegacy {

enum class BlockType : std::uint8_t {
    Air = 0,
    Stone,
    Dirt,
    Grass
};

class LegacyVoxelWorld {
public:
    static constexpr int Width = 32;
    static constexpr int Height = 64;
    static constexpr int Depth = 32;

    explicit LegacyVoxelWorld(std::uint32_t seed = 0x4C4345U)
        : seed_(seed), blocks_(static_cast<std::size_t>(Width * Height * Depth), BlockType::Air) {
        generateTerrain();
    }

    BlockType getBlock(int x, int y, int z) const {
        if (!inBounds(x, y, z)) {
            return BlockType::Air;
        }
        return blocks_[indexOf(x, y, z)];
    }

    bool setBlock(int x, int y, int z, BlockType block) {
        if (!inBounds(x, y, z)) {
            return false;
        }
        blocks_[indexOf(x, y, z)] = block;
        return true;
    }

    int surfaceHeightAt(int x, int z) const {
        if (x < 0 || x >= Width || z < 0 || z >= Depth) {
            return -1;
        }
        return terrainHeight(x, z);
    }

    std::size_t solidBlockCount() const {
        std::size_t count = 0;
        for (const BlockType block : blocks_) {
            if (block != BlockType::Air) {
                ++count;
            }
        }
        return count;
    }

private:
    std::uint32_t seed_;
    std::vector<BlockType> blocks_;

    static bool inBounds(int x, int y, int z) {
        return x >= 0 && x < Width &&
               y >= 0 && y < Height &&
               z >= 0 && z < Depth;
    }

    static std::size_t indexOf(int x, int y, int z) {
        return (static_cast<std::size_t>(y) * Depth + static_cast<std::size_t>(z)) * Width
             + static_cast<std::size_t>(x);
    }

    std::uint32_t noiseAt(int x, int z) const {
        std::uint32_t value = seed_;
        value ^= static_cast<std::uint32_t>(x) * 0x9E3779B9U;
        value ^= static_cast<std::uint32_t>(z) * 0x85EBCA6BU;
        value ^= value >> 16U;
        value *= 0x7FEB352DU;
        value ^= value >> 15U;
        value *= 0x846CA68BU;
        value ^= value >> 16U;
        return value;
    }

    int terrainHeight(int x, int z) const {
        const int broad = static_cast<int>(noiseAt(x / 4, z / 4) % 9U) - 4;
        const int detail = static_cast<int>(noiseAt(x, z) % 3U) - 1;
        return 24 + broad + detail;
    }

    void generateTerrain() {
        for (int x = 0; x < Width; ++x) {
            for (int z = 0; z < Depth; ++z) {
                const int surface = terrainHeight(x, z);
                for (int y = 0; y <= surface; ++y) {
                    BlockType block = BlockType::Stone;
                    if (y == surface) {
                        block = BlockType::Grass;
                    } else if (y >= surface - 3) {
                        block = BlockType::Dirt;
                    }
                    blocks_[indexOf(x, y, z)] = block;
                }
            }
        }
    }
};

}
