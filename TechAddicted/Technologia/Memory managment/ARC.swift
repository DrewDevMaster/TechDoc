//
//  Random.swift
//  TechAddicted
//
//  Created by Drew on 17.06.2025.
//

import Foundation

/*
 1. Что такое ARC?
 
 ARC (Automatic Reference Counting) — это механизм управления памятью в Swift и Objective-C, который автоматически отслеживает количество ссылок на объекты в памяти и освобождает их, когда они больше не нужны.

 ⸻

 📦 Принцип работы:

 Каждый объект в Swift имеет счётчик ссылок (reference count).
 Когда ты создаёшь или передаёшь ссылку на объект:
     •    🔼 счётчик увеличивается (+1)
     •    🔽 при удалении ссылки — уменьшается (-1)
     •    ❌ когда счётчик становится 0, объект автоматически удаляется из памяти
 */

 class PersonClass {
     var name: String
     init(name: String) {
         self.name = name
         print("\(name) инициализирован")
     }

     deinit {
         print("\(name) удалён из памяти")
     }
 }

 var person1: PersonClass? = PersonClass(name: "Anna")
 var person2 = person1 // +1

private func test() {
    person1 = nil // -1, но объект ещё в памяти
    person2 = nil // -1, теперь счётчик 0 => deinit
}
 
/*
 🧨 Проблема: Циклы сильных ссылок (retain cycles)

Если два объекта ссылаются друг на друга, они никогда не освободятся, даже если никто извне их не использует.

Пример retain cycle:
*/

private class A {
    var b: B?
}

private class B {
    var a: A?
}

private func test1() {
    let a = A()
    let b = B()
    a.b = b
    b.a = a // 🔁 цикл
}

/*
 🔧 Решение: использовать weak или unowned ссылки.
 🧠 Ключевые термины:
 
 Термин
 Значение
 strong
 Обычная ссылка, увеличивает счётчик
 weak
 Не увеличивает счётчик, используется с optional, не удерживает объект
 unowned
 Не увеличивает счётчик, но не optional. Если объект удалён — краш

 📌 ARC управляет:
     •    классами (class)
     •    ссылками (var, let, массивы ссылок)
     •    closures, которые захватывают self
*/
