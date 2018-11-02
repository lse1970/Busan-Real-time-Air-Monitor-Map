//
//  ViewController.swift
//  BusanMap02
//
//  Created by 김종현 on 30/10/2018.
//  Copyright © 2018 김종현. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, XMLParserDelegate {

    @IBOutlet weak var myMapView: MKMapView!
    
    var annotation: BusanData?
    var annotations: Array = [BusanData]()
    
    var item:[String:String] = [:]  // item[key] => value
    var items:[[String:String]] = []
    var currentElement = ""
    
    var tPM10: String?
    var address: String?
    var lat: String?
    var long: String?
    var loc: String?
    var dLat: Double?
    var dLong: Double?
    var vPM10Cai: String?
    
    let addrs:[String:[String]] = [
        "태종대" : ["영도구 전망로 24", "35.0597260", "129.0798400", "태종대유원지관리사무소", "도시대기", "녹지지역"],
        "전포동" : ["부산진구 전포대로 175번길 22", "35.1530480", "129.0635640","경남공고 옥상", "도시대기",  "상업지역"],
        "광복동" : ["중구 광복로 55번길 10", "35.0999630", "129.0304170", "광복동 주민센터", "도시대기", "상업지역"],
        "장림동" : ["사하구 장림로 161번길 2", "35.0829920", "128.9668750", "사하여성회관", "도시대기","공업지역"],
        "학장동" : ["사상구 대동로 205", "35.1460850", "128.9838270", "학장초등학교", "도시대기","공업지역"],
        "덕천동" : ["북구 만덕대로 155번길 81", "35.2158660", "129.0197570", "한국환경공단", "도시대기", "주거지역"],
        "연산동" : ["연제구 중앙대로 1065번길 14", "35.1841140", "129.0786090", "연제초등학교", "도시대기", "주거지역"],
        "대연동" : ["남구수영로 196번길 80", "35.1303210", "129.0876850", "부산공업고등학교", "도시대기", "주거지역"],
        "청룡동" : ["금정구 청룡로 25", "35.2752570", "129.0898810","청룡노포동 주민센터 옥상", "도시대기", "주거지역"],
        "기장읍" : ["기장군 기장읍 읍내로 69", "35.2460560", "129.2118280","기장초등학교 옥상", "도시대기", "주거지역"],
        "대저동" : ["강서구 낙동북로 236", "35.2114600", "128.9547110","대저차량사업소 옥상", "도시대기", "녹지지역"],
        "부곡동" : ["금정구 부곡로 156번길 7", "35.2298390", "129.0927140","부곡2동 주민센터 옥상", "도시대기", "주거지역"],
        "광안동" : ["수영구 수영로 521번길 55", "35.1527040", "129.1078090","구 보건환경연구원 3층", "도시대기", "주거지역"],
        "명장동" : ["동래구 명장로 32", "35.2047550", "129.1043270","명장동 주민센터 옥상", "도시대기", "주거지역"],
        "녹산동" : ["강서구 녹산산업중로 333", "35.0953270", "128.8556680", "(주)삼성전기부산사업장 옥상", "도시대기",  "공업지역"],
        "용수리" : ["기장군 정관면 용수로4", "35.3255580", "129.1801400", "정관면 주민센터 2층 옥상", "도시대기", "주거지역"],
        "좌동"  : ["해운대구 양운로 91", "35.1708900", "129.1742250", "좌1동 주민센터 옥상", "도시대기", "주거지역"],
        "수정동" : ["동구 구청로 1", "35.1293350", "129.0454230", "동구청사 옥상", "도시대기", "주거지역"],
        "대신동" : ["서구 대신로 150", "35.1173230", "129.0156410", "부산국민체육센터", "도시대기", "주거지역"],
        "온천동" : ["동래구 중앙대로 동래역", "35.2056140", "129.0785020", "동래지하철 앞", "도로변", "상업지역"],
        "초량동" : ["동구 초량동 윤흥신장군 동상앞", "35.11194650", "129.0354560", "윤흥신장군 동상 앞", "도로변", "상업지역"]
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "부산 미세먼지 지도"
        // Do any additional setup after loading the view, typically from a nib.
        // XML Parsing
        let key = "aT2qqrDmCzPVVXR6EFs6I50LZTIvvDrlvDKekAv9ltv9dbO%2F8i8JBz2wsrkpr9yrPEODkcXYzAqAEX1m%2Fl4nHQ%3D%3D"
        let strURL = "http://opendata.busan.go.kr/openapi/service/AirQualityInfoService/getAirQualityInfoClassifiedByStation?ServiceKey=\(key)&numOfRows=21"
        
        if let url = URL(string: strURL) {
            if let parser = XMLParser(contentsOf: url) {
                parser.delegate = self
                
                if (parser.parse()) {
                    print("parsing success")
                    
                    for item in items {
                        print("item pm10 = \(item["pm10"]!)")
                    }
                    
                } else {
                    print("parsing fail")
                }
            } else {
                print("url error")
            }
        }
        
        // Map
        myMapView.delegate = self
        let location = CLLocationCoordinate2D(latitude: 35.180100, longitude: 129.081017)
        let span = MKCoordinateSpan(latitudeDelta: 0.27, longitudeDelta: 0.27)
        let region = MKCoordinateRegion(center: location, span: span)
        myMapView.setRegion(region, animated: true)
        
        for item in items {
            let dSite = item["site"]
            print("dSite = \(dSite)")
            
            // 추가 데이터 처리
            for (key, value) in addrs {
                if key == dSite {
                    address = value[0]
                    lat = value[1]
                    long = value[2]
                    loc = value[3]
                    dLat = Double(lat!)
                    dLong = Double(long!)
                }
            }
            
            // 파싱 데이터 처리
            let dPM10 = item["pm10"]
            let dPM10Cai = item["pm10Cai"]
            
            print("dMP10 = \(String(describing: dPM10))")
            print("dPM10Cai = \(String(describing: dPM10Cai))")
            
            if dPM10Cai == "1" {
                vPM10Cai = "좋음"
            } else if dPM10Cai == "2" {
                vPM10Cai = "보통"
            } else if dPM10Cai == "3" {
                vPM10Cai = "나쁨"
            } else if dPM10Cai == "4" {
                vPM10Cai = "아주나쁨"
            } else {
                vPM10Cai = "오류"
            }
            
            let subtitleOut =  "PM10 " + vPM10Cai! + " " + dPM10! + " ug/m3 "
            
            annotation = BusanData(coordinate: CLLocationCoordinate2D(latitude: dLat!, longitude: dLong!), title: dSite!, subtitle: subtitleOut, pm10: dPM10!, pm10Cai: dPM10Cai!)
            
            annotations.append(annotation!)
            //myMapView.showAnnotations(annotations, animated: true)
            myMapView.addAnnotations(annotations)
  
        }
        
//        for addr in addrs {
//            let stationVal = addr.value
//            let stationName = addr.key
////            print(stationName)
//
//            let address = stationVal[0]
//            let lat = stationVal[1]
//            let long = stationVal[2]
//            let loc = stationVal[3]
//
//            let dLat = Double(lat)
//            let dLong = Double(long)
//
//            tPM10 = "pm10 " + items[i]["pm10"]! + " ug/m2"
//            //print(items[i]["pm10"])
//
//            i = i + 1
//            annotation = BusanData(coordinate: CLLocationCoordinate2D(latitude: dLat!, longitude: dLong!), title: stationName, subtitle: tPM10!)
//
//            annotations.append(annotation!)
//            myMapView.addAnnotations(annotations)
//        }
        
        // Position the map such that the provided array of annotations are all visible to the fullest extent possible.
//        myMapView.showAnnotations(annotations, animated: true)
//        print(annotations.count)
//        myMapView.addAnnotations(annotations)
       
        
        
//        let a = BusanData(coordinate: CLLocationCoordinate2D(latitude:35.0999630, longitude: 35.0999630), title: "광복동", subtitle: "광복동 주민센터")
//        let b = BusanData(coordinate: CLLocationCoordinate2D(latitude: 35.0829920, longitude: 128.9668750), title: "장림동", subtitle: "사하여성회관")
//        let c = BusanData(coordinate: CLLocationCoordinate2D(latitude: 35.1460850, longitude: 128.9838270), title: "학장동", subtitle: "학장초등학교")
//        let d = BusanData(coordinate: CLLocationCoordinate2D(latitude: 35.2158660, longitude: 129.0197570), title: "덕천동", subtitle: "한국환경공단")
//        let e = BusanData(coordinate: CLLocationCoordinate2D(latitude: 35.1841140, longitude: 129.0786090), title: " 연산동", subtitle: "연제초등학교")
//        let f = BusanData(coordinate: CLLocationCoordinate2D(latitude: 35.1303210, longitude: 129.0876850), title: "대연동", subtitle: "부산공업고등학교")
//        let g = BusanData(coordinate: CLLocationCoordinate2D(latitude: 35.2752570, longitude: 129.0898810), title: "청룡동", subtitle: "청룡노포동 주민센터 옥상")
//        let h = BusanData(coordinate: CLLocationCoordinate2D(latitude: 35.1530480, longitude: 129.0635640), title: "전포동", subtitle: "경남공고 옥상")
//        let i = BusanData(coordinate: CLLocationCoordinate2D(latitude: 35.0597260, longitude: 129.0798400), title: "태종대", subtitle: "태종대유원지관리사무소")
//        let j = BusanData(coordinate: CLLocationCoordinate2D(latitude: 35.2460560, longitude: 129.2118280), title: "기장읍", subtitle: "기장초등학교 옥상")
//        let k = BusanData(coordinate: CLLocationCoordinate2D(latitude: 35.2114600, longitude: 128.9547110), title: "대저동", subtitle: "대저차량사업소 옥상")
//        let l = BusanData(coordinate: CLLocationCoordinate2D(latitude: 35.2298390, longitude:  129.0927140), title: "부곡동", subtitle: "부곡2동 주민센터 옥상")
//        let m = BusanData(coordinate: CLLocationCoordinate2D(latitude: 35.1527040, longitude:  129.1078090), title: "광안동", subtitle: "구 보건환경연구원 3층")
//        let n = BusanData(coordinate: CLLocationCoordinate2D(latitude: 35.2047550, longitude:  129.1043270), title: "명장동", subtitle: "명장동 주민센터 옥상")
//        let o = BusanData(coordinate: CLLocationCoordinate2D(latitude: 35.0953270, longitude:  128.8556680), title: "녹산동", subtitle: "(주)삼성전기부산사업장 옥상")
//        let p = BusanData(coordinate: CLLocationCoordinate2D(latitude: 35.3255580, longitude:  129.1801400), title: "용수리", subtitle: "정관면 주민센터 2층 옥상")
//        let q = BusanData(coordinate: CLLocationCoordinate2D(latitude: 35.1708900, longitude:  129.1742250), title: "좌동", subtitle: "좌1동 주민센터 옥상")
//        let r = BusanData(coordinate: CLLocationCoordinate2D(latitude: 35.1293350, longitude:  129.0454230), title: "수정동", subtitle: "동구청사 옥상")
//        let s = BusanData(coordinate: CLLocationCoordinate2D(latitude: 35.1173230, longitude:  129.0156410), title: "대신동", subtitle: "부산국민체육센터")
//        let t = BusanData(coordinate: CLLocationCoordinate2D(latitude: 35.2056140, longitude:  129.0785020), title: "온천동", subtitle: "동래지하철 앞")
//        let u = BusanData(coordinate: CLLocationCoordinate2D(latitude: 35.11194650, longitude:  129.0354560), title: "초량동", subtitle: "윤흥신장군 동상 앞")
//
//        myMapView.addAnnotations([a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u])
        //myMapView.delegate = self
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "MyPin"
        
//        if annotation.isKind(of: MKUserLocation.self) {
//            return nil
//        }
        
        if annotation.isKind(of: BusanData.self) {
            var annotationView = myMapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
            
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                
                // 미세먼지 농도에 따라 pin의 색깔을 바꿈
                let castBusanData = annotation as! BusanData
                let pm10Val = castBusanData.pm10Cai
                switch pm10Val {
                case "4": annotationView?.pinTintColor = UIColor.red // 매우나쁨
                case "3": annotationView?.pinTintColor = UIColor.brown // 나쁨
                case "2": annotationView?.pinTintColor = UIColor.blue // 보통
                case "1" : annotationView?.pinTintColor = UIColor.green // 좋음
                default: annotationView?.pinTintColor = UIColor.black // 오류
                }
                
            } else {
                annotationView?.annotation = annotation
            }
            
            let btn = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = btn
            
            return annotationView
        }
        return nil
    }
    
    // XML Parsing Delegate 메소드
    // XMLParseDelegate
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        currentElement = elementName
        
        // tag 이름이 elements이거나 item이면 초기화
        if elementName == "items" {
            items = []
        } else if elementName == "item" {
            item = [:]
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        //        print("data = \(data)")
        if !data.isEmpty {
            item[currentElement] = data
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            items.append(item)
        }
    }
}

