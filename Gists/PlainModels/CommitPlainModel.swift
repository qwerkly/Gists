//
//  CommitPlainModel.swift
//  Gists
//
//  Created by Ivan Babich on 26/01/2019.
//  Copyright © 2019 Ivan Babich. All rights reserved.
//

import Foundation

struct CommitPlainModel: Decodable {
    
    let changeStatus: ChangeStatusPlainModel
    let version: String
    
    enum CodingKeys: String, CodingKey {
        case changeStatus = "change_status"
        case version
    }
    
    struct ChangeStatusPlainModel: Decodable {
        let additions: UInt
        let deletions: UInt
    }
}
