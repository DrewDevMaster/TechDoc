//
//  GCD vs OperationQueue.swift
//  TechAddicted
//
//  Created by ViktorM1Max on 19.06.2025.
//

import Foundation


/*
 Operation/OperationQueue и GCD (Grand Central Dispatch) — это два способа работы с многопоточностью в iOS. Они оба используются для асинхронного выполнения задач, но отличаются по уровню абстракции, гибкости и контролю.

 ⸻

 🧠 Главное различие:

                        GCD (Grand Central Dispatch)                 OperationQueue / Operation
 ⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻
 Уровень                        Низкоуровневый                             Более высокоуровневый
 Тип задач                      Блоки (closure)                        Классы-наследники Operation или блоки
 Отмена                         ❌ Нет встроенной отмены             ✅ Можно отменять операции
 Зависимости                    ❌ Нет                               ✅ Поддерживает зависимости между задачами
 Повторное использование        ❌                                   ✅ Можно переиспользовать Operation
 Кастомизация                   ❌ минимальная                       ✅ можно переопределить main, isReady и т. д.
 Приоритеты                     ✅ через qos                         ✅ можно устанавливать приоритеты
 Наблюдение                     ❌                                   ✅ KVO и блоки завершения


 ⸻

 🔧 Примеры

 ✅ GCD:

 DispatchQueue.global(qos: .background).async {
     // фоновая задача
     DispatchQueue.main.async {
         // обновление UI
     }
 }

 Просто, быстро, удобно. Но мало контроля.

 ⸻

 ✅ OperationQueue:

 let queue = OperationQueue()

 let operation1 = BlockOperation {
     print("Task 1")
 }

 let operation2 = BlockOperation {
     print("Task 2")
 }

 operation2.addDependency(operation1) // Task 2 выполнится после Task 1

 queue.addOperations([operation1, operation2], waitUntilFinished: false)

 Ты можешь:
     •    устанавливать зависимости
     •    отменять задачи (operation.cancel())
     •    приостанавливать очередь (queue.isSuspended)
     •    добавлять KVO или completion-блоки

 ⸻

 🧠 Когда использовать что?

 Хочешь сделать…                                            Используй
 ⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻⸻
 Просто отправить задачу в фон                              GCD
 Последовательное выполнение с зависимостями                Operation
 Возможность отмены задач                                   Operation
 Тонкая настройка очереди                                   Operation
 Максимальная производительность с минимумом кода           GCD


 ⸻

 💡 В реальных проектах:
     •    GCD отлично подходит для простых задач: загрузка данных, UI-обновления, анимации.
     •    OperationQueue хороша для сложной логики с зависимостями: парсинг, загрузка с обработкой, кэширование, очереди сетевых запросов и т. д.
 
 */
