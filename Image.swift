//
//  Image.swift
//  UserLocation
//
//  Created by Mohammed Abdullah Alotaibi on 11/12/2022.
//

import Foundation

class Image {
    var filename: String
    var id: String

    init(filename: String, id: String) {
        self.filename = filename
        self.id = id
    }

    init() {
        self.filename = ""
        self.id = "0"
    }
}
