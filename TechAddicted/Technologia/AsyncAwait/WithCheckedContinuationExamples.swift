//
//  WithCheckedContinuationExamples.swift
//  SwiftConcurrencyPlayground
//
//  Created by ChatGPT
//

import Foundation

// MARK: - Основы: Что такое withCheckedContinuation

/*
 withCheckedContinuation — это способ обернуть асинхронный код на колбэках
 (completion handlers) в красивый async/await стиль.

 Преимущество:
 - Позволяет адаптировать сторонние API, написанные до Swift Concurrency
 - Даёт полный контроль, когда и как завершить задачу
 - Используется в мостах между Combine, NotificationCenter, CoreBluetooth, и т.п.
 */

// MARK: - Пример 1: Эмуляция async-функции

func oldAsyncFunc(completion: @escaping (String) -> Void) {
    DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
        completion("Готово!")
    }
}

func newAsyncFunc() async -> String {
    await withCheckedContinuation { continuation in
        oldAsyncFunc { result in
            continuation.resume(returning: result)
        }
    }
}

// MARK: - Пример 2: Версия с ошибками (throwing)

enum NetworkError: Error {
    case invalidData
}

func simulateDownload(completion: @escaping (Result<Data, Error>) -> Void) {
    DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
        if Bool.random() {
            completion(.success(Data("OK".utf8)))
        } else {
            completion(.failure(NetworkError.invalidData))
        }
    }
}

func downloadFileAsync() async throws -> Data {
    try await withCheckedThrowingContinuation { continuation in
        simulateDownload { result in
            switch result {
            case .success(let data):
                continuation.resume(returning: data)
            case .failure(let error):
                continuation.resume(throwing: error)
            }
        }
    }
}

// MARK: - Пример 3: Использование в Task

@MainActor
final class SampleViewModel: ObservableObject {
    @Published var resultText: String = "Ожидание..."

    func load() {
        Task {
            let result = await newAsyncFunc()
            self.resultText = result
        }
    }

    func loadWithErrorHandling() {
        Task {
            do {
                let data = try await downloadFileAsync()
                self.resultText = "Загружено: \(data.count) байт"
            } catch {
                self.resultText = "Ошибка: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - Тестовое задание

/*
 Условие:
 У тебя есть старая функция:

 func simulateNetworkCall(completion: @escaping (String?) -> Void) {
     DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
         completion("Привет из сети!")
     }
 }

 Напиши функцию:

 func fetchText() async -> String

 Используй withCheckedContinuation и верни текст. Если nil — верни "Нет данных".
 */

func simulateNetworkCall(completion: @escaping (String?) -> Void) {
    DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
        completion("Привет из сети!")
    }
}

// TODO: Напиши реализацию здесь:
func fetchText() async -> String {
    await withCheckedContinuation { continuation in
        simulateNetworkCall { resultString in
            let finalStr = resultString ?? "Нет данных"
            continuation.resume(returning: finalStr)
        }
    }
}


//1.    Что делает ключевое слово async в сигнатуре функции? Показывает что функция может выполнятся с задержкой
//2.    Что делает await и почему он обязателен? Показывает что мы должны не ожидать ответ сейчас а дождатся пока ответа в случаи задержки
//3.    Когда стоит использовать try await, а когда — просто await? Используем try когда функция throw и может вернуть ошибку которую мы сможем обработать.
//4.    Чем try? отличается от try! и обычного try? В случаи с try? при ошибке нам вернет nil, в try мы вынуждены будем написать сценарий обрабтки ошибки, а force используем когда уверены что nil не будет
//5.    Что делает @MainActor? В каких случаях его стоит применять ко всему классу, а не только к функции? @MainActor гарантирует выполнение в главном потоке. Можем его использовать во всем классе если там нет сложных вычислений, но иначе лучше использовать для конкретного метода класса или использовать другие механизмы, например detached или await MainActor.run {}
//6.    Что такое Task и какие плюсы в использовании Task {} внутри ViewModel? Не знаю, мы это не проходили
//7.    Что делает withCheckedContinuation и в каких случаях он тебе нужен? withChackedContinuation можно использовать когда нам нужно перевести старую асинхронную функцию в async/await
//8.    В чём разница между withCheckedContinuation и withCheckedThrowingContinuation? withCheckedThrowingContinuation может также отдавать блок с ошибкой который можно отдельно обработать

//🧪 Задание 1
//Твоя задача:
//    1.    Создай функцию loginAsync(username:) async throws -> String
//    2.    Оберни fakeLogin в withCheckedThrowingContinuation
//    3.    Обработай её с do/catch в Task {}

func fakeLogin1234(username: String, completion: @escaping (Result<String, Error>) -> Void) {
    DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
        if username == "admin" {
            completion(.success("Добро пожаловать, admin"))
        } else {
            completion(.failure(NSError(domain: "Login", code: 401, userInfo: [NSLocalizedDescriptionKey: "Неверный логин"])))
        }
    }
}

func loginAsync(username: String) async throws -> String {
    try await withCheckedThrowingContinuation { continuaton in
        fakeLogin1234(username: username) { result in
            
            continuaton.resume(with: result)
            
            /*
            Или можно так, если я правильно понял то разницы не будет
             
            switch result {
            case .success(let text):
                continuaton.resume(returning: text)
            case .failure(let error):
                continuaton.resume(throwing: error)
            }
             */
        }
    }
}

final class LoginTestViewModel: ObservableObject {
    
    @Published var loginStateString = ""
    @Published var showErrorUIForLoginState = false
    
    func usageofLoginAsync() {
        Task {
            do {
                let result = try await loginAsync(username: "some_username")
                // Обновляем UI в главном потоке
                await MainActor.run {
                    self.loginStateString = result
                }
            } catch {
                // Обновляем UI в главном потоке
                await MainActor.run {
                    self.loginStateString = error.localizedDescription
                    self.showErrorUIForLoginState = true
                }
            }
        }
    }
}

/*
🧪 Задание 2: @MainActor и UI
    1.    Создай @MainActor final class UserViewModel: ObservableObject
    2.    Добавь Published-свойство @Published var status: String = "Не авторизован"
    3.    Добавь метод authorize() — он запускает Task, вызывает loginAsync, и обновляет status
*/

@MainActor
final class UserViewModel: ObservableObject {
    
    @Published var status: String = "Не авторизован"
    
    func authorize() {
        Task {
            do {
                let result = try await loginAsync(username: "some_username")
                // Обновляем UI в главном потоке
                await MainActor.run {
                    self.status = result
                }
            } catch {
                // Обновляем UI в главном потоке
                await MainActor.run {
                    self.status = error.localizedDescription
                }
            }
        }
    }
}

/*
 🧪 Задание 3: Понимание try/await

 Что выведет следующий код и почему?
 */

func failableAsync() async throws -> String {
    throw URLError(.notConnectedToInternet)
}

func safeCaller() async {
    let value = try? await failableAsync()
    print(value ?? "Нет значения")
}
//Ответ
//print не выведет строку "Нет значения" так как мы явно отдаем ошибку throw URLError(.notConnectedToInternet) и распечатает ее и все свойства обьекта, например код ошибки, errorDomain
