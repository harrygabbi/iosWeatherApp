import Foundation
import OpenMeteoSdk

class HourlyWeather: ObservableObject {
    @Published var currentTemperature: HourlyWeatherData?
    private let locationManager = LocationManager()
    
//    func initiateWeatherFetch() {
//            Task {
//                do {
////                    let location = try await locationManager.fetchLocation()
//                    await fetchCurrentWeather(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//                } catch {
//                    print("Failed to fetch location or weather data: \(error)")
//                }
//            }
//        }

    func fetchCurrentWeather(latitude: Double, longitude: Double) async {
            let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&hourly=temperature_2m,weather_code&timezone=America%2FLos_Angeles&forecast_days=3&format=flatbuffers"
            guard let url = URL(string: urlString) else {
                print("Invalid URL")
                return
            }

            do {
                let responses = try await WeatherApiResponse.fetch(url: url)
                let response = responses[0]
                let utcOffsetSeconds = response.utcOffsetSeconds
                let hourly = response.hourly!

                let data = HourlyWeatherData(
                    hourly: .init(
                        time: hourly.getDateTime(offset: utcOffsetSeconds),
                        temperature2m: hourly.variables(at: 0)!.values,
                        weatherCode: hourly.variables(at: 1)!.values
                    )
                )

                DispatchQueue.main.async {
                    self.currentTemperature = data
                }
            } catch {
                print("Error fetching weather data: \(error)")
            }
        }
}

struct HourlyWeatherData {
    let hourly: Hourly

    struct Hourly {
        let time: [Date]
        let temperature2m: [Float]
        let weatherCode: [Float]
    }
}
