//
//  Hypnos02App.swift
//  Hypnos02
//
//  Created by Euna Ahn on 2023/04/24.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct Hypnos02App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    init() {
        // Kakao SDK 초기화
        KakaoSDK.initSDK(appKey: "0dfdbdaf3c381b314ba4006745438cf2")
    }
}
