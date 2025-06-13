//
//  TaskBasics.swift
//  AsyncAwaitTraining
//
//  Created by ChatGPT on 2025-06-05
//

import SwiftUI

func heavyCalculation() { }

/*
🧠 Что такое Task?

Task {} — это способ запустить асинхронную операцию снаружи sync-функции.
Ты не можешь вызвать await в обычной функции (например, в onAppear или кнопке), но можешь создать задачу Task

⸻

📌 Когда используется Task {}
    •    Внутри обычной (не-async) функции.
    •    В ViewModel или View, чтобы не блокировать поток.
    •    Чтобы запустить фоновую работу независимо (или с контролем приоритета).
    •    Когда не нужен async let, а просто асинхронный блок.

⚠️ Task {} vs async let

Task {}
async let
Где использовать
Вне async-функций
Внутри async-функций
Можно отменять
✅ Да
❌ Нет (встроено, но без cancel)
Поддерживает приоритет
✅ Да (.userInitiated, и т.д.)
❌ Нет
Когда завершится
Когда дождались или завершили
Когда await вызван на всех

*/


struct ViewForTestingTask: View {
    
    @State var title = "button"
    
    var body: some View {
        Button(title) {
            //
            Task {
                let str = try await fetchProfile()
                print(str)
                title = str
            }
        }
    }
}
               

// MARK: - ViewModel using Task

final class MyViewModel: ObservableObject {
    @Published var text = ""

    func fetch() {
        Task {
            let data = await loadData()
            await MainActor.run {
                self.text = data
            }
        }
    }

    func loadData() async -> String {
        // Симуляция задержки
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        return "Ответ с сервера"
    }
}

// MARK: - View demonstrating Task usage

struct MyTaskExampleView: View {
    @StateObject private var viewModel = MyViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text(viewModel.text.isEmpty ? "Нажми кнопку" : viewModel.text)
                .padding()

            Button("Загрузить") {
                viewModel.fetch()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    MyTaskExampleView()
}

/*
 🧪 Тестовое задание:
     1.    Напиши простую View с кнопкой.
     2.    По нажатию вызывается Task {}.
     3.    Внутри Task вызывается await-функция loadUserData(), которая ждёт 2 секунды и возвращает строку.
     4.    Отобрази результат в тексте на экране.
 */


// MARK: - Task vs Task.detached Explanation

// Task {}
// - Наследует actor context, например, @MainActor
// - Наследует task-local values (например, приоритет)
// - Подходит для UI и ViewModel логики
// - Может выполняться на главном потоке

// Task.detached {}
// - Не наследует ни actor context, ни task-local values
// - Выполняется независимо от текущего контекста
// - Хорошо подходит для фоновых задач
// - Требует ручного возврата в MainActor при обновлении UI

// MARK: - Пример Task {}

@MainActor
final class ExampleViewModel: ObservableObject {
    @Published var name = ""

    func loadData() {
        Task {
            let result = try await fetchName()
            self.name = result // безопасно — мы на MainActor
        }
    }
}

// MARK: - Пример Task.detached {}

func processInBackground() {
    Task.detached {
        let result = try await heavyCalculation()

        // Обновить UI — нужно явно прыгнуть на MainActor
        await MainActor.run {
            print("Результат: \(result)")
        }
    }
}

// MARK: - Когда использовать

// | Задача                                          | Используй          |
// |------------------------------------------------|---------------------|
// | Обновить UI из ViewModel                       | Task {} (MainActor) |
// | Параллельная работа с сетью или диском         | Task {} или async let |
// | Выйти из MainActor (напр., в init без UI)      | Task.detached {} |
// | Запустить фоновый бесконечный цикл             | Task.detached {} |
// | Вызов в init() обычного класса, не ViewModel   | Task.detached {} |



/*
🔍 Когда использовать Task.detached {}

Task.detached нужен только тогда, когда ты хочешь создать асинхронную задачу, не зависящую от текущего контекста:
    •    не наследует @MainActor
    •    не наследует приоритет родительского Task
    •    независим от иерархии задачи — будет жить своей жизнью

 */

 // ✅ Практические сценарии использования

 import SwiftUI

 // 1. Task.detached в init класса
 class HeavyInitLoader {
     init() {
         Task.detached {
             let result = try await HeavyInitLoader.fetchHeavyInitialData()
             await MainActor.run {
                 print("Готово: \(result)")
             }
         }
     }

     static func fetchHeavyInitialData() async throws -> String {
         try await Task.sleep(nanoseconds: 1_000_000_000)
         return "Загружено из init"
     }
 }

 // 2. Task.detached для фона (например, GPS tracking)
 final class BackgroundService {
     func start() {
         Task.detached(priority: .background) {
             while true {
                 let data = try await BackgroundService.fetchLocation()
                 await MainActor.run {
                     print("Обновлена позиция: \(data)")
                 }
                 try await Task.sleep(nanoseconds: 5 * 1_000_000_000)
             }
         }
     }

     static func fetchLocation() async throws -> String {
         return "Lat: 45.0, Lon: 28.0"
     }
 }

 // 3. Task.detached для сохранения логов
 func logToDisk(_ message: String) {
     Task.detached {
         try await writeToDisk(message)
     }
 }

 func writeToDisk(_ message: String) async throws {
     // Симуляция задержки
     try await Task.sleep(nanoseconds: 500_000_000)
     print("Лог сохранён: \(message)")
 }

 // 4. Задача, которая должна выполниться даже после закрытия UI
 func reportCrash(_ crash: String) {
     Task.detached {
         try await sendCrashToServer(crash)
     }
 }

 func sendCrashToServer(_ crash: String) async throws {
     try await Task.sleep(nanoseconds: 1_000_000_000)
     print("Отчёт о краше отправлен: \(crash)")
 }

 // Пояснение:
 // Task.detached используется тогда, когда нужна полная независимость от UI, Task-иерархии и Actor-контекста
 // Никогда не обновляй UI напрямую внутри Task.detached — используй await MainActor.run {}

/*
Task.detached {}

Вот упрощённый жизненный цикл:
    1.    Когда ты вызываешь Task.detached, ты создаёшь новую задачу верхнего уровня (top-level task), которая:
    •    не является “дочерней” по отношению к какому-либо родительскому Task,
    •    не наследует контекст актора (например, не будет привязана к @MainActor),
    •    не наследует task-local values (локальные значения задачи).

    2.    Приоритет задачи:
    •    Если не указал приоритет (Task.detached {}), то будет использован по умолчанию .medium

*/

/// Приоритеты Task от наивысшего к наименьшему
/// ------------------------------------------------------------
///
/// 1️⃣ high — Очень высокая, выше чем userInitiated
/// 2️⃣ userInitiated — Пользователь ждёт результат
/// 3️⃣ medium — Стандартный приоритет (по умолчанию)
/// 4️⃣ utility — Фоновая работа, долгие задачи
/// 5️⃣ low — Малозначимые задачи, не срочно
/// 6️⃣ background — Максимально фоновая, минимальный приоритет

// Пример практического использования для каждого TaskPriority

func runTaskPriorityExamples() {
    
    // 1️⃣ HIGH (высочайший приоритет)
    Task.detached(priority: .high) {
        print("🔥 HIGH priority task started")
        // Пример: срочная отправка сообщения после нажатия кнопки "Отправить"
        // Пример: критический push-уведомление пользователю
    }
    
    /*
     
    Примеры для .high

    1️⃣ Push-уведомление + срочная синхронизация:

    Когда получено push-уведомление о важном событии (например, новое сообщение в чате),
    и ты хочешь быстро синхронизировать переписку и обновить UI:
    
    2️⃣ Финансовые транзакции (например оплата):

    Когда пользователь нажал “Оплатить”, и ты отправляешь транзакцию — важнейшая операция:
    
    
    3️⃣ Безопасность / биометрия:

    При запросе подтверждения с FaceID / TouchID + быстрая валидация доступа:
    
    4️⃣ Срочная отрисовка анимации:

    В некоторых случаях (например, в играх или в приложениях с heavy animation) ты можешь использовать .high чтобы подготовить ресурс:
    
    5️⃣ Сброс пароля / одноразовый код (OTP):
    Когда пришел одноразовый код по SMS / Email и ты хочешь немедленно синхронизировать его в UI:
    
    Итоги

    ✅ .high — редкий, но важный инструмент
    ✅ Используй только там, где важно:
        •    реактивно
        •    быстро
        •    немедленно отработать событие
        •    где задержка ухудшает UX или критична для логики (платежи, биометрия, OTP, синхрон чата и т.п.)

    ✅ Важно не злоупотреблять .high — иначе приоритет перестает иметь смысл и начинает блокировать другие важные задачи.
    */
    
    // 2️⃣ USER_INITIATED
    // пользователь ЯВНО инициировал и ожидает увидеть результат быстро.
    Task.detached(priority: .userInitiated) {
        print("👤 USER_INITIATED priority task started")
        // Пример: загрузка данных профиля после открытия профиля
        // Пример: создание PDF после нажатия "Скачать"
        // Пример: быстрый парсинг большого файла по запросу пользователя
    }
    
    // 3️⃣ MEDIUM (по умолчанию)
    Task.detached {
        print("⚙️ MEDIUM (default) priority task started")
        // Пример: запрос в сеть, который не блокирует UI
        // Пример: подгрузка не очень срочных данных
        // Пример: аналитика во время пользовательского сценария
    }
    
    // 4️⃣ UTILITY
    Task.detached(priority: .utility) {
        print("🔧 UTILITY priority task started")
        // Пример: резервное копирование данных
        // Пример: синхронизация с сервером в фоне
        // Пример: обработка изображений для кэша
    }
    
    // 5️⃣ LOW
    Task.detached(priority: .low) {
        print("🐢 LOW priority task started")
        // Пример: очистка старых кэшей
        // Пример: не срочное обновление базы данных
        // Пример: запись в лог-файл
    }
    
    // 6️⃣ BACKGROUND (самый низкий приоритет)
    Task.detached(priority: .background) {
        print("🌌 BACKGROUND priority task started")
        // Пример: логгирование, отправка статистики
        // Пример: запись telemetry событий
        // Пример: обновление неважных данных когда девайс на зарядке
    }
    
}

// Для теста можешь вызвать runTaskPriorityExamples() например в .onAppear в View
// или в AppDelegate / SceneDelegate



// MRAK: - Что такое task-local values

/*

👉 В Swift 5.5+ у каждой Task может быть свой локальный контекст (task-local values).
Это как переменные, локальные для данной цепочки задач (Task chain).
    •    Они автоматически передаются в дочерние Task-и, созданные внутри Task.
    •    Но не передаются в detached задачи (Task.detached).

Task-local values — это специальный механизм Swift Concurrency (не просто обычные переменные).
Для их создания используется @TaskLocal property wrapper.

⸻

Пример

Допустим у тебя есть контекст пользователя:
 @TaskLocal static var currentUserID: String?
 
 Теперь, если ты пишешь:
 Task {
     currentUserID = "user123"
     
     await doSomeWork() // Видит currentUserID == "user123"
     
     Task {
         await doMoreWork() // Видит currentUserID == "user123" (наследуется!)
     }
     
     Task.detached {
         await doDetachedWork() // НЕ видит currentUserID == "user123", currentUserID == nil
     }
 }
 
 Почему так?

 👉 Когда ты создаёшь:

 ✅ Task {} — создаётся дочерний Task, он наследует:
     •    приоритет
     •    actor context
     •    task-local values

 ✅ Task.detached {} — создаётся совершенно новая Task, без привязки к текущему:
     •    НЕ наследует приоритет
     •    НЕ наследует actor context
     •    НЕ наследует task-local values → контекст пуст

 ⸻

 Для чего task-local values реально применяются
     •    логирование → current traceID или requestID
     •    user context → userID, tenantID
     •    feature flags → включены ли определённые фичи
     •    debug flags
     •    auth token
     •    current locale / language

 
 
*/
//
// TaskLocalDemo.swift
// Добавь этот файл в проект и вызови TaskLocalDemo.runExample() из ContentView.onAppear или кнопки.
//


// 1️⃣ Создаём Task-local переменную
//
// TaskLocalDemo.swift
//

enum TaskLocalDemo {

    // Task-local value внутри типа
    @TaskLocal
    static var requestTraceId: String?

    static func runExample() {
        print("🌟 MAIN START")

        // Устанавливаем task-local value через withValue
        Self.$requestTraceId.withValue("user123") {

            print("Task: currentUserID =", requestTraceId ?? "nil")

            Task {
                print("Task: currentUserID =", requestTraceId ?? "nil")
                await doSomeWork()

                // Вложенный Task → унаследует currentUserID
                Task {
                    print("Child Task: currentUserID =", requestTraceId ?? "nil")
                    await doSomeWork()
                }

                // Detached Task → НЕ унаследует currentUserID
                Task.detached {
                    print("Detached Task: currentUserID =", requestTraceId ?? "nil")
                    await doSomeWork()
                }
            }
        }
    }

    static func doSomeWork() async {
        print("doSomeWork: currentUserID =", requestTraceId ?? "nil")
        try? await Task.sleep(nanoseconds: 500_000_000) // Пауза 0.5 сек для демонстрации
    }
}

/*
 
 🌟 MAIN START
 Task: currentUserID = user123
 doSomeWork: currentUserID = user123
 Child Task: currentUserID = user123
 doSomeWork: currentUserID = user123
 Detached Task: currentUserID = nil
 doSomeWork: currentUserID = nil
 
 */


func fetchUserProfile(id: Int) async throws -> UserProfile3000 {
    try await Task.sleep(nanoseconds: 500_000_000) // имитация задержки 0.5 сек
    return UserProfile3000(id: id, name: "User \(id)")
}

struct UserProfile3000 {
    let id: Int
    let name: String
}

/*
 ✅ HW
 
Напиши функцию fetchUserProfiles() async throws -> [UserProfile], которая будет:
    •    для массива id (например [1,2,3,4,5]) параллельно вызывать fetchUserProfile(id:) async throws -> UserProfile (можешь сделать заглушку функции).
    •    использовать withTaskGroup.
    •    собирать результат в массив.
*/
func fetchUserProfiles() async throws -> [UserProfile3000] {
    let usresId = [22,33,55,66]
    
    return await withTaskGroup(of: UserProfile3000?.self) { group in
        
        var usersProfiles = [UserProfile3000]()

        for id in usresId {
            group.addTask {
                let profile = try? await fetchUserProfile(id: id)
                return profile
            }
        }
        
        for await profile in group {
            if let profile = profile {
                usersProfiles.append(profile)
            }
        }
        
        return usersProfiles

    }
    
}

func fetchImages() async throws -> [UIImage] {
    let urls = [
        URL(string: "https://example.com/image1.png")!,
        URL(string: "https://example.com/image2.png")!,
        URL(string: "https://example.com/image3.png")!,
        URL(string: "https://example.com/image4.png")!,
        URL(string: "https://example.com/image5.png")!
    ]
    
    return await withTaskGroup(of: UIImage?.self) { group in
        var images: [UIImage] = []
        
        for url in urls {
            group.addTask {
//                let (data, _) = try? await URLSession.shared.data(from: url)
//                return data.flatMap { UIImage(data: $0) }
                
                let result = try? await URLSession.shared.data(from: url)
                return result.flatMap { UIImage(data: $0.0) }
            }
        }
        
        for await image in group {
            if let image = image {
                images.append(image)
            }
        }
        
        return images
    }
}


struct Article3000 {
    let id: Int
    let title: String
}

/*
 
 🚀 Новое задание (чуть сложнее):

 Функция loadArticles() async throws -> [Article]:
     •    У тебя есть articleIDs = [101, 102, 103, 104, 105].
     •    Напиши fetchArticle(id: Int) async throws -> Article, которая делает задержку 0.3 сек и возвращает Article(id: id, title: "Article \(id)").
     •    Используй withTaskGroup, чтобы параллельно загрузить все статьи.
     •    Собери результат в массив и верни.

 
 
 */
func loadArticles() async throws -> [Article3000] {
    
    let articleIDs = [101, 102, 103, 104, 105]
    
    let gr = await withTaskGroup(of: Article3000?.self) { group in
        var articlesArray = [Article3000]()
        
        for articleId in articleIDs {
            group.addTask {
                let article = try? await fetchArticle(id: articleId)
                return article
            }
        }
        
        for await i in group {
            if let i {
                articlesArray.append(i)
            }
        }
        
        return articlesArray
    }
    
    return gr
}

func fetchArticle(id: Int) async throws -> Article3000 {
    try? await Task.sleep(nanoseconds: 300_000_000)
    return Article3000(id: id, title: "Article \(id)")
}

//next task

/*
 •    Напиши функцию loadArticlesWithThrowingGroup() async throws -> [Article3000]:
 •    Используй withThrowingTaskGroup.
 •    Ошибка должна пробрасываться наверх — не глотать try?.
 •    Если хоть один fetchArticle упал — вся группа должна бросить ошибку.
 •    Если всё ок — возвращай массив статей.
 */

enum FetchArticleError: Error {
    case failed
}

func fetchArticle4000(id: Int) async throws -> Article3000 {
    try? await Task.sleep(nanoseconds: 300_000_000)
    if Bool.random() {
        throw FetchArticleError.failed
    }
    return Article3000(id: id, title: "Article \(id)")
}

func loadArticlesWithThrowingGroup() async throws -> [Article3000] {
    
    let articleIDs = [101, 102, 103, 104, 105]

    let throwingGroup = try await withThrowingTaskGroup(of: Article3000.self) { group in
        var articleArray = [Article3000]()
        
        for id in articleIDs {
            group.addTask(priority: .medium) {
                let articleById = try await fetchArticle4000(id: id)
                return articleById
            }
        }

        for try await newArticle in group {
            articleArray.append(newArticle)
        }
// or
    /*
        do {
            for try await newArticle in group {
                articleArray.append(newArticle)
            }
        } catch {
            print("Ошибка загрузки статьи:", error.localizedDescription)
            throw error
        }
     */
        
        return articleArray
    }
    
    return throwingGroup
}
