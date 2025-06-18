//
//  Autorelease Pool.swift
//  TechAddicted
//
//  Created by Drew on 18.06.2025.
//

import Foundation
import UIKit

/*
 Что такое Autorelease Pool
 
 Это механизм управления памятью который позволяет отложить высвобождение обьекта из памяти до конца выполнения блока, чтобы избежать немедленного release и контролировать время освобождения объектов.
 
 🧠 Зачем нужен Autorelease Pool?
     •    Чтобы не освобождать объект сразу, а отложить release до конца текущего цикла/контекста.
     •    Это уменьшает частоту обращений к системе управления памятью и повышает производительность.
     •    Позволяет освобождать ресурсы пакетно — особенно важно в больших циклах (например, генерация изображений, парсинг данных и т.п.).
 
 
 ✅ Как работает на самом деле:

 🔹 Без autoreleasepool:
 */

private func test() {
    for i in 0..<10000 {
        let image = UIImage(named: "BigImage_\(i)")
        // обработка
    }
}
/*
 •    UIImage(named:) возвращает autoreleased объект (т.е. он будет удалён позже, не сразу после итерации).
 •    Все эти 10 000 UIImage будут копиться в autorelease pool, созданном глобально в RunLoop.
 •    Они освободятся в конце runloop-а (то есть после всего цикла).
 •    ❗️Проблема: огромный расход памяти, потому что они все “висят” в пуле до конца.
 */

private func test1() {
    for i in 0..<10000 {
        autoreleasepool {
            let image = UIImage(named: "BigImage_\(i)")
            // обработка
        }
    }
}

/*
 •    В каждой итерации создаётся свой локальный autorelease pool, и когда итерация завершилась — объекты в нём сразу освобождаются.
 •    📉 Это резко снижает пиковую нагрузку на память, особенно при работе с тяжёлыми объектами (UIImage, NSData, NSAutoreleasePool-подобные).
 */



/*
•    autoreleasepool {} немного увеличивает нагрузку на CPU, так как создаёт и уничтожает локальный пул в каждой итерации.
•    Но в ситуациях с высоким расходом памяти (например, UIImage, NSData, массивы) — он почти всегда даёт выигрыш в производительности за счёт снижения давления на память и систему.

📊 Сравнение влияния на производительность

Сценарий
Без autoreleasepool
С autoreleasepool
🧠 CPU нагрузка
Ниже (меньше системных вызовов)
Чуть выше (создание/освобождение пула)
🧮 Пиковое потребление памяти
Очень высокое
Значительно ниже
📉 Вероятность тормозов/крашей
Выше
Ниже (меньше утечек и давление на память)
🚀 Общая стабильность при >1000 итерациях
Может ухудшаться
Стабильна


📌 Рекомендации:
🧠 Почему autoreleasepool может немного замедлить CPU:
    •    Каждый вызов autoreleasepool — это низкоуровневый системный вызов (создание/удаление NSAutoreleasePool/objc_autoreleasePoolPush/Pop).
    •    Он очень быстрый, но если ты вызываешь его внутри tight loop-а 10 000+ раз, — нагрузка растёт.
    •    Это пренебрежимо мало для большинства приложений, но может быть важно в real-time задачах (например, frame-by-frame video, ML inference).


Сценарий
Использовать autoreleasepool?
Цикл с большим количеством UIImage, NSData
✅ Да, обязательно
Бэкграунд парсинг JSON, XML
✅ Да
Реалтайм UI, анимации, scroll
⚠️ Лучше избегать внутри main-thread
Лёгкие операции (Int, String)
❌ Не нужно
Обработка файлов, видео, аудио
✅ Да

🔍 Пример: без него — больше пиков

Если в for-цикле загружаются 5000 UIImage и обрабатываются:
    •    Без autoreleasepool: пиковая память может легко вырасти на 500–800 МБ
    •    С autoreleasepool: пиковая память может быть 30–50 МБ — потому что объекты не копятся

⸻

🧾 Вывод

Да, autoreleasepool имеет небольшую цену по CPU, но в обмен даёт огромный выигрыш по памяти и стабильности. В большинстве случаев он ускоряет работу, потому что меньше потребления = меньше давления на систему = меньше лагов и сбоев.
            
*/

/*
Nesting Autorelease Pools
You can also nest autorelease pools for more granular memory management. When a nested pool drains, it only releases objects created within its scope, leaving objects in the outer pool untouched.
                                            
autoreleasepool {
    // Code that may create and autorelease objects
    autoreleasepool {
        // Code that may create and autorelease more objects
    }
    // The inner pool drains, releasing its objects
    // The outer pool continues to manage its objects
}

Example 2: Nesting Autorelease Pools
autoreleasepool {
    let image = loadImageFromFile("image.png")
    autoreleasepool {
        let thumbnail = createThumbnail(image)
        // Process the thumbnail
        // The 'thumbnail' object will be released when the inner pool drains
    }
    // The 'image' object is still managed by the outer pool
}
*/
