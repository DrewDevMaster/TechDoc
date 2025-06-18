//
//  DataRace.swift
//  TechAddicted
//
//  Created by Drew on 18.06.2025.
//

import Foundation

// MARK: - Data race

/*
 
Data race (состояние гонки данных) — это опасная ситуация, когда два или более потока одновременно обращаются к одной и той же области памяти, и хотя бы один из этих потоков изменяет данные, при этом нет никакой синхронизации между ними.

⸻

🧠 Ключевые признаки data race:
    1.    Доступ к общим данным (shared mutable state)
    2.    Хотя бы один поток пишет
    3.    Нет контроля доступа (например, через DispatchQueue, locks, @MainActor, isolated и т.п.)

⸻

🔥 Что происходит при data race?
    •    Результаты становятся непредсказуемыми: значения могут быть частично записаны, потеряны, перезаписаны.
    •    Могут возникать краши, утечки, баги, которые трудно воспроизвести.
    •    Это особенно опасно при работе с многопоточностью (DispatchQueue, Task, OperationQueue, etc.).

🔥 Реальний пример (Мой опыт)
Чтение и запись CoreData
*/

private func test2() {
   var counter = 0

   DispatchQueue.global().async {
       for _ in 0..<1000 {
           counter += 1
       }
   }

   DispatchQueue.global().async {
       for _ in 0..<1000 {
           counter += 1
       }
   }
}

/*
❗️Оба потока одновременно увеличивают counter.
В результате ты не получишь 2000, а что-то меньше или вообще случайное.



✅ Как защититься?

Подход
Пример
🧵 Сериализация
Используй DispatchQueue(label:) для последовательности
🔒 Блокировки
NSLock, os_unfair_lock, @SynchronizedActor
🧑‍🎓 Акторы (actor)
Swift Concurrency — безопасная изоляция состояния
🧵 @MainActor
Гарантирует, что доступ идёт только с main thread
🧾 Read/Write Barriers
Сложные структуры: DispatchQueue с .barrier флагом

🔐 Пример безопасного доступа:

let queue = DispatchQueue(label: "com.example.safe")

queue.async {
    counter += 1
}

✅ Через actor (Swift Concurrency):

actor Counter {
    private var value = 0

    func increment() {
        value += 1
    }

    func getValue() -> Int {
        return value
    }
}

📋 Вывод:

Вопрос
Ответ
Что такое data race?
Несинхронизированный доступ к данным
Чем опасен?
Непредсказуемость, баги, краши
Как защититься?
Синхронизация: serial queue, locks, actor
Где часто встречается?
Background-задачи, UI-рендер, Task, async


✅ Как исправить или предотвратить?

1. Контроль через DispatchQueue (Serial) Подходит для защищённых записей и чтений, если не нужно блокировать вызывающий поток.
*/

private func test3() {
   let syncQueue = DispatchQueue(label: "sync.counter") // serial

   var counter = 0

   for _ in 0..<1000 {
       syncQueue.async {
           counter += 1
       }
   }
}

/*
2. Контроль через Lock (NSLock)
 🔒 lock() / unlock() гарантируют, что только один поток за раз может изменить значение.

 ➡ Подходит для критических секций в многопоточной логике, особенно в Objective-C-подобных API.
 */

private func test4() {
   
   let lock = NSLock()
   var counter = 0
   
   DispatchQueue.global().async {
       for _ in 0..<1000 {
           lock.lock()
           counter += 1
           lock.unlock()
       }
   }
}


//🛡 3. Контроль через @MainActor

@MainActor
fileprivate class AppState1 {
   var counter = 0

   func increment() async {
       counter += 1
   }
   
   private func test5() {
       let state = AppState1()

       Task {
           await state.increment()
       }
   }
}

/*
🔒 Все обращения к AppState будут выполняться на главном потоке в безопасной последовательной очереди благодаря runtime isolation. Если @MainActor то поток в любом случаи будет перенаправлен на main


➡ Хорошо подходит для SwiftUI или логики, связанной с UI.
*/

//🛡 4. Контроль через isolated и actor (Swift Concurrency)

private actor Counter {
   private var value = 0

   func increment() {
       value += 1
   }

   func getValue() -> Int {
       value
   }
}

private func test6() {
   // Использование
   let counter = Counter()

   Task {
       await counter.increment()
   }
}

/*
🔒 actor гарантирует, что только одна задача за раз получит доступ к его состоянию.

➡ Это самый безопасный и современный способ борьбы с data race в Swift 5.5+.


🧪 Визуальное сравнение

Подход
Потокобезопасность
Подходит для UI?
Современность

DispatchQueue
✅ Да
⚠️ Частично
✅ Стандартный

NSLock
✅ Да
❌ Лучше избегать
🟡 Старый стиль

@MainActor
✅ Да
✅ Идеален
✅ Swift 5.5+

actor/isolated
✅ Да
⚠️ Лучше не для UI
✅ Swift 5.5+



🎯 Вывод:
    •    actor — лучший выбор для нового кода, особенно при async/await
    •    @MainActor — идеально для UI/SwiftUI
    •    DispatchQueue — удобный и гибкий для изоляции фрагментов кода
    •    NSLock — годится для низкоуровневого контроля, но требует аккуратности
*/
