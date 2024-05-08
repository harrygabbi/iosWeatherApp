//
//  ContentView.swift
//  weatherApp
//
//  Created by Harry Gabbi on 26/04/24.
//
import CoreLocation
import SwiftUI
import AVFoundation
import AVKit

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var viewModel = WeatherDataFetcher()
    @StateObject private var hourlyweatherReport = HourlyWeather()
    @StateObject private var  windManager = WindManager()
    
    var body: some View {
        let currentHour = getCurrentHour()
        ZStack {
            if let currentWeather = viewModel.currentTemperature {
                BackgroundView(isNight: currentWeather.current.isDay)
            }
            
            
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    if let location = locationManager.location {
                        VStack {
                            if let cityName = locationManager.cityName {
                                Text("Current location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                            } else {
                                Text("Current location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                                Text("Determining city name...")
                            }
                        }
                    } else {
                        Text("Fetching location...")
                    }
                    
                    
                    VStack {
                        if let cityName = locationManager.cityName {
                            CityTextView(cityName: cityName)
                        }
                        else{
                            Text("Surrey, BC");
                        }
                        if let currentWeather = viewModel.currentTemperature {
                            MainWeatherStatus(
                                imageName: "cloud.sun.fill",
                                temperature: "\(Int(currentWeather.current.temperature2m.rounded()))°",
                                high: "\(Int(currentWeather.daily.temperature2mMax[0]))",  // Added closing parenthesis for the high value
                                low: "\(Int(currentWeather.daily.temperature2mMin[0]))"   // Added closing parenthesis for the low value
                            )
                        } else {
                            Image("Image1")
                                .renderingMode(.original)
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                                .edgesIgnoringSafeArea(.all)
                                .offset(y: -140)
                            
                            
                        }
                        
                    }
                    .onAppear {
                        Task {
                            await viewModel.fetchCurrentWeather(latitude: locationManager.location?.coordinate.latitude ?? 0, longitude: locationManager.location?.coordinate.longitude ?? 0)
                            await hourlyweatherReport.fetchCurrentWeather(latitude: locationManager.location?.coordinate.latitude ?? 0, longitude: locationManager.location?.coordinate.longitude ?? 0)
                            
                            await windManager.fetchWindData(latitude: locationManager.location?.coordinate.latitude ?? 0, longitude: locationManager.location?.coordinate.longitude ?? 0)
                            
                        }
                    }
                    HStack{
                        VStack{
                            HStack{
                                Image(systemName: "clock")
                                    .foregroundColor(.white)
                                    .padding(.leading, 10)
                                    .opacity(0.6)
                                Text("HOURLY FORECAST")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding([.leading, .trailing], 0)
                                    .opacity(0.6)
                                Spacer()
                            }
                            .padding(.top)
                            Divider()
                                .frame(height: 1)
                                .background(Color.white.opacity(0.4))
                                .padding(.horizontal)
                            
                            
                            ScrollView(.horizontal, showsIndicators: false){
                                HStack{
                                    if let hourlyReport = hourlyweatherReport.currentTemperature{
                                        
                                        if let c = viewModel.currentTemperature{
                                            DayWeather(dayOfWeek: "NOW", weatherLogo:"cloud.sun.fill", temp: Int(c.current.temperature2m.rounded()))
                                            ForEach((currentHour+1)...23, id: \.self) { index in
                                                HourWeather(index: index, weatherLogo: weatherSymbol(for: hourlyReport.hourly.weatherCode[index], index: index), temp: Int(hourlyReport.hourly.temperature2m[index]))
                                                                                        }
                                                                                        ForEach(0...23, id: \.self) { index in
                                                                                            HourWeather(index: index, weatherLogo: weatherSymbol(for: hourlyReport.hourly.weatherCode[index+24], index: index+24), temp: Int(hourlyReport.hourly.temperature2m[index+24]))
                                                                                        
                                                                                            
                                                                                        }
                                        }
                            
                                        else{}

                                    }
                                    
                                    
                                }
                                .padding(8)
                            }
                            
                            
                        }
                        .frame(width: UIScreen.main.bounds.width*0.9 , height: UIScreen.main.bounds.height*0.23)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                        
                    }
                    
                    VStack(spacing: 10){
                        HStack(spacing: 10) {
                            if let currentWeather = viewModel.currentTemperature {
                                WeatherInfoBlock(iconName: "sun.max.fill", title: "UV Index",
                                                 width: UIScreen.main.bounds.width * 0.44, height: UIScreen.main.bounds.height*0.23, content: "\(currentWeather.daily.uvIndexMax[0])")
                                
                                WeatherInfoBlock(iconName: "thermometer.medium", title: "FEELS LIKE",
                                                 width: UIScreen.main.bounds.width * 0.44, height: UIScreen.main.bounds.height*0.23, content: "\(currentWeather.current.apparentTemperature.rounded())")
                            }
                        }
                        
                        VStack {
                            HStack(alignment: .top) {
                                Image(systemName: "wind")
                                    .foregroundColor(.white)
                                    .padding(.leading, 10)
                                    .padding(.top, 10)
                                
                                Text("WIND")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding([.leading, .trailing], 0)
                                    .padding(.top, 10)
                                
                                Spacer()
                            }
                            Divider()
                                .frame(height: 1)
                                .background(Color.white.opacity(0.4))
                                .padding(.horizontal)
                            Spacer()
                            HStack(spacing:10){
                                VStack{
                                    if let windData = windManager.windData {
                                        VStack(alignment: .leading) {
                                            HStack(spacing:20){
                                                Text("\(windData.current.windSpeed10m, specifier: "%.2f")")
                                                    .foregroundColor(.white)
                                                    .padding(.top, 10)
                                                    .font(.system(size: 30).bold())
                                                VStack{
                                                    Text("KM/H")
                                                        .foregroundColor(.white)
                                                        .font(.system(size: 12))
                                                    Text("Speed")
                                                        .foregroundColor(.white)
                                                        .font(.system(size: 12).bold())
                                                }
                                            }
                                            HStack(spacing:10){
                                                Text("\(windData.current.windGusts10m, specifier: "%.2f")")
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 30).bold())
                                                
                                                VStack{
                                                    Text("KM/H")
                                                        .foregroundColor(.white)
                                                        .font(.system(size: 12).bold())
                                                    Text("Gust")
                                                        .foregroundColor(.white)
                                                        .font(.system(size: 12).bold())
                                                }
                                                
                                            }
                                        }
                                      
                                    } else {
                                        Text("Fetching wind data...")
                                            .foregroundColor(.white)
                                    }
                                    Spacer()
                                    
                                }
                                
                                .padding(20)
                                
                                VStack(spacing:10){
                                    if let windData = windManager.windData {
                                        Image(systemName: "safari")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 100, height: 100)
                                            .foregroundColor(.white)
                                            .opacity(0.4)
                                        // Rotate the arrow based on the wind direction
                                            .rotationEffect(.degrees(-Double(windData.current.windDirection10m)))  // Negative for correct rotation
                                            .animation(.easeInOut, value: windData.current.windDirection10m)
                                        Text(" \(windData.current.windDirection10m, specifier: "%.0f")°")
                                            .foregroundColor(.white)
                                            .font(.system(size: 15))
                                        Spacer()
                                            
                                    }
                                }
                            }
                           
                        }
                        .frame(width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.height*0.23)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                        
                        
                        //                VStack{
                        //
                        //                    Button {
                        //                        print(" s")
                        ////                        isNight.toggle()
                        //                    } label: {
                        //                        WeatherButton(title: "Change Day Time", textColor: Color.indigo, backgroundColor: .white)
                        //                    }
                        Spacer()
                    }
                }
                
            }
        }
        
    }
}

#Preview {
    ContentView()
}

func formatDate(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(identifier: "America/Vancouver")  // Set to Pacific Time
    dateFormatter.dateFormat = "HH:mm"  // 24-hour time format
    return dateFormatter.string(from: date)
}
func returnStart(_ date: Date) -> Int {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(identifier: "America/Vancouver")  // Set to Pacific Time
    dateFormatter.dateFormat = "HH"  // 24-hour time format
    let a = dateFormatter.string(from: date)
    return Int(a) ?? 0
}
func getCurrentHour() -> Int {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        return hour
    }
func weatherSymbol(for code: Float, index: Int) -> String {
    if((5 < index && index < 21) || (29 < index && index < 45)){
        switch code {
        case 0:
            return "sun.max.fill"
        case 1, 2:
            return "cloud.sun.fill"
        case 3:
            return "cloud.fill"
        case 45, 48:
            return "cloud.fog.fill"
        case 51, 53, 55:
            return "cloud.drizzle.fill"
        case 56, 57:
            return "cloud.sleet.fill"
        case 61, 63, 65:
            return "cloud.rain.fill"
        case 66, 67:
            return "cloud.sleet.fill"
        case 71, 73, 75:
            return "cloud.snow.fill"
        case 77:
            return "cloud.snow.fill"
        case 80, 81, 82:
            return "cloud.heavyrain.fill"
        case 85, 86:
            return "cloud.snow.fill"
        case 95:
            return "cloud.bolt.fill"
        case 96, 99:
            return "cloud.bolt.rain.fill"
        default:
            return "questionmark.circle.fill"
        }}
    else{
        switch code {
        case 0:
            return "moon.fill"
        case 1, 2:
            return "cloud.moon.fill"
        case 3:
            return "cloud.fill"
        case 45, 48:
            return "cloud.fog.fill"
        case 51, 53, 55:
            return "cloud.drizzle.fill"
        case 56, 57:
            return "cloud.sleet.fill"
        case 61, 63, 65:
            return "cloud.rain.fill"
        case 66, 67:
            return "cloud.sleet.fill"
        case 71, 73, 75:
            return "cloud.snow.fill"
        case 77:
            return "cloud.snow.fill"
        case 80, 81, 82:
            return "cloud.heavyrain.fill"
        case 85, 86:
            return "cloud.snow.fill"
        case 95:
            return "cloud.bolt.fill"
        case 96, 99:
            return "cloud.bolt.rain.fill"
        default:
            return "questionmark.circle.fill"
        }
    }
}

struct HourWeather: View {
    
    //var hourOfDay: String
    var index: Int
    var weatherLogo: String
    var temp: Int
    
    var body: some View {
        VStack{
            if(index > 12 ){
                Text("\(index - 12)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                +
                Text("PM")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
            } else if(index == 0){
                Text("12")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                +
                Text("AM")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
            }else{
                       
                Text("\(index)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                +
                Text("AM")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
            }
            
            Image(systemName : weatherLogo)
                .symbolRenderingMode(.multicolor)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
            Text("\(temp)°")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.white)
            
        }
        .padding(.leading, 10)
    }
}
struct DayWeather: View {
    
    var dayOfWeek: String
    var weatherLogo: String
    var temp: Int
    
    var body: some View {
        VStack{
            Text(dayOfWeek)
                .font(.system(size: 16))
                .foregroundColor(.white)
            
            Image(systemName : weatherLogo)
                .symbolRenderingMode(.multicolor)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
            Text("\(temp)°")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.white)
            
        }
        .padding(.leading, 10)
    }
}

struct BackgroundView: View {
     
    var isNight: Float
    
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [isNight == 0 ?  Color.black : Color(red: 0, green: 0, blue: 0.5),
                                                   Color(red: 0.678, green: 0.847, blue: 0.902)]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }
}
struct CityTextView: View {
    
    var cityName: String
    
    var body: some View {
        Text(cityName)
            .font(.system(size:32,weight: .medium,design: .default))
            .foregroundColor(.white)
            .padding(.top, 20)
    }
}

struct MainWeatherStatus: View {
    var imageName: String
    var temperature: String
    var high:String
    var low: String

    var body: some View {
        VStack(spacing: -4) {
            Image(systemName: imageName)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 90, height: 90)

            Text("\(temperature)")
                .font(.system(size: 55, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 100)
                
            
            HStack{
                Text("cloudy")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
//                    .frame(width: 180, height: 40, alignment: .center)
//                    .border(Color.red)
                
            }
            
            Text("High: \(high)° Low: \(low)°")
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .padding()
        }
        .padding(.bottom, 40)
    }
}



struct WeatherInfoBlock: View {
    var iconName: String
    var title: String
    var width: CGFloat
    var height: CGFloat
    var content: String

    // Calculate dynamic font size based on block width
    private var dynamicFontSize: CGFloat {
        width * 0.4 // Adjust the multiplier to get the desired font size
    }

    var body: some View {
        VStack {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(.white)
                    .padding(.leading, 10)

                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding([.leading, .trailing], 0)
 
                Spacer()
            }
            .padding(.top, 10)
            Spacer()
            VStack{
                Text(content)
                    .font(.system(size: dynamicFontSize))  // Use dynamic font size
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .frame(width: width, height: height)
        .background(Color.white.opacity(0.2))
        .cornerRadius(12)
    }
}
