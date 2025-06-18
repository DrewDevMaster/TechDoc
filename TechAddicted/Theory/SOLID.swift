//
//  SOLID.swift
//  TechAddicted
//
//  Created by ViktorM1Max on 18.06.2025.
//

import Foundation

/*
 💡 Почему SOLID важен:
     •    Повышает читаемость
     •    Облегчает тестирование
     •    Делает код гибким и расширяемым
     •    Уменьшает баги при изменениях
 
 
 
============== S ==============
 
 S — Single Responsibility Principle

 Один класс должен иметь только одну причину для изменения.

 ✅ Каждый класс должен выполнять одну задачу.
 ❌ Не нужно смешивать логику отображения, бизнес-логику и сохранение данных в одном классе.
 
 
 
 ============== O ==============
 
 O — Open/Closed Principle

 Программные сущности должны быть открыты для расширения, но закрыты для изменения.

 ✅ Новый функционал добавляется без изменения существующего кода, через наследование, протоколы или композицию.
 
 Пример:
 
 protocol Shape {
     func area() -> Double
 }

 class Circle: Shape { ... }
 class Square: Shape { ... }

 func totalArea(shapes: [Shape]) -> Double {
     return shapes.reduce(0) { $0 + $1.area() }
 }
 
 Если ты добавишь Triangle, тебе не нужно менять totalArea() → это Open/Closed.
 
 
 
 ============== L ==============
 
 L — Liskov Substitution Principle

 Объекты подклассов должны быть заменяемыми на объекты суперклассов без нарушения логики.

 ✅ Подклассы не должны ломать поведение родительских классов.
 
 === Плохо ===
 class Bird {
     func fly() {}
 }

 class Ostrich: Bird {
     override func fly() {
         // Ostrich can't fly ❌
     }
 }
 
 === Хорошо ===
 Лучше создать FlyingBird и NonFlyingBird.
 
 
 
 ============== I ==============
 
 I — Interface Segregation Principle

 Не заставляй класс реализовывать интерфейсы, которые он не использует.

 ✅ Лучше много маленьких протоколов, чем один “гигантский”.

 === Плохо ===
 protocol Printer {
     func print()
     func scan()
     func fax()
 }
 
 === Хорошо ===
 protocol Printable { func print() }
 protocol Scannable { func scan() }
 protocol Faxable   { func fax() }
 
 
 
 ============== D ==============
 
 D — Dependency Inversion Principle

 Модули верхнего уровня не должны зависеть от модулей нижнего уровня. Оба должны зависеть от абстракций.

 ✅ Зависимости должны быть построены через протоколы, а не напрямую через классы.
 
 === Плохо ===
 class UserService {
     let network = RealNetwork() // жёсткая зависимость ❌
 }
 
 === Хорошо ===
 protocol Network {
     func fetchData()
 }

 class RealNetwork: Network { ... }

 class UserService {
     let network: Network
     init(network: Network) {
         self.network = network
     }
 }
 
 */
