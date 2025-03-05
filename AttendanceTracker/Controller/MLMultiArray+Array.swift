//
//  MLMultiArray+Array.swift
//  AttendanceTracker
//
//  Created by Ansh Hardaha on 2025/02/23.
//

import CoreML

extension MLMultiArray {
    func toArray() -> [Float] {
        return (0..<self.count).map { i in
            return self[i].floatValue
        }
    }
}
