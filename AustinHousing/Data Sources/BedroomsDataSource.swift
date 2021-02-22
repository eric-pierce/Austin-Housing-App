/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Data source for the size field on the UIPicker.
*/

import Foundation

struct BedroomsDataSource {
    /// Helper formatter to represent large nubmers in the picker
    let values = [1, 2, 3, 4, 5]
    
    func title(for index: Int) -> String? {
        guard index < values.count else { return nil }
        return String(values[index])
    }
    
    func value(for index: Int) -> Double? {
        guard index < values.count else { return nil }
        return Double(values[index])
    }
}
