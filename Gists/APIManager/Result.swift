//
//  Result.swift
//  Gists
//
//  Created by Ivan Babich on 26/01/2019.
//  Copyright © 2019 Ivan Babich. All rights reserved.
//

import Foundation

enum Result<T, U> where U: Error  {
    case success(T)
    case failure(U)
}
