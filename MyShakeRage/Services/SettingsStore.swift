import Foundation

final class SettingsStore {
    private enum Keys {
        static let settings = "app_settings"
        static let shakeCountPrefix = "daily_shake_count_"
    }

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadSettings() -> AppSettings {
        guard
            let data = defaults.data(forKey: Keys.settings),
            let settings = try? decoder.decode(AppSettings.self, from: data)
        else {
            return .default
        }

        return settings
    }

    func saveSettings(_ settings: AppSettings) throws {
        let data = try encoder.encode(settings)
        defaults.set(data, forKey: Keys.settings)
    }

    func shakeCount(for date: Date, calendar: Calendar = .current) -> Int {
        defaults.integer(forKey: shakeCountKey(for: date, calendar: calendar))
    }

    func incrementShakeCount(for date: Date = .now, calendar: Calendar = .current) {
        let key = shakeCountKey(for: date, calendar: calendar)
        defaults.set(defaults.integer(forKey: key) + 1, forKey: key)
    }

    private func shakeCountKey(for date: Date, calendar: Calendar) -> String {
        Keys.shakeCountPrefix + date.dayKey(calendar: calendar)
    }
}
