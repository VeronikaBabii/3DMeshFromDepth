//
//  Texture.swift
//  3DMeshFromDepth
//
//  Created by Veronika Babii on 18.02.2022.
//

import MetalKit

protocol Resource {
    associatedtype Element
}

struct Texture: Resource {
    typealias Element = Any
    
    let texture: MTLTexture
    let index: Int
}
