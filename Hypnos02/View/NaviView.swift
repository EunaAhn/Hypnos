//
//  NaviView.swift
//  Hypnos02
//
//  Created by Euna Ahn on 2023/04/26.
//

import SwiftUI
import KakaoSDKNavi
import Combine

struct Address: Identifiable {
    let id = UUID()
    let name: String
    let street: String
    let city: String
    let state: String
    let zip: String
}

class AddressStore: ObservableObject {
    @Published var addresses: [Address] = []
    
    init() {
        self.addresses = [
            Address(name: "김포 졸음쉼터", street: "경기도 김포시 고촌읍 신곡리 757-1", city: "김포", state: "서울외곽선", zip: "고속국도"),
            Address(name: "Jane Doe", street: "456 Elm St", city: "Somewhere", state: "NY", zip: "67890"),
            Address(name: "Bob Johnson", street: "789 Maple St", city: "Nowhere", state: "IL", zip: "54321")
        ]
    }
    
    func searchAddresses(query: String) -> [Address] {
        if query.isEmpty {
            return self.addresses
        } else {
            return self.addresses.filter { $0.name.contains(query) }
        }
    }
}

struct NaviView: View {
    @ObservedObject var store = AddressStore()
    @State var query: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("졸음쉼터 검색하기", text: $query)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal, 15)
                    .padding(.top, 10)
                        
                List(store.searchAddresses(query: query)) { address in
                    VStack(alignment: .leading) {
                        Text(address.name)
                            .font(.headline)
                        Text("\(address.street)\n\(address.city), \(address.state) \(address.zip)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .contentShape(Rectangle()) // 각 행을 버튼 역할로 만들기 위해 추가
                    .onTapGesture { // 버튼 액션 추가
                        print("\(address.name) is tapped.")
                        let destination = NaviLocation(name: "카카오", x: "321430.7697913759", y: "532999.1181562026")
                        guard let shareUrl = NaviApi.shared.shareUrl(destination: destination) else {
                            return
                        }
                                        
                        if UIApplication.shared.canOpenURL(shareUrl) {
                            UIApplication.shared.open(shareUrl, options: [:], completionHandler: nil)
                        }
                        else {
                            UIApplication.shared.open(NaviApi.webNaviInstallUrl, options: [:], completionHandler: nil)
                        }
                    }
                }
            }
            .navigationBarTitle("졸음쉼터 안내")
        }
    }
}


struct Previews_NaviView: PreviewProvider {
    static var previews: some View {
        NaviView()
    }
}
