//
//  Producer.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/20/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

class Producer<Element> : Observable<Element> { //Producer重载了Obervable的subscribe方法，并声明了一个抽象方法run
    override init() {
        super.init()
    }
    
    override func subscribe<O : ObserverType>(_ observer: O) -> Disposable where O.E == Element {

        //判断是否需要Scheduler进行切换线程的调用，按需在指定线程中操作
        if !CurrentThreadScheduler.isScheduleRequired {
            // The returned disposable needs to release all references once it was disposed.
            let disposer = SinkDisposer()  //创建一个SinkDisposer
            let sinkAndSubscription = run(observer, cancel: disposer)  //调用run方法，执行sink处理
            disposer.setSinkAndSubscription(sink: sinkAndSubscription.sink, subscription: sinkAndSubscription.subscription)

            return disposer
        }
        else {
            return CurrentThreadScheduler.instance.schedule(()) { _ in
                let disposer = SinkDisposer()
                let sinkAndSubscription = self.run(observer, cancel: disposer)
                disposer.setSinkAndSubscription(sink: sinkAndSubscription.sink, subscription: sinkAndSubscription.subscription)

                return disposer
            }
        }
    }

    //run方法，订阅时执行，返回一个sink和subscription元组，这里run执行sink相关操作，主要包括对事件的转发，以及转发前的大部分预处理
    func run<O : ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == Element {
        rxAbstractMethod()
    }
}

fileprivate final class SinkDisposer: Cancelable {  //遵循Cancelable协议
    fileprivate enum DisposeState: UInt32 {
        case disposed = 1
        case sinkAndSubscriptionSet = 2
    }

    // Jeej, swift API consistency rules
    fileprivate enum DisposeStateInt32: Int32 {
        case disposed = 1
        case sinkAndSubscriptionSet = 2
    }
    
    private var _state: AtomicInt = 0   //AtomicInt 描述状态
    private var _sink: Disposable? = nil
    private var _subscription: Disposable? = nil

    var isDisposed: Bool {
        return AtomicFlagSet(DisposeState.disposed.rawValue, &_state)
    }

    func setSinkAndSubscription(sink: Disposable, subscription: Disposable) {
        //先设置_sink和_subscription的值，再判断是否为重复操作或无效操作
        _sink = sink
        _subscription = subscription

        let previousState = AtomicOr(DisposeState.sinkAndSubscriptionSet.rawValue, &_state) //原子操作按位或，将sinkAndSubscriptionSet.rawValue的状态原子地写到到_state上，并返回_state原值给previousState
        //func OSAtomicOr32OrigBarrier(_ __theMask: UInt32, _ __theValue: UnsafeMutablePointer<UInt32>!) -> Int32
        //携带内存屏障
        if (previousState & DisposeStateInt32.sinkAndSubscriptionSet.rawValue) != 0 { //判断原值，若为sinkAndSubscriptionSet.rawValue，表明重复执行设置
            rxFatalError("Sink and subscription were already set")
        }

        if (previousState & DisposeStateInt32.disposed.rawValue) != 0 {  //若已经dispose过，上面对_sink和_subscription的设置无效，应当被直接释放
            sink.dispose()
            subscription.dispose()
            _sink = nil
            _subscription = nil
        }
    }
    
    func dispose() {
        let previousState = AtomicOr(DisposeState.disposed.rawValue, &_state) //原子操作按位或，将disposed.rawValue的状态原子地写到到_state上，并返回_state原值给previousState

        if (previousState & DisposeStateInt32.disposed.rawValue) != 0 { //若已dispose过，直接返回，不重复执行dispose
            return
        }

        if (previousState & DisposeStateInt32.sinkAndSubscriptionSet.rawValue) != 0 { //如果未dispose过，且sinkAndSubscriptionSet状态有效，分别执行sink和subscription的dispose操作
            guard let sink = _sink else {
                rxFatalError("Sink not set")
            }
            guard let subscription = _subscription else {
                rxFatalError("Subscription not set")
            }

            sink.dispose()
            subscription.dispose()

            _sink = nil
            _subscription = nil
        }
    }
}
