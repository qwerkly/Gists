//
//  GistPlainModel.swift
//  Gists
//
//  Created by Ivan Babich on 25/01/2019.
//  Copyright © 2019 Ivan Babich. All rights reserved.
//

import Foundation

struct GistPlainModel: Decodable {
    
    let commitsUrl: URL
    var owner: OwnerPlainModel
    let description: String?
    let files: [String : FilePlainModel]
    var commits: [CommitPlainModel]?
    
    enum CodingKeys: String, CodingKey {
        case commitsUrl = "commits_url"
        case owner
        case description
        case files
        case commits
    }
}
