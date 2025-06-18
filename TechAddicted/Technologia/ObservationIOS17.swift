
//
//  ObservableMacroExample.swift
//  SwiftUI iOS 17+
//
//  Показывает разницу между @Observable (новый способ) и ObservableObject (старый способ)
//

import SwiftUI
import Observation // Нужен для @Observable (Swift 5.9+)

/*
 🆕 @Observable — альтернатива ObservableObject
     •    @Observable — это макрос, который автоматически делает класс наблюдаемым без необходимости вручную подписываться на ObservableObject и использовать @Published.
     •    В отличие от @Published, он наблюдает за всеми изменяемыми свойствами по умолчанию (var count здесь автоматически отслеживается).

 🔹 Преимущества:
     •    Нет необходимости писать @Published.
     •    Лучше производительность (меньше обёрток, меньше свифтового boilerplate).
     •    Интеграция с новым Observation API (внутренне построено на ObservationTracking).

 ⸻

 🧾 @ObservationIgnored — исключение из наблюдения
     •    Используется, чтобы исключить конкретное свойство из автоматического отслеживания изменений.
     •    В этом примере:
 @ObservationIgnored
 private var internalCounter = 0
 
 
 — internalCounter не будет триггерить обновление вьюшки, даже если он меняется.

 ⸻

 🧠 Как это работает в связке с View
 
 @State private var viewModel = ObservableMacroViewModel()
 
 Используется @State, потому что viewModel создается внутри View, и его жизненный цикл должен сохраняться при перерисовках.
 •    Благодаря @Observable, все изменения в viewModel.count автоматически приводят к обновлению вью, без @Published, @ObservedObject и objectWillChange.

⸻

🔄 Чем отличается от старого подхода?
 
 Старый (ObservableObject)
 Новый (@Observable)
 @Published var count
 var count
 @ObservedObject или @StateObject
 @State с @Observable моделью
 ручное управление objectWillChange
 автоматическое отслеживание
 используется Combine
 использует Observation API (iOS 17)

 ❗️Важно:
     •    Работает только на iOS 17+, macOS 14+ и с поддержкой Swift 5.9+
     •    Нужен импорт SwiftUI и проект на SwiftData / Observation Runtime

 ⸻

 📌 Вывод

 Ты используешь новейший SwiftUI подход, который упрощает и ускоряет создание реактивных ViewModel. Он уменьшает связанный с Combine boilerplate и делает код чище.

 */

// MARK: - Новый способ: @Observable

@Observable
class NewCounterViewModel {
    var count = 0 // Автоматически отслеживается SwiftUI
    @ObservationIgnored var internalLog = [String]() // Не влияет на перерисовку

    func increment() {
        count += 1
        internalLog.append("Incremented to \(count)")
    }
}


// MARK: - Старый способ: ObservableObject + @Published

class OldCounterViewModel: ObservableObject {
    @Published var count = 0 // Явно помечаем, чтобы SwiftUI отслеживал
    var internalLog = [String]() // Не отслеживается SwiftUI

    func increment() {
        count += 1
        internalLog.append("Incremented to \(count)")
    }
}


// MARK: - View с использованием @Observable (новый способ)

struct NewCounterView: View {
    @State private var viewModel = NewCounterViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("New Count: \(viewModel.count)")
                .font(.title)

            Button("Increment") {
                viewModel.increment()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}


// MARK: - View с использованием ObservableObject (старый способ)

struct OldCounterView: View {
    @StateObject private var viewModel = OldCounterViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("Old Count: \(viewModel.count)")
                .font(.title)

            Button("Increment") {
                viewModel.increment()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}


// MARK: - Пример превью

struct ObservableMacroExample_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            NewCounterView()
                .tabItem { Label("New", systemImage: "bolt") }

            OldCounterView()
                .tabItem { Label("Old", systemImage: "clock") }
        }
    }
}
