//
//  withCheckedContinuation.swift
//  TechAddicted
//
//  Created by Drew on 05.06.2025.
//

import Foundation

/*
🧩 Что такое withCheckedContinuation

withCheckedContinuation — это способ обернуть асинхронную логику с колбэками в синтаксис async/await.

Другими словами:

Это мост между старым стилем с замыканиями (completion handlers) и новым стилем async/await

⸻

🔧 Сигнатура:


func withCheckedContinuation<T>(
    _ body: (CheckedContinuation<T, Never>) -> Void
) async -> T

•    T — тип возвращаемого значения
•    Never — означает, что continuation не может выбросить ошибку (есть и withCheckedThrowingContinuation для throws)
•    внутри ты получаешь объект continuation, у которого есть методы:
•    resume(returning:) — завершает continuation и возвращает результат
•    resume(throwing:) — если используется withCheckedThrowingContinuation

⸻

🔍 Пример: эмуляция async delay с колбэком

У тебя есть функция старого типа:

*/

//func oldAsyncFunc(completion: @escaping (String) -> Void) {
//    DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
//        completion("Готово!")
//    }
//}
//
////Оборачиваем её в async:
//
//func newAsyncFunc() async -> String {
//    await withCheckedContinuation { continuation in
//        oldAsyncFunc { result in
//            continuation.resume(returning: result)
//        }
//    }
//}

//Теперь ты можешь просто:

//Task {
//    let text = await newAsyncFunc()
//    print(text) // Готово!
//}

/*
💥 Важно
    •    Ты обязан вызвать resume(...) внутри withCheckedContinuation ровно один раз.
    •    Если забудешь вызвать resume(...) — поток зависнет (и ты получишь runtime warning).
    •    Если вызовешь дважды — приложение упадёт с ошибкой.

⸻

📌 Пример с withCheckedThrowingContinuation

Если функция может выбросить ошибку, например:

*/

//func downloadFile(completion: @escaping (Result<Data, Error>) -> Void) {
//    
//}
//func downloadFileAsync() async throws -> Data {
//    try await withCheckedThrowingContinuation { continuation in
//        downloadFile { result in
//            switch result {
//            case .success(let data):
//                continuation.resume(returning: data)
//            case .failure(let error):
//                continuation.resume(throwing: error)
//            }
//        }
//    }
//}

/*
🧠 Когда использовать
    •    У тебя есть сторонняя библиотека без async/await, только с колбэками
    •    Тебе нужно адаптировать NotificationCenter, delegate, Combine, CoreBluetooth, CLLocationManager и т.п.
    •    Ты делаешь мост между Combine и async/await
    •    Ты делаешь кастомные concurrency primitives (как Swift Concurrency под капотом)

*/


//🧪 Проверим, понял ли ты
//
//Можешь ли ты написать функцию fetchText() на основе этой «старой»:
