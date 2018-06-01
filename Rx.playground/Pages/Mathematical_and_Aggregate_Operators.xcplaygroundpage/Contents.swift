/*:
 > # IMPORTANT: To use **Rx.playground**:
 1. Open **Rx.xcworkspace**.
 1. Build the **RxSwift-macOS** scheme (**Product** → **Build**).
 1. Open **Rx** playground in the **Project navigator**.
 1. Show the Debug Area (**View** → **Debug Area** → **Show Debug Area**).
 ----
 [Previous](@previous) - [Table of Contents](Table_of_Contents)
 */
import RxSwift
/*:
 # Mathematical and Aggregate Operators
 Operators that operate on the entire sequence of items emitted by an `Observable`.
 ## `toArray`
 Converts an `Observable` sequence into an array, emits that array as a new single-element `Observable` sequence, and then terminates. [More info](http://reactivex.io/documentation/operators/to.html)
 ![](http://reactivex.io/documentation/operators/images/to.c.png)
 */
example("toArray") {
    let disposeBag = DisposeBag()
    
    Observable.range(start: 1, count: 10)
        .toArray()  //将信号塞入数组，然后发送只包含这个数组的信号，之后直接发送completed
        .subscribe { print($0) }
        .disposed(by: disposeBag)
}
/*:
 ----
 ## `reduce`
 Begins with an initial seed value, and then applies an accumulator closure to all elements emitted by an `Observable` sequence, and returns the aggregate result as a single-element `Observable` sequence. [More info](http://reactivex.io/documentation/operators/reduce.html)
 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/reduce.png)
 */
example("reduce") {
    let disposeBag = DisposeBag()
    
    Observable.of(10, 100, 1000)
        .reduce(1, accumulator: +)  //设置初始的种子值，然后将闭包结果依次作用于这个每个信号，最终返回一个包含最终累积值的信号
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)

    Observable.of(10, 100, 1000)
        .reduce(1, accumulator: { (element, seed) -> Int in //上述的+就带有该闭包的效果
            return element * seed;
        })
        .subscribe(onNext: {print($0) })
        .disposed(by: disposeBag)
}
/*:
 ----
 ## `concat`
 Joins elements from inner `Observable` sequences of an `Observable` sequence in a sequential manner, waiting for each sequence to terminate successfully before emitting elements from the next sequence. [More info](http://reactivex.io/documentation/operators/concat.html)
 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/concat.png)
 */
example("concat") {
    let disposeBag = DisposeBag()
    
    let subject1 = BehaviorSubject(value: "🍎")
    let subject2 = BehaviorSubject(value: "🐶")
    
    let variable = Variable(subject1)
    
    variable.asObservable()
        .concat()  //拼接
        .subscribe { print($0) }
        .disposed(by: disposeBag)
    
    subject1.onNext("🍐")
    subject1.onNext("🍊")
    
    variable.value = subject2   //这里接入第二个序列
    
    subject2.onNext("I would be ignored")  //由于第一个序列没有发送completed，这个信号会被subject2的下一个信号挤掉

    subject2.onNext("🐱")
    
    subject1.onCompleted() //当第一个序列发送completed之后，才会开始发送subject2中存在的信号
    
    subject2.onNext("🐭")

    subject2.onNext("🍎")

    subject2.onCompleted()  //当第二个序列发送completed，没有其他序列在后面等待，则直接返回最终的completed
}

//: [Next](@next) - [Table of Contents](Table_of_Contents)
