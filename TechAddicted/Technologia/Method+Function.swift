//
//  Method+Function.swift
//  TechAddicted
//
//  Created by Drew on 05.06.2025.
//

import Foundation

/*
 
 Разница между методом и функцией?

 В Swift есть разница между методами (methods) и функциями (functions), хотя оба понятия представляют собой блоки кода, которые выполняют определенные действия. Основные отличия между методами и функциями в Swift следующие:
 1. Принадлежность к типу:
     * Методы (methods) являются функциями, которые привязаны к определенному типу данных, такому как класс, структура или перечисление. Методы выполняются в контексте экземпляра этого типа и имеют доступ к его свойствам и другим методам.
     * Функции (functions) являются независимыми блоками кода, которые могут быть вызваны из любого места программы. Они не привязаны к определенному типу данных и могут быть определены в глобальной области или внутри других функций, методов или замыканий.
 2. Синтаксис вызова:
     * Методы вызываются на экземпляре определенного типа, с использованием точечной нотации. Например: object.method().
     * Функции вызываются непосредственно по имени, без указания конкретного экземпляра. Например: function().
 3. Передача параметров:
     * Методы имеют доступ к специальному параметру self, который представляет экземпляр, на котором был вызван метод. Методы также могут принимать другие параметры.
     * Функции могут принимать параметры, но они не имеют доступа к специальному параметру self, так как они не привязаны к конкретному экземпляру.
 4. Наследование и полиморфизм:
     * Методы могут быть унаследованы от базовых классов и переопределены в подклассах. Это позволяет использовать полиморфизм и динамическую диспетчеризацию методов.
     * Функции не наследуются и не подвержены полиморфизму.

 
 */
