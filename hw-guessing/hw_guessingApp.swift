//
//  hw_guessingApp.swift
//  hw-guessing
//
//  Created by falcon on 2021/3/5.
//

import SwiftUI

@main
struct hw_guessingApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(q: question(q: "問題", a: "答案"), qShow: "")
        }
    }
}
