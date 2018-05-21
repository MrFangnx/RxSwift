//
//  Map.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 3/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension ObservableType {

    /**
     Projects each element of an observable sequence into a new form.

     - seealso: [map operator on reactivex.io](http://reactivex.io/documentation/operators/map.html)

     - parameter transform: A transform function to apply to each source element.
     - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.

     */
    public func map<R>(_ transform: @escaping (E) throws -> R) //map操作，将自身转换为Observable，执行composeMap
        -> Observable<R> {
        return self.asObservable().composeMap(transform)
    }
}

//具像化sink类，用于Producer子类执行run方法时，对数据源进行处理，即变换闭包的执行
final fileprivate class MapSink<SourceType, O : ObserverType> : Sink<O>, ObserverType {
    typealias Transform = (SourceType) throws -> ResultType

    typealias ResultType = O.E
    typealias Element = SourceType

    private let _transform: Transform
    
    init(transform: @escaping Transform, observer: O, cancel: Cancelable) {
        _transform = transform
        super.init(observer: observer, cancel: cancel)
    }

    func on(_ event: Event<SourceType>) {
        switch event {
        case .next(let element):
            do {
                let mappedElement = try _transform(element) //执行变换操作
                forwardOn(.next(mappedElement))  //发送消息给观察者
            }
            catch let e {
                forwardOn(.error(e))
                dispose()
            }
        case .error(let error):
            forwardOn(.error(error))
            dispose()
        case .completed:
            forwardOn(.completed)
            dispose()
        }
    }
}

#if TRACE_RESOURCES
    fileprivate var _numberOfMapOperators: AtomicInt = 0
    extension Resources {
        public static var numberOfMapOperators: Int32 {
            return _numberOfMapOperators.valueSnapshot()
        }
    }
#endif

internal func _map<Element, R>(source: Observable<Element>, transform: @escaping (Element) throws -> R) -> Observable<R> {
    return Map(source: source, transform: transform) //返回一个Producer的子类Map对象，传入Observable调用者自身和操作元素的闭包
}

final fileprivate class Map<SourceType, ResultType>: Producer<ResultType> {
    typealias Transform = (SourceType) throws -> ResultType

    private let _source: Observable<SourceType>

    private let _transform: Transform

    //构造方法中，存储了Observable及元素的变换操作
    init(source: Observable<SourceType>, transform: @escaping Transform) {
        _source = source
        _transform = transform

#if TRACE_RESOURCES
        let _ = AtomicIncrement(&_numberOfMapOperators) //原子地增加变换操作的计数
#endif
    }
    //重载composeMap，这样当普通Observale执行map产生的Map（Observale）对象在此执行map时，会先执行Map对象自身的变换操作，再执行map方法里的操作，这样多次map操作得到优化，只会在sink中对数据源执行一次综合变换？
    override func composeMap<R>(_ selector: @escaping (ResultType) throws -> R) -> Observable<R> {
        let originalSelector = _transform
        return Map<SourceType, R>(source: _source, transform: { (s: SourceType) throws -> R in
            let r: ResultType = try originalSelector(s)  //执行Map对象自己的变换操作，由普通Observable第一次调用map方法时传入
            return try selector(r)  //执行Map对象的map方法，链式调用传入下一个map
        })
    }
    
    //实现Producer的抽象run方法，订阅时执行，创建MapSink对象作为sink，并产生subscription返回
    override func run<O: ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == ResultType {
        let sink = MapSink(transform: _transform, observer: observer, cancel: cancel)
        let subscription = _source.subscribe(sink) //run和subscribe递归调用，实现嵌套的变换操作
        return (sink: sink, subscription: subscription)
    }

    #if TRACE_RESOURCES
    deinit {
        let _ = AtomicDecrement(&_numberOfMapOperators)
    }
    #endif
}
