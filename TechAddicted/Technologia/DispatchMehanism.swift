//
//  DispatchMehanism.swift
//  TechAddicted
//
//  Created by Drew on 28.05.2025.
//

import Foundation
import UIKit


//MARK: - Статическая vs. динамическая диспетчеризация

/*
 struct, final class, static методы

Определяется в рантайме
class, @objc dynamic


Когда использовать @objc dynamic?
    •    Когда нужна KVO (наблюдение за свойствами).
    •    Когда используете target-action механизмы (например, UIButton).
    •    Когда требуется максимальная динамика (например, плагин-системы, перехват вызовов, runtime-магия).

 */

//MARK: - KVO

/*

KVO (Key-Value Observing) — это часть Objective-C runtime, которая позволяет следить за изменением значения свойства объекта. Swift поддерживает его, но только для классов, унаследованных от NSObject, и свойств, помеченных @objc dynamic.

 
@objc
Экспорт в Objective-C runtime
dynamic
Использование objc runtime-диспетчеризации

Когда реально использовать KVO?
    •    В старых UIKit-приложениях
    •    При работе с AVPlayer, CALayer, ScrollView.contentOffset, и другими API, поддерживающими KVO
    •    Если используете сторонние библиотеки или Objective-C API

*/

class Person: NSObject {
    @objc dynamic var name: String = ""
}

let person = Person()

// Подписка на изменения
let observation = person.observe(\.name, options: [.new, .old]) { (person, change) in
    print("Name changed from \(change.oldValue!) to \(change.newValue!)")
}
// person.name = "John"  // -> Name changed from "" to "John"



//MARK: - Table Dispatch (aka V-Table Dispatch)
/*
 - Механизм Swift, через который вызываются переопределяемые методы классов, если они не final и не помечены dynamic
 
 Каждий класс создает vtable — таблица виртуальных функций где храннит ссылку на обьект
 Механизм вызова - По индексу

 */

class Animal {
    func speak() { print("Animal") }
}

class Dog: Animal {
    override func speak() { print("Bark") }
}

let a: Animal = Dog()
// a.speak() // через vtable


//MARK: - Message Dispatch (objc_msgSend)

//Механизм вызова - По хешу селектора
//
//Позволяет использовать KVO, Selector, Swizzling

//MARK: - Witness Table Dispatch

/*
 - Механизм вызова методов при исп протокола как тип (let x: SomeProtocol), или при использовании generic where T: Protocol.
 
 Исп когда тип соответствует протоколу, Swift создаёт witness table — таблицу указателей на реализацию методов этого протокола в типе.
 */

protocol Speaker {
    func speak()
}

struct Cat: Speaker {
    func speak() { print("Meow") }
}

let delegate: Speaker = Cat()
// delegate.speak() // через witness table




//MARK: - swizzling

/*
Метод swizzling — это обмен реализаций двух методов в момент выполнения (runtime), чтобы изменить поведение существующего метода без изменения его исходного кода.
*/

extension NSObject {
    static func swizzleMethod(
        originalSelector: Selector,
        swizzledSelector: Selector
    ) {
        guard let originalMethod = class_getInstanceMethod(self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(self, swizzledSelector) else { return }

        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

extension UIViewController {
    
    @objc func swizzled_viewDidLoad() {
        print("viewDidLoad swizzled for \(self)")
        swizzled_viewDidLoad() // вызывает оригинальную реализацию (уже поменялись местами!)
    }

    static let swizzleViewDidLoad: Void = {
        swizzleMethod(
            originalSelector: #selector(UIViewController.viewDidLoad),
            swizzledSelector: #selector(UIViewController.swizzled_viewDidLoad)
        )
    }()
}
