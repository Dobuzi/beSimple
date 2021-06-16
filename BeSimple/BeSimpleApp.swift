//
//  BeSimpleApp.swift
//  BeSimple
//
//  Created by 김종원 on 2021/06/14.
//

import SwiftUI
import Firebase

@main
struct BeSimpleApp: App {
    init() {
        FirebaseApp.configure()
        let db = Firestore.firestore()
        let storage = Storage.storage()
        print(db.description)
        print(storage.description)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
