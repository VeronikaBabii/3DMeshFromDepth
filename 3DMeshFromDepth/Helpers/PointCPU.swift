//
//  PointCPU.swift
//  3DMeshFromDepth
//
//  Created by Veronika Babii on 16.02.2022.
//

import Foundation

class PointCPU {
   var position: simd_float3
   var color: simd_float3
   
    init(position: simd_float3, color: simd_float3) {
       self.position = position
       self.color = color * 255
   }
}
