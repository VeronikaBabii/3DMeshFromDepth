//
//  PointsSaver.swift
//  3DMeshFromDepth
//
//  Created by Veronika Tsukat on 08.08.2022.
//

import Foundation

class PointsSaver {
    
    static let shared = PointsSaver()
    
    func save(text: String, withFileName fileName: String) {
        let filePath = FileManager.default.temporaryDirectory.appendingPathComponent("\(fileName)")
        if !FileManager.default.fileExists(atPath: filePath.path) {
            FileManager.default.createFile(atPath: filePath.path, contents: text.data(using: .utf8), attributes: nil)
        }
        print("\(fileName) was saved successful")
    }
}
