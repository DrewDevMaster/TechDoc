import Foundation
// MARK: - 🧠 Тема: async let — параллельное выполнение асинхронных операций

// 🔑 Ключевая идея:
// async let позволяет запускать несколько async-операций одновременно и затем ожидать их результат.
// Это более эффективный способ, чем делать await по очереди.

// 🤯 Пример: загрузка данных параллельно

func fetchUserAndPosts() async throws -> (String, Int) {
    async let user = fetchName()           // стартуем обе задачи параллельно
    async let posts = fetchAge()         // в фоне тоже начата

    // ждем завершения обеих
    return try await (user, posts)
}

// ⚠️ Если бы мы использовали let user = try await fetchUser(), а потом let posts = try await fetchPosts(), они бы выполнялись последовательно.

// 🧪 Задание для тебя:

// Условия:
func fetchName() async throws -> String {
    try await Task.sleep(nanoseconds: 2_000_000_000) // 2 секунды
    return "Имя: Алекс"
}

func fetchAge() async throws -> Int {
    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 секунда
    return 30
}

// Напиши функцию:
func fetchProfile() async throws -> String {
    print(Date().timeIntervalSince1970)
    async let name = fetchName()
    async let age = fetchAge()
    let userName = try await name
    let userAge = try await age
    let string = "\(userName), \(userAge) лет"
    print(Date().timeIntervalSince1970)
    return string
}

// ⏱ Проверь: с async let выполнение займет около 2 сек, а не 3.

// 🔍 После задания обсудим:
// - где использовать async let, а где Task {} или TaskGroup
// - что будет, если ошибка возникнет в одной из задач
