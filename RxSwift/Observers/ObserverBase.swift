//
//  ObserverBase.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

class ObserverBase<ElementType> : Disposable, ObserverType { //抽象类，遵循Disposable和ObserverType协议，实现了on方法
    typealias E = ElementType

    private var _isStopped: AtomicInt = 0   //标记观察的序列是否停止

    func on(_ event: Event<E>) {
        switch event {
        case .next:  //若事件类型为next
            if _isStopped == 0 {  //若序列未停止，执行onCore方法，即发送next事件
                onCore(event)
            }
        case .error, .completed:  //若事件类型为error或者completed
            if AtomicCompareAndSwap(0, 1, &_isStopped) {  //将标记置为已停止，若旧值等于内存里的值，返回true，并更新内存里的值为新值，即此刻会执行onCore方法；若旧值与内存值不同，则返回false，不会重复执行onCore方法
                //func OSAtomicCompareAndSwap32Barrier(_ __oldValue: Int32, _ __newValue: Int32, _ __theValue: UnsafeMutablePointer<Int32>!) -> Bool
                //携带内存屏障，确保此前内存中读写操作完毕
                onCore(event)
            }
        }
    }

    func onCore(_ event: Event<E>) {
        rxAbstractMethod()
    }

    func dispose() {
        _ = AtomicCompareAndSwap(0, 1, &_isStopped)
    }
}
