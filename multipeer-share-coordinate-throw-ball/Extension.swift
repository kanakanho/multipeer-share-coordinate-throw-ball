//
//  Extension.swift
//  multipeer-share-coordinate-throw-ball
//
//  Created by blueken on 2024/12/27.
//

import ARKit

extension SIMD4 {
    var xyz: SIMD3<Scalar> {
        self[SIMD3(0, 1, 2)]
    }
}

extension simd_float3 {
    var list: [Float] {
        return [x, y, z]
    }
}

extension simd_float4x4 {
    var position: SIMD3<Float> {
        self.columns.3.xyz
    }
    
    init?(floatListStr: [String]) {
        let values = floatListStr.compactMap(Float.init)
        if values.count != 16 { return nil }
        
        self.init([
            SIMD4<Float>(values[0], values[1], values[2], values[3]),
            SIMD4<Float>(values[4], values[5], values[6], values[7]),
            SIMD4<Float>(values[8], values[9], values[10], values[11]),
            SIMD4<Float>(values[12], values[13], values[14], values[15])
        ])
    }
    
    var floatList: [Float] {
        return [
            self.columns.0.x, self.columns.0.y, self.columns.0.z, self.columns.0.w,
            self.columns.1.x, self.columns.1.y, self.columns.1.z, self.columns.1.w,
            self.columns.2.x, self.columns.2.y, self.columns.2.z, self.columns.2.w,
            self.columns.3.x, self.columns.3.y, self.columns.3.z, self.columns.3.w
        ]
     }
}
