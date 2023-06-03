//
//  NaviListView.swift
//  Hypnos02
//
//  Created by Euna Ahn on 2023/05/13.
//

import SwiftUI
import Alamofire
import KakaoSDKNavi
import SwiftyJSON
import KakaoSDKCommon
import CoreLocation

struct NaviListView: View {
    @State private var keyword = ""
    @State private var resultList = [Place]()
    @ObservedObject private var locationManagerDelegate = LocationManagerDelegate()
    
    @State var currentTab: Int = 0
    @Namespace var namespace
    
    var body: some View {
        VStack {
            HStack{
                Button("졸음쉼터") {
                    keyword = " 졸음쉼터"
                    searchPlaces()
                }
                .font(.system(size: 17, weight: .heavy,design: .rounded))
                .padding(EdgeInsets(top: 13, leading: 15, bottom: 13, trailing: 15))
                .foregroundColor(.white)
                .background(.blue.opacity(0.7))
                .clipShape(Capsule())
                .padding(.top, 10)
                
                Button("휴게소") {
                    keyword = "가까운 휴게소"
                    searchPlaces()
                }
                .font(.system(size: 17, weight: .heavy,design: .rounded))
                .padding(EdgeInsets(top: 13, leading: 15, bottom: 13, trailing: 15))
                .foregroundColor(.white)
                .background(.pink.opacity(0.7))
                .clipShape(Capsule())
                .padding(.top, 10)
                
                Button("주차장") {
                    keyword = "가까운 주차장"
                    searchPlaces()
                }
                .font(.system(size: 17, weight: .heavy,design: .rounded))
                .padding(EdgeInsets(top: 13, leading: 15, bottom: 13, trailing: 15))
                .foregroundColor(.white)
                .background(.green.opacity(0.7))
                .clipShape(Capsule())
                .padding(.top, 10)
                
                Button("카페") {
                    keyword = "가까운 카페"
                    searchPlaces()
                }
                .font(.system(size: 17, weight: .heavy,design: .rounded))
                .padding(EdgeInsets(top: 13, leading: 15, bottom: 13, trailing: 15))
                .foregroundColor(.white)
                .background(.yellow.opacity(0.7))
                .clipShape(Capsule())
                .padding(.top, 10)
                
                Button("공원") {
                    keyword = "가까운 공원"
                    searchPlaces()
                }
                .font(.system(size: 17, weight: .heavy,design: .rounded))
                .padding(EdgeInsets(top: 13, leading: 15, bottom: 13, trailing: 15))
                .foregroundColor(.white)
                .background(.orange.opacity(0.7))
                .clipShape(Capsule())
                .padding(.top, 10)
                
            }
            
            List(resultList) { place in
                VStack(alignment: .leading) {
                    Text(place.placeName)
                        .font(.headline)
                    Text(place.roadAddressName)
                        .font(.subheadline)
                    Text("일직선 거리: \(place.distance)km")
                        .font(.subheadline)
                }
                .contentShape(Rectangle()) // 각 행을 버튼 역할로 만들기 위해 추가
                .onTapGesture { // 버튼 액션 추가
                    print("\(place.placeName) is tapped.")
                    let destination = NaviLocation(name: place.placeName, x: place.longitudeX, y: place.latitudeY)
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
            //.padding()
        }
    }
        
    func searchPlaces() {
        
        
        let headers: HTTPHeaders = [
            "Authorization": "KakaoAK 04b4b883df9438c24cf7feacf48912e0"
        ]
        
        let parameters: [String: Any] = [
            "query": keyword,
            "page": 1,
            "size": 15,
            "sort": "distance",
            "x": locationManagerDelegate.longitude,
            "y": locationManagerDelegate.latitude,
            "radius": 20000
        ]
        
        AF.request("https://dapi.kakao.com/v2/local/search/keyword.json",
                   method: .get,
                   parameters: parameters,
                   headers: headers)
            .validate()
            .responseDecodable(of: SearchResponse.self) { response in
                switch response.result {
                case .success(let result):
                    let documents = result.documents
                    //print(documents) // 추가: 원시 데이터 확인
                    
                    var places = [Place]()
                    let dispatchGroup = DispatchGroup()
                    
                    for document in documents {
                        let longitude = document.x
                        let latitude = document.y
                        let distance_0 = document.distance
                        let distance = (distance_0 as NSString).doubleValue / 1000
                        
                        dispatchGroup.enter()
                        
                        convertToKTM(latitude: latitude, longitude: longitude) { ktmX, ktmY in
                            let place = Place(placeName: document.placeName,
                                              roadAddressName: document.roadAddressName,
                                              longitudeX: String(ktmX),
                                              latitudeY: String(ktmY), distance: String(format: "%.2f", distance))
                            places.append(place)
                            dispatchGroup.leave()
                        }
                    }
                    
                    dispatchGroup.notify(queue: .main) {
                        self.resultList = places
                    }
                    
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    func convertToKTM(latitude: String, longitude: String, completion: @escaping (Double, Double) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "KakaoAK 04b4b883df9438c24cf7feacf48912e0"
        ]
        
        let parameters: [String: Any] = [
            "x": longitude,
            "y": latitude,
            "input_coord": "WGS84",
            "output_coord": "KTM"
        ]
        
        AF.request("https://dapi.kakao.com/v2/local/geo/transcoord.json",
                   method: .get,
                   parameters: parameters,
                   headers: headers)
            .validate()
            .responseDecodable(of: CoordinateResponse.self) { response in
                switch response.result {
                case .success(let result):
                    let ktmX = result.documents[0].x
                    let ktmY = result.documents[0].y
                    
                    completion(ktmX, ktmY)
                    
                case .failure(let error):
                    print(error)
                    completion(0.0, 0.0) // 변환 실패 시 기본값 반환
                }
            }
    }
}


class LocationManagerDelegate: NSObject, CLLocationManagerDelegate, ObservableObject {
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
        }
    }
}


struct NaviListView_Previews: PreviewProvider {
    static var previews: some View {
        NaviListView()
    }
}

struct CoordinateResponse: Decodable {
    let documents: [CoordinateDocument]
}

struct CoordinateDocument: Decodable {
    let x: Double
    let y: Double
}

struct Place: Identifiable {
    let id = UUID()
    let placeName: String
    let roadAddressName: String
    let longitudeX: String
    let latitudeY: String
    let distance: String
}

struct SearchResponse: Decodable {
    let documents: [Document]
}

struct Document: Decodable {
    let id = UUID()
    let placeName: String
    let roadAddressName: String
    let x: String
    let y: String
    let distance: String

    enum CodingKeys: String, CodingKey {
        case placeName = "place_name"
        case roadAddressName = "road_address_name"
        case x
        case y
        case distance
    }
}

