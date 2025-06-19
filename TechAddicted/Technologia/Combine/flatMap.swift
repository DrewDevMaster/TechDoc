//
//  File.swift
//  TechAddicted
//
//  Created by Drew on 18.06.2025.
//

import Foundation
import Combine

// MARK: flatMap в Combine

/*
 flatMap в Combine — это оператор, который преобразует каждое полученное значение из одного паблишера в новый вложенный паблишер,
 а затем объединяет (flatten) все эти вложенные стримы в один.
 
 📌 Проще говоря:
     •    Ты получаешь значение A,
     •    Превращаешь его в Publisher,
     •    flatMap подписывается на этот Publisher и «выравнивает» всё в общий поток.
 
 🧠 Когда это нужно?

 Когда одно значение из upstream вызывает асинхронную операцию, которая тоже возвращает Publisher, и ты хочешь продолжать работу с её результатом.
 
 
 
 */

private func test() {
    var cancellables = Set<AnyCancellable>()
    
    let userIDPublisher = Just("123")
        .setFailureType(to: Error.self) // потому что fetchUserDetails возвращает Publisher с Error

    userIDPublisher
        .flatMap { id in
            fetchUserDetails(for: id)
        }
        .sink(
            receiveCompletion: { completion in
                print("Finished with: \(completion)")
            },
            receiveValue: { user in
                print("User name: \(user.name)")
            }
        )
        .store(in: &cancellables)
}

private struct User: Decodable {
    let id: String
    let name: String
    let email: String
}

private func fetchUserDetails(for userID: String) -> AnyPublisher<User, Error> {
    let urlString = "https://api.example.com/users/\(userID)"
    guard let url = URL(string: urlString) else {
        return Fail(error: URLError(.badURL))
            .eraseToAnyPublisher()
    }

    return URLSession.shared.dataTaskPublisher(for: url)
        .map(\.data)
        .decode(type: User.self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
}

/*
📌 Здесь:
    •    Just("123") — даёт ID пользователя.
    •    fetchUserDetails(for:) — возвращает AnyPublisher<User, Error>.
    •    flatMap позволяет подписаться на результат fetchUserDetails и “вытянуть” User наружу в общий поток.

⸻

⚠️ Важно:
    •    flatMap не отменяет предыдущие вложенные publisher’ы, если приходит новое значение. Это поведение отличается от switchToLatest, который отменяет предыдущий.
*/
