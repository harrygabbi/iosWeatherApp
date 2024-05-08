import Foundation
import OpenMeteoSdk

struct WeatherData {
    let current: Current

    struct Current {
        let time: Date
        let windSpeed10m: Float
        let windDirection10m: Float
        let windGusts10m: Float
    }
}

class WindManager: ObservableObject {
    @Published var windData: WeatherData?
    
    
    
    func fetchWindData(latitude: Double, longitude: Double) async {
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current=wind_speed_10m,wind_direction_10m,wind_gusts_10m&timezone=America%2FLos_Angeles&forecast_days=1&format=flatbuffers"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        do {
            let responses = try await WeatherApiResponse.fetch(url: url)
            let response = responses[0]

            let utcOffsetSeconds = response.utcOffsetSeconds
            
            let current = response.current!
            
            let data = WeatherData(
                current: .init(
                    time: Date(timeIntervalSince1970: TimeInterval(current.time + Int64(utcOffsetSeconds))),
                    windSpeed10m: current.variables(at: 0)!.value,
                    windDirection10m: current.variables(at: 1)!.value,
                    windGusts10m: current.variables(at: 2)!.value
                )
            )
            
            DispatchQueue.main.async {
                self.windData = data
            }
        } catch {
            print("Error fetching wind data: \(error)")
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // GMT
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: date)
    }
}
