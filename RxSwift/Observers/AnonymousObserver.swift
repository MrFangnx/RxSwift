//
//  AnonymousObserver.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

final class AnonymousObserver<ElementType> : ObserverBase<ElementType> {  //匿名观察者，实现ObserverBase抽象基类里的onCore方法
    typealias Element = ElementType
    
    typealias EventHandler = (Event<Element>) -> Void
    
    private let _eventHandler : EventHandler
    
    init(_ eventHandler: @escaping EventHandler) { //初始化时传入闭包，存储为私有变量
#if TRACE_RESOURCES
        let _ = Resources.incrementTotal()
#endif
        _eventHandler = eventHandler
    }

    override func onCore(_ event: Event<Element>) {  //onCore方法主要执行的就是闭包内操作
        return _eventHandler(event)
    }
    
#if TRACE_RESOURCES
    deinit {
        let _ = Resources.decrementTotal()
    }
#endif
}
