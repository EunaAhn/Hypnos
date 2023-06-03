//
//  HomeView.swift
//  Hypnos02
//
//  Created by Euna Ahn on 2023/04/26.
//

import SwiftUI
import Charts
import Alamofire
import Combine
import KakaoSDKNavi
import SwiftyJSON
import KakaoSDKCommon
import CoreLocation


struct HomeView: View {
    @State private var isShowingMusicSelection = false
    @Binding var selectedTrack: Track?
    @State private var viewMonths: [ViewMonth] = []
    
    @State private var isDeviceConnected = false
    @State private var isPlayingMusic = false
    
    @State var customAlert = false
    @State var HUD = false
    
    @State private var keyword = ""
    @State private var resultList = [Place]()
    @ObservedObject private var locationManagerDelegate = LocationManagerDelegate()
    
    let curGradient = LinearGradient(
        gradient: Gradient (
            colors: [
                Color(.blue).opacity(0.1),
                Color(.blue).opacity(0.0)
            ]
        ),
        startPoint: .top,
        endPoint: .bottom
    )
    
    let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack{
            ZStack{
                VStack {
                    RadialGradient(colors: [.white.opacity(0.3), .blue.opacity(0.7)],
                                   center: .bottomTrailing,
                                   startRadius: 0, endRadius: 300)
                        .ignoresSafeArea(edges: .top)
                        .frame(height: 0)
                    
                    Spacer()
                }
                Spacer()
                VStack {
                    HStack { // Add a HStack to contain the "Fetch Data" button and the text views
                        VStack {
                            Text("졸음횟수")
                                .padding(.top, -75.0)
                            Text("Total: \(viewMonths.reduce(0, { $0 + $1.viewCount }))")
                                .fontWeight(.semibold)
                                .font(.footnote)
                                .padding(.vertical, -65.0)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            fetchData()
                        }) {
                            HStack {
                                Image(systemName: "goforward")
                                Text("Update")
                            }
                            //Text("Update")
                        }
                        .font(.system(size: 17, weight: .heavy,design: .rounded))
                        .padding(EdgeInsets(top: 7, leading: 15, bottom: 7, trailing: 15))
                        .foregroundColor(.white)
                        .background(.blue.opacity(0.7))
                        .clipShape(Capsule())
                        .padding(.top, -85.0)
                        
                    }
                    
                    
                    Chart {
                        ForEach(viewMonths){ viewMonth in
                            
                            LineMark(
                                x: .value("Month", viewMonth.date, unit: .day),
                                y: .value("Views", viewMonth.viewCount)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(Color.blue.gradient.opacity(0.7))
                            .cornerRadius(10)
                            .symbol {
                                Circle()
                                    .fill(.white)
                                    .frame(width: 10)
                                    .shadow(radius: 2)
                                
                            }
                            
                            AreaMark(
                                x: .value("Month", viewMonth.date, unit: .day),
                                y: .value("Views", viewMonth.viewCount)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(curGradient)
                            
                        }
                    }
                    .padding(.top, -50.0)
                    .frame(height: 150.0)
                    
                    Divider().padding(5)
                    
                    HStack {
                        Text("알림음악 설정")
                            .padding(3)
                            //.foregroundColor(.blue.opacity(0.7))
                        Spacer() // 왼쪽에 뷰를 배치하기 위해 오른쪽으로 공간을 차지하는 Spacer 추가
                    }
                        
                    
                    if let track = selectedTrack { // 선택된 트랙이 있을 때만 MusicNotificationView 표시
                        MusicNotificationView(title: track.title, artist: track.artist)
                            .onTapGesture {
                                isShowingMusicSelection = true // 선택된 트랙 설정
                            }
                            .sheet(isPresented: $isShowingMusicSelection) {
                                MusicSelectionView(selectedTrack: $selectedTrack) // 선택된 트랙을 MusicSelectionView에 전달
                            }
                    } else {
                        MusicNotificationView(title: "탁상알림소리", artist: "알림음악6")
                            .onTapGesture {
                                isShowingMusicSelection = true // 선택된 트랙 설정
                            }
                            .sheet(isPresented: $isShowingMusicSelection) {
                                MusicSelectionView(selectedTrack: $selectedTrack) // 선택된 트랙을 MusicSelectionView에 전달
                            }
                    }
                    
                    Divider().padding(5)
                    
                    HStack {
                        Text("Muse Device Connect")
                            .padding(3)
                            .foregroundColor(.blue.opacity(0.7))
                        Spacer() // 왼쪽에 뷰를 배치하기 위해 오른쪽으로 공간을 차지하는 Spacer 추가
                    }
                    
                    Button(action: {
                        isDeviceConnected.toggle()
                    }) {
                        Text("Device Connect: \(isDeviceConnected ? "On" : "Off")")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
                    .foregroundColor(.white)
                    .background(.blue.opacity(0.7))
                    .cornerRadius(20)
                    .padding(.vertical, 8)
                    .padding(.trailing, 16)
                    

                    .onReceive(timer) { _ in
                        if isDeviceConnected {
                            fetchDeviceStatus()
                        }
                    }
                }
                .padding()
                .navigationTitle("Hypnos")
                .navigationBarColor(backgroundColor: .clear, titleColor: .white)
                .font(.system(size: 17, weight: .heavy,design: .rounded))
                .onAppear {
                    fetchData() // Call fetchData() when the view appears
                }
            }
        }
    }
    
    // 날짜를 파싱하는 메서드
    func parseDate(_ dateString: String) -> Date? {
        let tmpDateStringT = dateString.replacingOccurrences(of: "T", with: " ")
        let tmpDateStringZ = tmpDateStringT.replacingOccurrences(of: ".000Z", with: "")
        return tmpDateStringZ.toDate()
    }
    
    func fetchData() {
        // JSON 데이터 가져오기
        let url = "http://www.digipine.com:1502/getsleepycount" // JSON 데이터가 있는 URL을 입력하세요
        let parameters: Parameters = [
            "userID": "euna001",
            "month": "05",
            "year": "2023"
        ]
        
        AF.request(url,
                   method: .post, // HTTP메서드 설정
                   parameters: parameters, // 파라미터 설정
                   encoding: JSONEncoding.default, // 인코딩 타입 설정
                   headers: ["Content-Type":"application/json", "Accept":"*/*"]) // 헤더 설정
        .validate(statusCode: 200..<300) // 유효성 검사
        .responseDecodable(of: ResponseData.self) { response in
            switch response.result {
            case .success(_):
                if let rawData = response.data, let rawDataString = String(data: rawData, encoding: .utf8) {
                    print("원시 데이터:")
                    print(rawDataString)
                }
                    
                
                if let responseData = try? JSONDecoder().decode(ResponseData.self, from: response.data!) {
                    let msg = responseData.error.msg
//                    for list in msg {
//                        print("data=\(list.date.debugDescription)")
//                        print("sleepycnt=\(list.sleepycnt.debugDescription)")
//                    }
                    
                    
                    // JSON 파싱하여 viewMonths 배열에 데이터 추가
                    var months: [ViewMonth] = []
                    for item in msg {
                        if let dateString = item.date,
                           let sleepCount = item.sleepycnt {
                            print("data_org=\(dateString)")
 
                            if let date = parseDate(dateString) {
                                let month = ViewMonth(date: date, viewCount: sleepCount)
                                months.append(month)
                            }
                        }
                    }
                    viewMonths = months
                    
                    // JSON 파싱 결과를 확인하기 위해 콘솔에 출력
                    print("파싱된 JSON:")
                    for month in viewMonths {
                        print("날짜: \(month.date), 졸음 횟수: \(month.viewCount)")
                    }
                    
                } else {
                    print("JSON 디코딩에 실패했습니다.")
                }
                
            case .failure(let error):
                print("에러: \(error)")
            }
        }
        
    }
    
    // Fetch device status from JSON API
    func fetchDeviceStatus() {
        let url = "http://www.digipine.com:1502/getsleepystatus"
        let parameters: Parameters = [
            "userID": "euna001"
        ]
        
        AF.request(url,
                    method: .post,
                    parameters: parameters,
                    encoding: JSONEncoding.default,
                    headers: ["Content-Type":"application/json", "Accept":"*/*"])
            .validate(statusCode: 200..<300)
            .responseDecodable(of: DeviceStatusResponse.self) { response in
                switch response.result {
                case .success(_):
                    //if let rawData = response.data, let rawDataString = String(data: rawData, encoding: .utf8) {
                   //     print("원시 데이터:")
                   //     print(rawDataString)
                   // }
                    
                    if let responseData = try? JSONDecoder().decode(DeviceStatusResponse.self, from: response.data!) {
                        let msg = responseData.error.msg
                        
                        for item in msg {
                            if let sleepy = item.sleepy {
                                if let sleepyStatus = item.sleepy {
                                    print("sleepyStatus:\(sleepyStatus)")
                                    //isPlayingMusic = (sleepyStatus == 1)
                                    //playSound(key: )
                                    if let track = selectedTrack {
                                        let key = track.title
                                        playSound(key: key)
                                    }
                                    
                                    alertView()
                                }
                            }
                        }
                    }
                    
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
    }
    
    func alertView(){
        
        let alert = UIAlertController(title: "졸음감지", message: "가까운 졸음쉼터로 안내하길 원하십니까?", preferredStyle: .alert)
        
        let navi = UIAlertAction(title: "start", style: .default) { (_) in
            keyword = "졸음쉼터"
            searchPlaces { places in
                if let firstPlace = places.first {
                    let destination = NaviLocation(name: firstPlace.placeName, x: firstPlace.longitudeX, y: firstPlace.latitudeY)
                    guard let shareUrl = NaviApi.shared.shareUrl(destination: destination) else {
                        return
                    }
                    
                    if UIApplication.shared.canOpenURL(shareUrl) {
                        UIApplication.shared.open(shareUrl, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.open(NaviApi.webNaviInstallUrl, options: [:], completionHandler: nil)
                    }
                }
            }
        }
        
        let cancel = UIAlertAction(title: "cancel", style: .destructive) { (_) in
            
        }
        
        alert.addAction(cancel)
        alert.addAction(navi)
        
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: {
            
        })
    }
    func searchPlaces(completion: @escaping ([Place]) -> Void) {
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
                    
                    var places = [Place]()
                    let dispatchGroup = DispatchGroup()
                    
                    for document in documents {
                        let longitude = document.x
                        let latitude = document.y
                        
                        dispatchGroup.enter()
                        
                        convertToKTM(latitude: latitude, longitude: longitude) { ktmX, ktmY in
                            let place = Place(placeName: document.placeName,
                                              roadAddressName: document.roadAddressName,
                                              longitudeX: String(ktmX),
                                              latitudeY: String(ktmY))
                            places.append(place)
                            dispatchGroup.leave()
                        }
                    }
                    
                    dispatchGroup.notify(queue: .main) {
                        completion(places)
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

        enum CodingKeys: String, CodingKey {
            case placeName = "place_name"
            case roadAddressName = "road_address_name"
            case x
            case y
        }
    }


    
    struct DeviceStatusResponse: Decodable {
        let error: ErrorData
    }
    
    struct ResponseData: Decodable {
        let error: ErrorData
    }
    
    struct ErrorData: Decodable {
        let code: Int
        let msg: [MessageData] // 형식을 [MessageData]로 변경
    }
    
    struct MessageData: Decodable {
        let date: String?
        let sleepycnt: Int?
        let sleepy: Int?
    }
    
    
    struct ViewMonth: Identifiable {
        let id = UUID()
        let date: Date
        let viewCount: Int
    }
    
    
    struct HomeView_Previews: PreviewProvider {
        static var previews: some View {
            HomeView(selectedTrack: .constant(nil))
        }
    }
}

struct NavigationBarModifier: ViewModifier {

    var backgroundColor: UIColor?
    var titleColor: UIColor?

    init(backgroundColor: UIColor?, titleColor: UIColor?) {
        self.backgroundColor = backgroundColor
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithTransparentBackground()
        coloredAppearance.backgroundColor = backgroundColor
        coloredAppearance.titleTextAttributes = [.foregroundColor: titleColor ?? .white]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: titleColor ?? .white]

        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
    }

    func body(content: Content) -> some View {
        ZStack{
            content
            VStack {
                GeometryReader { geometry in
                    Color(self.backgroundColor ?? .clear)
                        .frame(height: geometry.safeAreaInsets.top)
                        .edgesIgnoringSafeArea(.top)
                    Spacer()
                }
            }
        }
    }
}

extension View {

    func navigationBarColor(backgroundColor: UIColor?, titleColor: UIColor?) -> some View {
        self.modifier(NavigationBarModifier(backgroundColor: backgroundColor, titleColor: titleColor))
    }

}

extension String {
    func toDate() -> Date? { //"yyyy-MM-dd HH:mm:ss"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        if let date = dateFormatter.date(from: self) {
            return date
        } else {
            return nil
        }
    }
}

extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter.string(from: self)
    }
}
