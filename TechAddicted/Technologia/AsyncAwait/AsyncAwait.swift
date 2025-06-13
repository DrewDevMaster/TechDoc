//
//  AsyncAwait.swift
//  TechAddicted
//
//  Created by Drew on 05.06.2025.
//

import SwiftUI

struct User2: Decodable {
    let id: Int
    let name: String
    let email: String
}

final class UserService {
    func fetchUser() async throws -> User2 {
        let url = URL(string: "https://jsonplaceholder.typicode.com/users/1")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(User2.self, from: data)
    }
}

@MainActor
final class UserViewModel1: ObservableObject {
    @Published var user: User2?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service = UserService()

    func loadUser() {
        Task {
            /*
            let result = try? await service.fetchUser()
            if let name = result?.name {
                print(name)
            }
             */
            do {
                isLoading = true
                let result = try await service.fetchUser()
                user = result
            } catch {
                errorMessage = "Ошибка загрузки: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
}

struct AsyncSampleContentView: View {
    @StateObject var vm = UserViewModel1()

    var body: some View {
        VStack {
            if vm.isLoading {
                ProgressView("Загрузка...")
            } else if let user = vm.user {
                Text("Имя: \(user.name)")
                Text("Email: \(user.email)")
            } else if let error = vm.errorMessage {
                Text(error).foregroundColor(.red)
            }

            Button("Загрузить") {
                vm.loadUser()
            }
        }
        .padding()
    }
}

/*
 
 🚀 Урок 1: async/await — Основы

 🔧 Цель

 Понять, как работает асинхронность в Swift на базовом уровне.

 ✅ Что мы разберём
     •    async и await на примере загрузки данных с сервера
     •    Сравнение с completion-ами
 
 🔍 1. Что такое async throws
 
 func fetchUser() async throws -> User
 
 •    async — говорит компилятору: эта функция может выполняться асинхронно (то есть она приостанавливается и потом продолжается, не блокируя текущий поток, в основном — главный UI-поток).
 •    throws — значит, что функция может выбросить ошибку, которую нужно будет обработать через try / do-catch.

👉 В связке:
 •    async throws — это функция, которая может долго выполняться (например, сетевой запрос) и завершиться с ошибкой.

⸻

🔍 2. Что такое try await — может ли быть try? await или try! await
 
 let (data, _) = try await URLSession.shared.data(from: url)
 
 Здесь:
     •    await говорит: «подожди результат асинхронной операции».
     •    try говорит: «эта операция может бросить ошибку, и мы её ловим».

 Ты можешь использовать и другие формы:

 ✅ try await — нормальный способ, требует do/catch
 
 do {
     let result = try await fetchUser()
 } catch {
     print("Произошла ошибка: \(error)")
 }
 
 ✅ try? await — безопасная попытка: вернёт nil, если была ошибка
 let result = try? await fetchUser()
 if let name = result?.name {
     print(name)
 }
 
 
 🔍 3. Что такое @MainActor и почему он ставится на весь класс
 @MainActor
 final class UserViewModel: ObservableObject {
    ...
 }
 
 •    @MainActor гарантирует, что весь код в этом классе выполняется на главном потоке.
 •    Это критично, когда ты работаешь с UI (@Published, SwiftUI) — любые изменения UI должны быть на главном потоке, иначе получишь баги или краши.

Можно использовать @MainActor:
 •    🔹 на классе — тогда все функции, свойства и методы исполняются на главном потоке
 •    🔸 на конкретной функции — если тебе нужно пометить только её:
 
 @MainActor
 func updateUI() { ... }
 ✅ В реальных проектах @MainActor на весь ViewModel — хорошая практика.

 🧠 Суть: не весь код должен быть на главном потоке

 Ты абсолютно прав:
     •    UI должен обновляться на главном потоке
     •    тяжёлые вычисления, парсинг, фильтрации, работа с файлами/базами данных — должны выполняться в фоновом потоке
 
 🎯 Как это делается с @MainActor и Task

 Ты можешь частично использовать @MainActor, и передавать исполнение между потоками, вот как:
 */

final class UserViewModel111: ObservableObject {
    
    @Published var userName: String = ""
    var filteredUsers = [User2]()
    func loadUser() {
        Task {
            // 1️⃣ Выполняем в фоновом потоке
            let user = try await UserService().fetchUser()
            
            // 2️⃣ Переключаемся на главный поток для обновления UI
            await MainActor.run {
                self.userName = user.name
            }
        }
    }
    
    //✅ Пример: тяжёлая фильтрация списка

    func filterLargeList(_ items: [User2]) {
        Task {
            let result = await withCheckedContinuation { continuation in
                DispatchQueue.global().async {
                    let filtered = items.filter { $0.name.contains("a") }
                    continuation.resume(returning: filtered)
                }
            }

            await MainActor.run {
                self.filteredUsers = result
            }
        }
    }
}







