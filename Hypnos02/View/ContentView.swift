//
//  ContentView.swift
//  Hypnos02
//
//  Created by Euna Ahn on 2023/04/24.
//

import SwiftUI
import Charts
import KakaoSDKNavi

struct ContentView: View {
    @State private var selectedTrack: Track?
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        Group {
            if viewModel.userSession != nil {
                TabView{
                    HomeView(selectedTrack: $selectedTrack).tabItem{
                        Label("Home",systemImage: "house")
                    }

                    NaviListView().tabItem {
                        Label("Navi", systemImage: "paperplane.circle.fill")
                        
                    }
                    
                    ProfileView().tabItem {
                        Label("MyProfile", systemImage: "person.fill")
                    }
                    
                }
            } else {
                LoginView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
