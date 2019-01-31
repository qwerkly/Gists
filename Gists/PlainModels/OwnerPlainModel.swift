//
//  OwnerPlainModel.swift
//  Gists
//
//  Created by Ivan Babich on 26/01/2019.
//  Copyright © 2019 Ivan Babich. All rights reserved.
//

import Foundation

struct OwnerPlainModel: Decodable {
    
    let avatarURL: URL
    let url: URL
    var name: String?
    var avatarData: Data?
    let gistsURL: String
    
    enum CodingKeys: String, CodingKey {
        case avatarURL = "avatar_url"
        case url
        case name
        case avatarData
        case gistsURL = "gists_url"
    }
}
