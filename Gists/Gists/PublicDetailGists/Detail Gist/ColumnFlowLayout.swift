//
//  ColumnFlowLayout.swift
//  Gists
//
//  Created by Ivan Babich on 28/01/2019.
//  Copyright © 2019 Ivan Babich. All rights reserved.
//

import UIKit

class ColumnFlowLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        self.itemSize = CGSize(width: collectionView.bounds.width / 3.5, height: collectionView.bounds.height - self.minimumInteritemSpacing - 8.0)
        self.sectionInset = UIEdgeInsets(top: self.minimumInteritemSpacing, left: 16.0, bottom: 8.0, right: 16.0)
        self.scrollDirection = .horizontal
        self.sectionInsetReference = .fromSafeArea
    }
}
