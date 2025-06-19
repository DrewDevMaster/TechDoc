//
//  SwiftUI vs UIKit missing features.swift
//  TechAddicted
//
//  Created by ViktorM1Max on 19.06.2025.
//

import Foundation

/*
 Отличный и очень практичный вопрос для собеседований и продвинутой работы с SwiftUI. Несмотря на то, что SwiftUI активно развивается, на 2025 год (Swift 5.10, iOS 18) всё ещё есть ограничения, при которых UIKit остаётся необходимым.

 ⸻

 📌 ТОП кейсы, где UIKit нужен в SwiftUI:

 1. Тонкая кастомизация UITextView, UITextField, UISearchBar

 SwiftUI-поля ввода (например, TextField, TextEditor, SearchField) всё ещё ограничены:
     •    Нет доступа к UITextFieldDelegate/UITextViewDelegate
     •    Нет полной кастомизации клавиатуры, автофокуса, cursor-color, inputAccessoryView
     •    Нет полноценной реализации поиска с автофокусом при появлении

 🛠️ Решение: UIViewRepresentable + UITextView/UITextField

 ⸻

 2. Точная работа со скроллингом
     •    Нет полного доступа к offset, contentSize, scrollTo(offset:)
     •    Нельзя вставить scroll indicators или кастомный pull-to-refresh (хотя появился .refreshable)

 🛠️ Решение: UIScrollView + UIViewControllerRepresentable

 ⸻

 3. Тонкая анимация, gesture control, UIGestureRecognizer

 SwiftUI жесты хороши, но:
     •    Нет мульти-жестов (двойной тап + свайп одновременно)
     •    Нет кастомных UIGestureRecognizer

 🛠️ Решение: использовать UIView с gestureRecognizers внутри UIViewRepresentable

 ⸻

 4. WebView

 SwiftUI не имеет собственного WebView.

 🛠️ Решение: использовать WKWebView через UIViewRepresentable.

 ⸻

 5. AVFoundation / Камера / Фото
     •    Нет готового SwiftUI API для AVCaptureSession, AVPlayer, записи видео, сканирования QR-кодов.

 🛠️ Решение: UIKit (UIViewControllerRepresentable) + AVFoundation.

 ⸻

 6. Drag and Drop между разными приложениями / экранами

 SwiftUI поддерживает drag-and-drop, но:
     •    Ограничено только внутри приложения или в одном View
     •    Нет полноценной поддержки UIDragInteraction, UIDropInteraction

 ⸻

 7. Тосты, алерты, popover в любой позиции
     •    SwiftUI .alert, .sheet, .popover — очень ограничены:
     •    нельзя кастомизировать внешний вид
     •    нельзя показывать несколько модальных окон
     •    нельзя размещать popover точно по координатам

 🛠️ Решение: UIKit UIAlertController, кастомные UIViewController

 ⸻

 8. UICollectionView / DiffableDataSource
     •    SwiftUI LazyVGrid, LazyHGrid пока не полностью заменяют UICollectionView:
     •    Нет drag & drop reorder
     •    Нет prefetching
     •    Нет sticky headers

 🛠️ Решение: UICollectionViewController + UIViewControllerRepresentable

 ⸻

 9. Accessiblity: кастомные VoiceOver события
     •    SwiftUI поддерживает базовые .accessibilityLabel, но не даёт тонкий контроль над кастомными событиями, действиями и ротором.

 🛠️ Решение: UIKit UIAccessibility* API

 ⸻

 10. Фоновая работа, Background Tasks UI (например, GPS, Audio Session)
     •    SwiftUI View не имеет контроля над жизненным циклом, сессиями, режимами background audio и т. д.

 🛠️ Решение: UIKit AppDelegate + SceneDelegate

 ⸻

 💡 Вывод:

 Хочешь…                                    SwiftUI справится?      UIKit нужен?
 Отображать список                                  ✅                   ❌
 Работать с камерой, AVPlayer                       ❌                   ✅
 Сделать кастомный TextField с тулбаром             ❌                   ✅
 Показать WebView                                   ❌                   ✅
 Контролировать scroll position точно               ❌                   ✅
 Работать с drag & drop между экранами              ❌                   ✅
 Сделать интерактивный popover с анимацией          ❌                   ✅

 */


// 1. Custom UITextField with Toolbar
import SwiftUI
import UIKit

struct CustomTextField: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.borderStyle = .roundedRect
        textField.inputAccessoryView = context.coordinator.toolbar()
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CustomTextField

        init(_ parent: CustomTextField) {
            self.parent = parent
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }

        func toolbar() -> UIToolbar {
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(dismiss))
            toolbar.items = [done]
            return toolbar
        }

        @objc func dismiss() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}



// 2. UITextView (multiline text editor)
struct CustomTextView: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.systemFont(ofSize: 17)
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CustomTextView

        init(_ parent: CustomTextView) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }
}



// 3. WKWebView
import WebKit
struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}



// 4. UIScrollView with custom content offset handling
struct ScrollableView<Content: View>: UIViewRepresentable {
    var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        let hosting = UIHostingController(rootView: content)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(hosting.view)
        NSLayoutConstraint.activate([
            hosting.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hosting.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hosting.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {}
}



// 5. AVPlayerViewController
import AVKit
struct VideoPlayerView: UIViewControllerRepresentable {
    let player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}



// 6. Custom Popover via UIKit
struct CustomPopoverViewController: UIViewControllerRepresentable {
    let content: () -> UIViewController

    func makeUIViewController(context: Context) -> UIViewController {
        content()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}



// 8. Gesture Recognizer Wrapper
struct CustomGestureView: UIViewRepresentable {
    var onDoubleTap: () -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.doubleTapped))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onDoubleTap: onDoubleTap)
    }

    class Coordinator: NSObject {
        let onDoubleTap: () -> Void
        init(onDoubleTap: @escaping () -> Void) {
            self.onDoubleTap = onDoubleTap
        }

        @objc func doubleTapped() {
            onDoubleTap()
        }
    }
}
