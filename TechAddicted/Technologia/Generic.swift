//
//  Generic.swift
//  TechAddicted
//
//  Created by Drew on 05.06.2025.
//

import SwiftUI

/*
 Что такое generics.  И как их используешь? Как ограничить тип?  В Swift "generics" (или универсальные типы) позволяют создавать гибкие и многоразовые функции и типы, которые могут работать с любым типом, при условии сохранения безопасности типов. Generics — это один из способов обеспечения повторного использования кода.

 */

func swapValues<T>(_ a: inout T, _ b: inout T) {
    let temp = a
    a = b
    b = temp
}

enum GenericTest {
    func test() {
        
        var x = 5
        var y = 10
        swapValues(&x, &y) // Работает с Int
        
        var a = "Hello"
        var b = "World"
        swapValues(&a, &b) // Работает с String
    }
}

// Ограничение протоколом:

protocol NetworkLayer {
    func callAPI()
}

func printName<T: NetworkLayer>(_ value: T) {
    value.callAPI()
}

//Ограничение типом:

func compare<T: Equatable>(_ a: T, _ b: T) -> Bool {
    return a == b
}

// Несколько ограничений (через where):

func logIfEqual<T>(_ a: T, _ b: T) where T: Equatable, T: NetworkLayer {
    if a == b {
        print("Equal: \(a)")
    }
}

/*
 
 Где применяются generics в стандартной библиотеке?
     •    Array<T>, Dictionary<Key, Value> — стандартные коллекции используют generics.
     •    Optional<T> — обертка над значением любого типа.
     •    Result<Success, Failure> — для работы с результатом, содержащим значение или ошибку.
 
 
 
 
 Почему generics полезны для переиспользования кода?
 
 1. Писать универсальные функции и типы
 Вместо того чтобы писать одну и ту же функцию для разных типов данных (например, Int, String, Double)
 */


//2. Сохранять типобезопасность.
//Позволяет ограничить тип и видеть несовместимость во время разработки (инкрементальный анализ кода (type-checker).)


//❌ Без generics (небезопасно)

class Storage {
    func save(_ value: Any, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }

    func load(forKey key: String) -> Any? {
        UserDefaults.standard.object(forKey: key)
    }
}

class StorageTest {
    func test() {
        // Использование
        let storage = Storage()
        storage.save(42, forKey: "userId")
        let userId = storage.load(forKey: "userId") as? String  // 💥 Ошибка: это Int, а не String
    }
}

//✅ С generics (типобезопасно)

class TypedStorage {
    func save<T: Codable>(_ value: T, forKey key: String) {
        let data = try? JSONEncoder().encode(value)
        UserDefaults.standard.set(data, forKey: key)
    }

    func load<T: Codable>(forKey key: String, as type: T.Type) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}


class TypedStorageTest {
    func test() {
        // Использование
        let storage = TypedStorage()
        storage.save(42, forKey: "userId")

        let userId: Int? = storage.load(forKey: "userId", as: Int.self) // ✅ ОК
        let name: String? = storage.load(forKey: "userId", as: String.self) // ❌ Ошибка при декодировании (видна сразу в тестах)
    }
}

// 3.Уменьшить дублирование кода
// Напрмер

struct User333 {
    let name: String
}

struct Product {
    let title: String
}

//❌ Без generics: дублирование

struct UserListView: View {
    let users: [User333]

    var body: some View {
        List(users, id: \.name) { user in
            Text(user.name)
        }
    }
}

struct ProductListView: View {
    let products: [Product]

    var body: some View {
        List(products, id: \.title) { product in
            Text(product.title)
        }
    }
}

//✅ С generics: переиспользуемый компонент

struct GenericList<T, Content: View>: View {
    let items: [T]
    let id: KeyPath<T, String>
    let rowBuilder: (T) -> Content

    var body: some View {
        List(items, id: id) { item in
            rowBuilder(item)
        }
    }
}

//

struct GenericContentView: View {
    let users = [User333(name: "Alice"), User333(name: "Bob")]
    let products = [Product(title: "iPhone"), Product(title: "MacBook")]

    var body: some View {
        VStack {
            GenericList(items: users, id: \.name) { user in
                Text("👤 \(user.name)")
            }

            GenericList(items: products, id: \.title) { product in
                Text("📦 \(product.title)")
            }
        }
    }
}


//4. Построение обобщённых коллекций и алгоритмов

class Cache<Key: Hashable, Value> {
    private var storage: [Key: Value] = [:]

    func insert(_ value: Value, for key: Key) {
        storage[key] = value
    }

    func value(for key: Key) -> Value? {
        return storage[key]
    }

    func removeValue(for key: Key) {
        storage.removeValue(forKey: key)
    }

    func removeAll() {
        storage.removeAll()
    }
}

func CacheTesting() {
    let imageCache = Cache<String, UIImage>()
    imageCache.insert(UIImage(named: "avatar")!, for: "profilePic")
    let profilePic = imageCache.value(for: "profilePic")

    let userCache = Cache<Int, User333>()
    userCache.insert(User333(name: "Alice"), for: 1)
    let user = userCache.value(for: 1)
}

// 🔁 Обобщённый алгоритм фильтрации

func filter<T>(_ input: [T], where predicate: (T) -> Bool) -> [T] {
    var result: [T] = []
    for element in input where predicate(element) {
        result.append(element)
    }
    return result
}

func testFilteration() {
    let numbers = [1, 2, 3, 4, 5]
    let even = filter(numbers) { $0 % 2 == 0 } // [2, 4]

    let users = [User333(name: "Alice"), User333(name: "Bob")]
    let filtered = filter(users) { $0.name.hasPrefix("A") } // [Alice]
}

//✅ 5. Инкапсуляция логики
//Вы можете обобщать не только функции, но и классы, структуры и протоколы. Это помогает строить более чистую, модульную и расширяемую архитектуру.

struct Stack<T> {
    private var elements: [T] = []

    mutating func push(_ value: T) {
        elements.append(value)
    }

    mutating func pop() -> T? {
        elements.popLast()
    }
}

func StackUsageTest () {
    var x = Stack<String>()
    let lastItem = x.pop()
}

//

protocol APIModel: Decodable {}

struct User1: APIModel {
    let id: Int
    let name: String
}

struct Product1: APIModel {
    let id: Int
    let title: String
}

class NetworkServiceTech {
    func fetch<T: APIModel>(from url: URL, completion: @escaping (Result<T, Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "EmptyData", code: -1)))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

func usageNetworkService() {
    let userURL = URL(string: "https://example.com/user.json")!
    let productURL = URL(string: "https://example.com/product.json")!

    let service = NetworkServiceTech()

    service.fetch(from: userURL) { (result: Result<User1, Error>) in
        switch result {
        case .success(let user):
            print("User loaded:", user)
        case .failure(let error):
            print("Error:", error)
        }
    }

    service.fetch(from: productURL) { (result: Result<Product1, Error>) in
        // ...
    }
}
