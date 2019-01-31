//
//  DetailGistViewController.swift
//  Gists
//
//  Created by Ivan Babich on 26/01/2019.
//  Copyright © 2019 Ivan Babich. All rights reserved.
//

import UIKit

class DetailGistViewController: UIViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var gistNameLabel: UILabel!
    @IBOutlet weak var filesCollectionView: UICollectionView!
    @IBOutlet weak var commitsTableView: UITableView!
    var gist: GistPlainModel!
    var gistsModel: GistsModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let avatarData = gist.owner.avatarData {
            avatarImageView.image = UIImage(data: avatarData)
        }
        userNameLabel.text = gist.owner.name
        gistNameLabel.text = gist.description
        loadCommits(for: gist.commitsUrl)
    }
    
    private func loadCommits(for url: URL) {
        gistsModel.downloadCommits(from: url) { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let commits):
                    self?.gist.commits = commits
                    self?.commitsTableView.reloadData()
                    break
                case .failure(let error):
                    print(error)
                    break
                }
            }
        }
    }
}

extension DetailGistViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return gist.files.count == 0 ? 0 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gist.files.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FileCell", for: indexPath) as! GistFileCollectionViewCell
        let keys = Array(gist.files.keys)
        if let file = gist.files[keys[indexPath.row]] {
            cell.configureCell(fileModel: file)
        }
        return cell
    }
}

extension DetailGistViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gist.commits?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommitCell", for: indexPath)
        cell.textLabel?.text = "Число добавленных строк: \(gist.commits?[indexPath.row].changeStatus.additions ?? 0)"
        cell.detailTextLabel?.text = "Число удаленных строк: \(gist.commits?[indexPath.row].changeStatus.deletions ?? 0)"
        return cell
    }
}
