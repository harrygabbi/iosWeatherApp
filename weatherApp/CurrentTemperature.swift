import Foundation
import OpenMeteoSdk

class WeatherDataFetcher: ObservableObject {
    
    @Published var currentTemperature: CurrentWeatherData?

    func fetchCurrentWeather(latitude: Double, longitude: Double) async {
        do {
            let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day&daily=temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max&timezone=America%2FLos_Angeles&forecast_days=1&format=flatbuffers")!
            let responses = try await WeatherApiResponse.fetch(url: url)

            let response = responses[0]
            let utcOffsetSeconds = response.utcOffsetSeconds
            let current = response.current!
            let daily = response.daily!

            let data = CurrentWeatherData(
                current: .init(
                    time: Date(timeIntervalSince1970: TimeInterval(current.time + Int64(utcOffsetSeconds))),
                    temperature2m: current.variables(at: 0)!.value,
                    relativeHumidity2m: current.variables(at: 1)!.value,
                    apparentTemperature: current.variables(at: 2)!.value,
                    isDay: current.variables(at: 2)!.value
                ),
                daily: .init(
                    time: daily.getDateTime(offset: utcOffsetSeconds),
                    temperature2mMax: daily.variables(at: 0)!.values,
                    temperature2mMin: daily.variables(at: 1)!.values,
                    sunrise: daily.getDateTime(offset: utcOffsetSeconds),
                    sunset: daily.variables(at: 3)!.values,
                    uvIndexMax: daily.variables(at: 4)!.values
                )
            )
            
            DispatchQueue.main.async {
                self.currentTemperature = data
            }
        } catch {
            print("something went wrong")
        }
    }
}

struct CurrentWeatherData {
    let current: Current
    let daily: Daily

    struct Current {
        let time: Date
        let temperature2m: Float
        let relativeHumidity2m: Float
        let apparentTemperature: Float
        let isDay: Float
    }
    struct Daily {
        let time: [Date]
        let temperature2mMax: [Float]
        let temperature2mMin: [Float]
        let sunrise: [Date]
        let sunset: [Float]
        let uvIndexMax: [Float]
    }
}
