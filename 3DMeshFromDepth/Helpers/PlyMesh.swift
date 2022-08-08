//
//  PlyMesh.swift
//  3DMeshFromDepth
//
//  Created by Veronika Babii on 16.02.2022.
//

import Foundation

class PlyMesh {
    
    static func writeToFile(pointsCpuBuffer: inout [PointCPU], pointsCount: Int) throws {
        let fileName = "scan"
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let date = Date().description(with: .current)
        
        let plyFile = documentsDirectory.appendingPathComponent("\(fileName)_\(date).ply", isDirectory: false)
        FileManager.default.createFile(atPath: plyFile.path, contents: nil, attributes: nil)
        
        let format = "binary_little_endian"
        
        var headersString = ""
        let headers = [
            "ply",
            "comment Created by SceneX (IOS)",
            "format \(format) 1.0",
            "element vertex \(pointsCount)",
            "property float x",
            "property float y",
            "property float z",
            "property uchar red",
            "property uchar green",
            "property uchar blue",
            "property uchar alpha",
            "element face 0",
            "property list uchar int vertex_indices",
            "end_header"]
        
        for header in headers { headersString += header + "\r\n" }
        try headersString.write(to: plyFile, atomically: true, encoding: .ascii)
        
        try writeBinary(file: plyFile, format: format, pointsCPUBuffer: &pointsCpuBuffer)
    }
    
    private static func writeBinary(file: URL, format: String, pointsCPUBuffer: inout [PointCPU]) throws -> Void {
        let fileHandle = try! FileHandle(forWritingTo: file)
        fileHandle.seekToEndOfFile()
        var data = Data()
        
        for point in pointsCPUBuffer {
            
            var x = point.position.x.bitPattern.littleEndian
            data.append(withUnsafePointer(to: &x) {
                Data(buffer: UnsafeBufferPointer(start: $0, count: 1))
            })
            
            var y = point.position.y.bitPattern.littleEndian
            data.append(withUnsafePointer(to: &y) {
                Data(buffer: UnsafeBufferPointer(start: $0, count: 1))
            })
            
            var z = point.position.z.bitPattern.littleEndian
            data.append(withUnsafePointer(to: &z) {
                Data(buffer: UnsafeBufferPointer(start: $0, count: 1))
            })
            
            let colors = point.color
            var red = self.arrangeColorByte(color: colors.x).littleEndian
            data.append(withUnsafePointer(to: &red) {
                Data(buffer: UnsafeBufferPointer(start: $0, count: 1))
            })
            
            var green = self.arrangeColorByte(color: colors.y).littleEndian
            data.append(withUnsafePointer(to: &green) {
                Data(buffer: UnsafeBufferPointer(start: $0, count: 1))
            })
            
            var blue = self.arrangeColorByte(color: colors.z).littleEndian
            data.append(withUnsafePointer(to: &blue) {
                Data(buffer: UnsafeBufferPointer(start: $0, count: 1))
            })
            
            var alpha = UInt8(255).littleEndian
            data.append(withUnsafePointer(to: &alpha) {
                Data(buffer: UnsafeBufferPointer(start: $0, count: 1))
            })
        }
        fileHandle.write(data)
        fileHandle.closeFile()
    }
    
    private static func arrangeColorByte(color: simd_float1) -> UInt8 {
        let absColor = abs(Int16(color))
        return absColor <= 255 ? UInt8(absColor) : UInt8(255)
    }
}
