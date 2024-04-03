/// Copyright (c) 2019 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI
import Combine

/*
 - Conforms to ObservableObject so that others can view any changes in this class
 - Conforms to Identifiable so it can be "identified" with a UUID or other id
 */
class WeeklyWeatherViewModel: ObservableObject, Identifiable {
	
	// MARK: @Published property wrapper creates a Publisher for the variable
	@Published var city: String = ""
	@Published var dataSource: [DailyWeatherRowViewModel] = []
	private let weatherFetcher: WeatherFetchable
	
	/*
	 MARK: A collection of references to requests
	 */
	private var disposables = Set<AnyCancellable>()
	
	init(weatherFetcher: WeatherFetchable) {
		self.weatherFetcher = weatherFetcher
	}
	
	func fetchWeather(forCity city: String) {
		
		weatherFetcher.weeklyWeatherForecast(forCity: city)
		
			// MARK: Map response to an array of ViewModel objects
			.map { response in
				response.list.map(DailyWeatherRowViewModel.init)
			}
			.map(Array.removeDuplicates)
		
			// MARK: Place response to the main queue where the UI lives
			.receive(on: DispatchQueue.main)
		
		// MARK: Create a publisher to update the dataSource
			.sink { [weak self] value in
				guard let self = self else { return }
				switch (value) {
					case .failure:
						self.dataSource = []
					case .finished:
						break
				}
			} receiveValue: { [weak self] forecast in
				guard let self = self else { return }
				self.dataSource = forecast
			}
		
			// MARK: By storying this into disposables, the publisher will remain active until the app terminates
			.store(in: &disposables)


	}
	
}

