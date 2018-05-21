//
//  DisposeBag.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 3/25/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension Disposable {
    /// Adds `self` to `bag`
    ///
    /// - parameter bag: `DisposeBag` to add `self` to.
    public func disposed(by bag: DisposeBag) {
        bag.insert(self)
    }
}

/**
Thread safe bag that disposes added disposables on `deinit`.

This returns ARC (RAII) like resource management to `RxSwift`.

In case contained disposables need to be disposed, just put a different dispose bag
or create a new one in its place.

    self.existingDisposeBag = DisposeBag()

In case explicit disposal is necessary, there is also `CompositeDisposable`.
*/
public final class DisposeBag: DisposeBase {
    
    private var _lock = SpinLock()  //一个递归锁，继承自NSRecursiveLock，用于_disposables数组线程安全
                                    //使用递归锁是因为会出现同一个线程多次insert一个Disposable，导致死锁
    
    // state
    private var _disposables = [Disposable]()
    private var _isDisposed = false
    
    /// Constructs new empty dispose bag.
    public override init() {
        super.init()
    }
    
    /// Adds `disposable` to be disposed when dispose bag is being deinited.
    ///
    /// - parameter disposable: Disposable to add.
    public func insert(_ disposable: Disposable) {
        _insert(disposable)?.dispose()
    }
    
    private func _insert(_ disposable: Disposable) -> Disposable? {
        _lock.lock(); defer { _lock.unlock() } //defer将释放锁的过程推入栈中，defer所在作用域结束时，按照入栈defer代码块的反序出栈执行代码块，释放锁
        if _isDisposed {  //若已完成释放，则不再添加新的Disposable
            return disposable  //这里提前退出，会执行栈内的defer，释放锁
        }

        _disposables.append(disposable)

        return nil
    }

    /// This is internal on purpose, take a look at `CompositeDisposable` instead.
    private func dispose() {       //取出所有Disposable，并执行释放操作
        let oldDisposables = _dispose()

        for disposable in oldDisposables {
            disposable.dispose()
        }
    }

    private func _dispose() -> [Disposable] {
        _lock.lock(); defer { _lock.unlock() }

        let disposables = _disposables
        
        _disposables.removeAll(keepingCapacity: false)
        _isDisposed = true
        
        return disposables
    }
    
    deinit {  //deinit时，释放全部Disposable
        dispose()
    }
}
