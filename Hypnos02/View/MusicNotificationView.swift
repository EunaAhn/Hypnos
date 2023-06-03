//
//  MusicNotificationView.swift
//  Hypnos02
//
//  Created by Euna Ahn on 2023/04/28.
//

import SwiftUI

struct MusicNotificationView: View {
    let title: String
    let artist: String
    
    init(title: String = "", artist: String = "") {
        self.title = title
        self.artist = artist
    }
    
    var body: some View {
        HStack {
            Image("music_image")
                .resizable()
                .frame(width: 80, height: 80)
                //.overlay(LinearGradient(gradient: Gradient(colors: [.blue]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(10)
                .foregroundColor(.white)
                .padding(.top, 15)
                .padding(.leading, 15)
                .padding(.bottom, 15)
                .padding(.trailing, 10)
            
            VStack(alignment: .leading, spacing: 4){ // Add spacing to the VStack
                Text(title)
                    //.font(.headline)
                    .font(.system(size: 17, weight: .heavy, design: .rounded))
                    //.foregroundColor(.primary)
                
                Text(artist)
                    //.font(.subheadline)
                    .font(.system(size: 15, weight: .light, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            Spacer() // Add a spacer to push the VStack to the right
        }
        .background(.gray.opacity(0.2))
        .cornerRadius(20)
        .padding(.vertical, 8)
        .padding(.trailing, 16)
        
    }
}

struct MusicNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        MusicNotificationView(title: "Sample Title", artist: "Sample Artist")
    }
}

