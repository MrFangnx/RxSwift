//
//  Disposable.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// Represents a disposable resource.
public protocol Disposable { //声明dispose方法，定义释放资源的统一行为
    /// Dispose resource.
    func dispose()
}
