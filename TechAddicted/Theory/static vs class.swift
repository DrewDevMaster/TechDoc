//
//  static vs class.swift
//  TechAddicted
//
//  Created by ViktorM1Max on 19.06.2025.
//

import Foundation

/*
 Ключевые слова static и class в Swift используются для объявления свойств и методов, которые принадлежат типу, а не экземпляру. Но между ними есть важные различия, особенно в контексте наследования.

 ⸻

 ✅ static — свойство/метод принадлежит типу (не экземпляру)

 struct MyStruct {
     static let name = "Struct type property"
 }

     •    MyStruct.name — доступ без создания экземпляра.
     •    Нельзя переопределить (override) в подклассе — это жёстко привязано к типу.

 ⸻

 ✅ class — то же, что и static, но разрешает переопределение

 class Animal {
     class func sound() -> String {
         return "Some sound"
     }
 }

 class Dog: Animal {
     override class func sound() -> String {
         return "Bark"
     }
 }

     •    Animal.sound() → "Some sound"
     •    Dog.sound() → "Bark"

 ⚠️ class используется только в классах (не в структурах и enum’ах).

 ⸻

 🔍 Таблица различий:

 Свойство/метод                           static                            class
 Доступ без экземпляра                      ✅                               ✅
 Наследование                       ❌ нельзя переопределить         ✅ можно переопределить
 Где можно использовать              class, struct, enum                только class


 ⸻

 🎯 Примеры использования

 static:

 struct Math {
     static func add(_ a: Int, _ b: Int) -> Int {
         return a + b
     }
 }

 Math.add(2, 3) // 5


 ⸻

 class:

 class Base {
     class var typeName: String {
         "Base"
     }
 }

 class Sub: Base {
     override class var typeName: String {
         "Sub"
     }
 }

 Sub.typeName // "Sub"


 ⸻

 💡 Когда использовать
     •    🔒 static — когда наследование не нужно (рекомендуется в struct и enum)
     •    🧬 class — если нужно разрешить переопределение в подклассах

 */
