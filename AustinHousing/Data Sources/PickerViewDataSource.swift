/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Data source for the picker that manages the solar panels, bathrooms and bedrooms data sources.
*/

import UIKit

/**
     The common data source for the three features and their picker values. Decouples
     the user interface and the feature specific values.
*/
class PickerDataSource: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    // MARK: - Properties
    
    private let livingAreaDataSource = LivingAreaDataSource()
    private let bathroomsDataSource = BathroomsDataSource()
    private let bedroomsDataSource = BedroomsDataSource()
    
    // MARK: - Helpers
    
    /// Find the title for the given feature.
    func title(for row: Int, feature: Feature) -> String? {
        switch feature {
        case .livingArea:  return livingAreaDataSource.title(for: row)
        case .bathrooms:  return bathroomsDataSource.title(for: row)
        case .bedrooms:         return bedroomsDataSource.title(for: row)
        }
    }
    
    /// For the given feature, find the value for the given row.
    func value(for row: Int, feature: Feature) -> Double {
        let value: Double?
        
        switch feature {
        case .livingArea:      value = livingAreaDataSource.value(for: row)
        case .bathrooms:      value = bathroomsDataSource.value(for: row)
        case .bedrooms:             value = bedroomsDataSource.value(for: row)
        }
        
        return value!
    }
    
    // MARK: - UIPickerViewDataSource
    
    /// Hardcoded 3 items in the picker.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    /// Find the count of each column of the picker.
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch Feature(rawValue: component)! {
        case .livingArea:  return livingAreaDataSource.values.count
        case .bathrooms:  return bathroomsDataSource.values.count
        case .bedrooms:  return bedroomsDataSource.values.count
        }
    }
}
