import WidgetKit
import Foundation

enum WidgetReloader {
    private static var pending: DispatchWorkItem?

    static func requestReload() {
        pending?.cancel()
        let item = DispatchWorkItem {
            WidgetCenter.shared.reloadAllTimelines()
        }
        pending = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: item)
    }
}
