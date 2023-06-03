//
//  MusicSelectionView.swift
//  Hypnos02
//
//  Created by Euna Ahn on 2023/04/28.
//

import SwiftUI

struct Track: Identifiable, Equatable, Hashable {
    let id = UUID()
    let title: String
    let artist: String


    
    let thumbnail = Image("music_image")
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Album {
    let tracks = [
        Track(title: "가벼운 결말", artist: "알림음악1"),
        Track(title: "기상나팔소리", artist: "알림음악2"),
        Track(title: "딩동댕동", artist: "알림음악3"),
        Track(title: "마리오", artist: "알림음악4"),
        Track(title: "오케스트라 연주", artist: "알림음악5"),
        Track(title: "탁상알람소리", artist: "알림음악6"),
        Track(title: "팡파르 나팔소리", artist: "알림음악7")
    ]
}

struct MusicSelectionView: View {
    let data = Album()
    @State private var favoriteTracks: Set<Track> = []
    @Binding var selectedTrack: Track?
    
    var body: some View {
        List {
            ForEach(data.tracks) { track in
                TrackRow(track: track, isFavorite: Binding<Bool>(
                    get: { favoriteTracks.contains(track) }, // favoriteTracks.contains(track)로 수정
                    set: { isFavorite in
                        if isFavorite {
                            favoriteTracks.insert(track)
                            selectedTrack = track
                        } else {
                            favoriteTracks.remove(track)
                        }
                        if isFavorite {
                            selectedTrack = track // 토글이 변경되었을 때 selectedTrack 업데이트
                        } else if selectedTrack == track {
                            selectedTrack = nil
                        }
                    }
                ), selectedTrack: $selectedTrack) // selectedTrack 전달
            }
        }
    }
}

struct TrackRow: View {
    let track: Track
    @Binding var isFavorite: Bool
    @Binding var selectedTrack: Track?

    var body: some View {
        HStack {
            track.thumbnail
                .resizable()
                .frame(width: 50, height: 50)
                .cornerRadius(6)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(track.title)
                    .font(.headline)
                Text(track.artist)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            
            Spacer()
            Toggle(isOn: $isFavorite) {
                EmptyView()
            }
            .toggleStyle(SwitchToggleStyle(tint: .blue))
            .onChange(of: isFavorite) { newValue in
                if newValue {
                    selectedTrack = track // 토글이 변경되었을 때 selectedTrack 업데이트
                    playSound(key: track.title)
                    
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.trailing, 16)
    }
    
}



struct MusicSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        MusicSelectionView(selectedTrack: .constant(nil))
    }
}
