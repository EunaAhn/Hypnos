//
//  Hypnos02App.swift
//  Hypnos02
//
//  Created by Euna Ahn on 2023/04/24.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth
import Firebase

@main
struct Hypnos02App: App {
    @StateObject var viewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
    init() {
        FirebaseApp.configure()
        // Kakao SDK 초기화
        KakaoSDK.initSDK(appKey: "0dfdbdaf3c381b314ba4006745438cf2")
    }
}
