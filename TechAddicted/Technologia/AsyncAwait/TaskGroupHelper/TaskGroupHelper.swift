import Foundation

// Универсальный helper для обычных TaskGroup
final class TaskGroupHelper {

    /// Запускает обычную TaskGroup для массива ID (или любых элементов)
    static func runTaskGroup<T>(
        ids: [Int],
        task: @escaping (Int) async -> T?
    ) async -> [T] {
        await withTaskGroup(of: T?.self) { group in
            var results = [T]()
            
            for id in ids {
                group.addTask {
                    await task(id)
                }
            }
            
            for await result in group {
                if let value = result {
                    results.append(value)
                }
            }
            
            return results
        }
    }
}

// Универсальный helper для ThrowingTaskGroup
final class ThrowingTaskGroupHelper {

    /// Запускает ThrowingTaskGroup для массива ID (или любых элементов)
    static func runThrowingTaskGroup<T>(
        ids: [Int],
        task: @escaping (Int) async throws -> T
    ) async throws -> [T] {
        try await withThrowingTaskGroup(of: T.self) { group in
            var results = [T]()
            
            for id in ids {
                group.addTask {
                    try await task(id)
                }
            }
            
            for try await result in group {
                results.append(result)
            }
            
            return results
        }
    }
}

/*

let articles = await TaskGroupHelper.runTaskGroup(
    ids: [1, 2, 3, 4, 5]
) { id in
    await fetchArticle3000(id: id) // не кидает throw
}

//
 
do {
    let articles = try await ThrowingTaskGroupHelper.runThrowingTaskGroup(
        ids: [1, 2, 3, 4, 5]
    ) { id in
        try await fetchArticle4000(id: id) // может throw
    }
    
    print("Успешно загружено \(articles.count) статей")
    
} catch {
    print("Ошибка загрузки:", error.localizedDescription)
}

*/
