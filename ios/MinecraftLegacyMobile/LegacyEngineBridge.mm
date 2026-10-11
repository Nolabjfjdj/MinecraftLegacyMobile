#import "LegacyEngineBridge.h"

#include "../../Engine/Core/LegacyEngineCore.hpp"
#include "../../Engine/Core/LegacyVoxelWorld.hpp"
#include "../../Engine/Core/VoxelMesher.hpp"

#include <cstdint>
#include <vector>

@implementation LegacyEngineBridge {
    minecraftlegacy::LegacyEngineCore core_;
    minecraftlegacy::LegacyVoxelWorld world_;
    std::vector<float> vertexData_;
    std::vector<std::uint32_t> indexData_;
    NSUInteger vertexCount_;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        const minecraftlegacy::VoxelMesh mesh = minecraftlegacy::VoxelMesher().build(world_);
        vertexData_.reserve(mesh.vertices.size() * 7);
        for (const minecraftlegacy::VoxelMeshVertex& vertex : mesh.vertices) {
            vertexData_.push_back(vertex.x);
            vertexData_.push_back(vertex.y);
            vertexData_.push_back(vertex.z);
            vertexData_.push_back(vertex.normalX);
            vertexData_.push_back(vertex.normalY);
            vertexData_.push_back(vertex.normalZ);
            vertexData_.push_back(static_cast<float>(vertex.blockType));
        }
        indexData_ = mesh.indices;
        vertexCount_ = mesh.vertices.size();
    }
    return self;
}

- (NSString *)statusMessage {
    if (core_.isRunning()) {
        return @"Noyau C++ actif. Terrain voxel généré et maillage préparé pour Metal.";
    }

    return @"Noyau C++ en pause. Terrain voxel prêt pour le rendu Metal.";
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

- (NSData *)meshVertexData {
    return [NSData dataWithBytes:vertexData_.data() length:vertexData_.size() * sizeof(float)];
}

- (NSData *)meshIndexData {
    return [NSData dataWithBytes:indexData_.data() length:indexData_.size() * sizeof(std::uint32_t)];
}

- (NSUInteger)meshVertexCount {
    return vertexCount_;
}

- (NSUInteger)meshIndexCount {
    return indexData_.size();
}

@end
