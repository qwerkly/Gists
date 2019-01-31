//
//  PublicGistsViewModel.swift
//  Gists
//
//  Created by Ivan Babich on 25/01/2019.
//  Copyright © 2019 Ivan Babich. All rights reserved.
//

import Foundation

class GistsModel: APIClient {
    
    private let publicGistsURL = "https://api.github.com/gists/public"
    private var currentPage = 1
    private var batchSize = 20
    var gists = [GistPlainModel]()
    var topUsers = [OwnerPlainModel]()
    var userGists = [GistPlainModel]()
    let session: URLSession
    
    var didNewGistsLoad: (([IndexPath]?) -> Void)?
    var didNewGistsFail: ((APIError) -> Void)?
    var didOwnerOrAvatarLoad: ((Int) -> Void)?
    var didTopUserChange: (() -> Void)?
    
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    convenience init() {
        self.init(configuration: .default)
    }
    
    func downloadGists() {
        var components = URLComponents(string: publicGistsURL)!
        components.queryItems = [URLQueryItem(name: "page", value: "\(currentPage)"),
                                 URLQueryItem(name: "per_page", value: "\(batchSize)")]
        fetch(with: URLRequest(url: components.url!), decode: {
            guard let newGists = $0 as? [GistPlainModel] else { return [] }
            self.gists.append(contentsOf: newGists)
            DispatchQueue.main.async {
                if self.currentPage > self.batchSize {
                    let indexPathsToReload = self.calculateIndexPathsToReload(from: newGists)
                    self.didNewGistsLoad?(indexPathsToReload)
                } else {
                    self.didNewGistsLoad?(.none)
                }
            }
            for i in 0..<self.gists.count {
                let gist = self.gists[i]
                DispatchQueue.global().sync {
                    self.downloadOwner(from: gist.owner.url, completion: { (result) in
                        switch result {
                        case .success(_):
                            DispatchQueue.main.async {
                                self.didOwnerOrAvatarLoad?(i)
                            }
                            break
                        case .failure(_):
                            break
                        }
                    })
                }
                DispatchQueue.global().sync {
                    self.downloadImage(from: gist.owner.avatarURL, for: gist.owner.url, completion: { (result) in
                        switch result {
                        case .success(_):
                            DispatchQueue.main.async {
                                self.didOwnerOrAvatarLoad?(i)
                                self.didTopUserChange?()
                            }
                            break
                        case .failure(_):
                            break
                        }
                    })
                }
            }
            self.currentPage = self.gists.count
            let oldTopUsers = self.topUsers
            self.topUsers = self.getTopUsers()
            var isTopUsersChanged = false
            if oldTopUsers.count != self.topUsers.count {
                isTopUsersChanged = true
            }
            if !isTopUsersChanged {
                for i in 0..<self.topUsers.count {
                    let newUser = self.topUsers[i]
                    let oldUser = oldTopUsers[i]
                    if newUser.url != oldUser.url {
                        isTopUsersChanged = true
                        break
                    }
                }
            }
            if isTopUsersChanged {
                DispatchQueue.main.async {
                    self.didTopUserChange?()
                }
            }
            return newGists
        }, completion: { (result: Result<[GistPlainModel], APIError>) in
            switch (result) {
            case .success(_):
                break
            case .failure(let error):
                DispatchQueue.main.async {
                    self.didNewGistsFail?(error)
                }
            }
        })
    }
    
    private func downloadOwner(from url: URL, completion: @escaping (Result<OwnerPlainModel?, APIError>) -> Void) {
        let urlRequest = URLRequest(url: url)
        fetch(with: urlRequest, decode: {
            guard let owner = $0 as? OwnerPlainModel else { return nil }
            for i in 0..<self.gists.count {
                if self.gists[i].owner.url == url {
                    self.gists[i].owner.name = owner.name
                }
            }
            return owner
        }, completion: completion)
    }
    
    private func downloadImage(from url: URL, for ownerURL: URL, completion: @escaping (Result<Data, APIError>) -> Void) {
        fetchImage(from: url) { (result) in
            switch result {
            case .success(let imageData):
                for i in 0..<self.gists.count {
                    if self.gists[i].owner.url == ownerURL {
                        self.gists[i].owner.avatarData = imageData
                    }
                }
                for i in 0..<self.topUsers.count {
                    if self.topUsers[i].url == ownerURL && self.topUsers[i].avatarData == nil {
                        self.topUsers[i].avatarData = imageData
                        DispatchQueue.main.async {
                            self.didTopUserChange?()
                        }
                    }
                }
                break
            case .failure(let error):
                print("Ошибка загрузки аватара пользователя: \(error)")
                break
            }
            completion(result)
        }
    }
    
    func downloadGists(for url: URL, completion: @escaping (Result<[GistPlainModel], APIError>) -> Void) {
        let urlRequest = URLRequest(url: url)
        fetch(with: urlRequest, decode: {
            guard let gists = $0 as? [GistPlainModel] else { return [] }
            self.userGists = gists
            return gists
        }, completion: completion)
    }
    
    private func getTopUsers() -> [OwnerPlainModel] {
        var urlsCount = [URL : Int]()
        for gist in gists {
            let userURL = gist.owner.url
            urlsCount[userURL] = gists.filter{ $0.owner.url == userURL }.count
        }
        var sortedUrlsCount = urlsCount.sorted{ $0.value > $1.value }
        while sortedUrlsCount.count > 10 {
            sortedUrlsCount.removeLast()
        }
        var topUsers = [OwnerPlainModel]()
        for key in sortedUrlsCount {
            for gist in gists {
                if gist.owner.url == key.key {
                    topUsers.append(gist.owner)
                    break
                }
            }
        }
        return topUsers
    }
    
    func downloadCommits(from url: URL, completion: @escaping (Result<[CommitPlainModel], APIError>) -> Void) {
        let urlRequest = URLRequest(url: url)
        fetch(with: urlRequest, decode: {
            guard let commits = $0 as? [CommitPlainModel] else { return [] }
            return commits
        }, completion: completion)
    }
    
    private func calculateIndexPathsToReload(from newGists: [GistPlainModel]) -> [IndexPath] {
        let startIndex = gists.count - newGists.count
        let endIndex = startIndex + newGists.count
        return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
}
