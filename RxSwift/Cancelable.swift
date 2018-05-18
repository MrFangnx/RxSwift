//
//  Cancelable.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 3/12/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// Represents disposable resource with state tracking.
public protocol Cancelable : Disposable {  //继承Disposable，追加声明了新方法isDisposed
    /// Was resource disposed.
    var isDisposed: Bool { get }   //标识该序列是否已被释放
}
