//
//  SubjectType.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 3/1/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

//subject对象既可以作为可观察序列，又可以作为观察者
/// Represents an object that is both an observable sequence as well as an observer.
public protocol SubjectType : ObservableType {  //subject继承自Obersvable，是一个可观察序列
    /// The type of the observer that represents this subject.
    ///
    /// Usually this type is type of subject itself, but it doesn't have to be.
    associatedtype SubjectObserverType : ObserverType  //协议的泛型不能通过<T>，而是通过associatedtype关联类型来声明

    /// Returns observer interface for subject.
    ///
    /// - returns: Observer interface for subject.
    func asObserver() -> SubjectObserverType    //SubjectType 也可以作为Observer实例返回
    
}
