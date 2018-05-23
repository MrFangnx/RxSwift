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
# Transforming Operators
Operators that transform Next event elements emitted by an `Observable` sequence.
## `map`
 Applies a transforming closure to elements emitted by an `Observable` sequence, and returns a new `Observable` sequence of the transformed elements. [More info](http://reactivex.io/documentation/operators/map.html)
![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/map.png)
*/
example("map") {
    let disposeBag = DisposeBag()
    Observable.of(1, 2, 3)
        .map { $0 * $0 }   //返回变换后的新可观察序列
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}
/*:
 ----
 ## `flatMap` and `flatMapLatest`
 Transforms the elements emitted by an `Observable` sequence into `Observable` sequences, and merges the emissions from both `Observable` sequences into a single `Observable` sequence. This is also useful when, for example, when you have an `Observable` sequence that itself emits `Observable` sequences, and you want to be able to react to new emissions from either `Observable` sequence. The difference between `flatMap` and `flatMapLatest` is, `flatMapLatest` will only emit elements from the most recent inner `Observable` sequence. [More info](http://reactivex.io/documentation/operators/flatmap.html)
 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/flatmap.png)
 */
example("flatMap and flatMapLatest") {
    let disposeBag = DisposeBag()
    
    struct Player {
        var score: Variable<Int>
    }
    
    let 👦🏻 = Player(score: Variable(80))
    let 👧🏼 = Player(score: Variable(90))
    
    let player = Variable(👦🏻)
    
    player.asObservable()
        .flatMap { $0.score.asObservable() } // Change flatMap to flatMapLatest and observe change in printed output
        .subscribe(onNext: { print("flatMap: \($0)")})
        .disposed(by: disposeBag)
    
    👦🏻.score.value = 85
    
    player.value = 👧🏼
    
    👦🏻.score.value = 95 // Will be printed when using flatMap, but will not be printed when using flatMapLatest
    
    👧🏼.score.value = 100
    
    ////////////////////////////////////////
    print("/////////////////////////////////////////////")
    player.asObservable()
        .flatMapLatest { $0.score.asObservable() }
        .subscribe(onNext: { print("flatMapLatest: \($0)")})
        .disposed(by: disposeBag)
    
    👦🏻.score.value = 105
    👧🏼.score.value = 110
    
    player.value = 👦🏻
    
    👦🏻.score.value = 115
    👧🏼.score.value = 120
    
}
/*:
 > In this example, using `flatMap` may have unintended consequences. After assigning 👧🏼 to `player.value`, `👧🏼.score` will begin to emit elements, but the previous inner `Observable` sequence (`👦🏻.score`) will also still emit elements. By changing `flatMap` to `flatMapLatest`, only the most recent inner `Observable` sequence (`👧🏼.score`) will emit elements, i.e., setting `👦🏻.score.value` to `95` has no effect.
 #
 > `flatMapLatest` is actually a combination of the `map` and `switchLatest` operators.
 */
/*:
 ----
 ## `scan`
 Begins with an initial seed value, and then applies an accumulator closure to each element emitted by an `Observable` sequence, and returns each intermediate result as a single-element `Observable` sequence. [More info](http://reactivex.io/documentation/operators/scan.html)
 ![](https://raw.githubusercontent.com/kzaher/rxswiftcontent/master/MarbleDiagrams/png/scan.png)
 */
example("scan") {
    let disposeBag = DisposeBag()
    
    Observable.of(10, 100, 1000)
        .scan(2) { aggregateValue, newValue in  //初始值开始，每一次收到信号都累加起来组成新的序列
            aggregateValue + newValue
        }
        .subscribe(onNext: { print($0) })
        .disposed(by: disposeBag)
}

//: [Next](@next) - [Table of Contents](Table_of_Contents)
