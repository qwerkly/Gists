//
//  FilePlainModel.swift
//  Gists
//
//  Created by Ivan Babich on 28/01/2019.
//  Copyright © 2019 Ivan Babich. All rights reserved.
//

import Foundation

struct FilePlainModel: Decodable {
    
    let fileName: String
    let type: String
    let language: String?
    let rawURL: URL
    let size: UInt
    
    enum CodingKeys: String, CodingKey {
        case fileName = "filename"
        case type
        case language
        case rawURL = "raw_url"
        case size
    }
}
