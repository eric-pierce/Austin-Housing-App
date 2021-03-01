/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main view controller for the MarsHabitatPricer app. Uses a `UIPickerView` to gather user inputs.
   The model's output is the predicted price.
*/

import UIKit
import CoreML
import Foundation

extension Bundle {
    func decode<T: Decodable>(_ type: T.Type, from file: String, dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) -> T {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle.")
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        decoder.keyDecodingStrategy = keyDecodingStrategy

        do {
            return try decoder.decode(T.self, from: data)
        } catch DecodingError.keyNotFound(let key, let context) {
            fatalError("Failed to decode \(file) from bundle due to missing key '\(key.stringValue)' not found – \(context.debugDescription)")
        } catch DecodingError.typeMismatch(_, let context) {
            fatalError("Failed to decode \(file) from bundle due to type mismatch – \(context.debugDescription)")
        } catch DecodingError.valueNotFound(let type, let context) {
            fatalError("Failed to decode \(file) from bundle due to missing \(type) value – \(context.debugDescription)")
        } catch DecodingError.dataCorrupted(_) {
            fatalError("Failed to decode \(file) from bundle because it appears to be invalid JSON")
        } catch {
            fatalError("Failed to decode \(file) from bundle: \(error.localizedDescription)")
        }
    }
}

struct House: Codable {
    var zpid: Int
    var propertyTaxRate: Double
    var hasAssociation: Double
    var hasCooling: Double
    var hasGarage: Double
    var hasHeating: Double
    var hasSpa: Double
    var hasView: Double
    var lotSizeSqFt: Double
    var livingAreaSqFt: Double
    var avgSchoolDistance: Double
    var avgSchoolRating: Double
    var avgSchoolSize: Double
    var MedianStudentsPerTeacher: Double
    var BuiltAfter2k: Double
    var HasPhotos: Double
    var HasAccessibilityFeatures: Double
    var HasAppliances: Double
    var HasPatioPorch: Double
    var HasSecurityFeatures: Double
    var HasWaterfront: Double
    var HasWindowFeatures: Double
    var NearElementarySchools: Double
    var NearMiddleSchools: Double
    var NearHighSchools: Double
    var Bathrooms: Double
    var Bedrooms: Double
    var Stories: Double
    var ht_Apartment: Double
    var ht_Condo: Double
    var ht_Mobile_Manufactured: Double
    var ht_MultiFamily: Double
    var ht_Multiple_Occupancy: Double
    var ht_Other: Double
    var ht_Residential: Double
    var ht_Single_Family: Double
    var ht_Townhouse: Double
    var ht_Vacant_Land: Double
    var zip_78617: Double
    var zip_78619: Double
    var zip_78652: Double
    var zip_78653: Double
    var zip_78660: Double
    var zip_78701: Double
    var zip_78702: Double
    var zip_78703: Double
    var zip_78704: Double
    var zip_78705: Double
    var zip_78717: Double
    var zip_78719: Double
    var zip_78721: Double
    var zip_78722: Double
    var zip_78723: Double
    var zip_78724: Double
    var zip_78725: Double
    var zip_78726: Double
    var zip_78727: Double
    var zip_78728: Double
    var zip_78729: Double
    var zip_78730: Double
    var zip_78731: Double
    var zip_78732: Double
    var zip_78733: Double
    var zip_78734: Double
    var zip_78735: Double
    var zip_78736: Double
    var zip_78737: Double
    var zip_78738: Double
    var zip_78739: Double
    var zip_78741: Double
    var zip_78742: Double
    var zip_78744: Double
    var zip_78745: Double
    var zip_78746: Double
    var zip_78747: Double
    var zip_78748: Double
    var zip_78749: Double
    var zip_78750: Double
    var zip_78751: Double
    var zip_78752: Double
    var zip_78753: Double
    var zip_78754: Double
    var zip_78756: Double
    var zip_78757: Double
    var zip_78758: Double
    var zip_78759: Double
    var price: Double
    var photo: String
}

class ViewController: UIViewController {

    let model = AustinHousing_3()
    let homedata = Bundle.main.decode([House].self, from: "finaldata.json")
    var curr_zpid = 58317621
    //var thishouse = House()
    //var modelData = [] as [String]
    /// Data source for the picker.
    let pickerDataSource = PickerDataSource()
    
    /// Formatter for the output.
    let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        formatter.usesGroupingSeparator = true
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    // MARK: - Outlets

    /// Label that will be updated with the predicted price.
    @IBOutlet weak var testDataLabel: UILabel!
    
    /// Label that will be updated with the predicted price.
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var detailsLabel: UILabel!

    @IBOutlet weak var zpidinput: UITextField!
    
    @IBOutlet weak var showphoto: UIImageView!

    @IBAction func ZpidInput(_ sender: Any) {
        var newhouse = homedata.filter{$0.zpid == Int(self.zpidinput.text!)}
        if (newhouse.count > 0) {
            print(newhouse[0])
        //    var mirror = Mirror(reflecting: thishouse[0])
        //    for child in mirror.children  {
        //        print("key: \(child.label), value: \(child.value)")
        //    }
            //detailsLabel.text = thishouse[0].self
            let url = URL(string: newhouse[0].photo)!
            downloadImage(from: url)
            updatePredictedPrice(thishouse: newhouse[0])
        }
     }
    
    /**
         The UI that users will use to select the square footage, number of bathrooms, number of bedrooms
    */
    @IBOutlet weak var pickerView: UIPickerView! {
        didSet {
            pickerView.delegate = self
            pickerView.dataSource = pickerDataSource

            let features: [Feature] = [.livingArea, .bathrooms, .bedrooms]
            //let features: [Feature] = [.garage, .bathrooms, .security]
            for feature in features {
                pickerView.selectRow(2, inComponent: feature.rawValue, animated: false)
            }
        }
    }

    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }


    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { [weak self] in
                self?.showphoto.image = UIImage(data: data)
            }
        }
    }

    /// Updated the predicted price, when created.
    override func viewDidLoad() {
        super.viewDidLoad()
        //updatePredictedPrice()
        //modelData = loadData()
        //let homedata = Bundle.main.decode([House].self, from: "test-data.json")
        print(homedata[0].zpid)
        curr_zpid = homedata[0].zpid
        var thishouse = homedata.filter{$0.zpid == curr_zpid}
        print(thishouse[0].price)
        zpidinput.text = String(curr_zpid)
        var currphoto = thishouse[0].photo
        updatePredictedPrice(thishouse: thishouse[0])
        let url = URL(string: currphoto)!
        downloadImage(from: url)
    }
   
    
    func loadData() -> [String] {
        var housedata = [] as [String]
        let url = URL(string:"https://raw.githubusercontent.com/eric-pierce/Zillow-Housing/main/test-data.csv")!
        let task = URLSession.shared.dataTask(with:url) { (data, response, error) in
            if error != nil {
               print(error!)
            }
            else {
                if let textFile = String(data: data!, encoding: .utf8) {
                //print(textFile)
                    housedata = textFile.components(separatedBy: "\n")
                    print(housedata.count)
                    //housedata = textFile.components(separatedBy: "\n").map{ $0.components(separatedBy: ",") }
                //housedata = getCSVData(textFile)
               }
            }
        }
        task.resume()
        print(housedata.count)
        return housedata//.map{ $0.components(separatedBy: ",")}
    }
    /**
         The main logic for the app, performing the integration with Core ML.
         First gather the values for input to the model. Then have the model generate
         a prediction with those inputs. Finally, present the predicted value to
         the user.
    */
    func updatePredictedPrice(thishouse: House? = nil) {
        func selectedRow(for feature: Feature) -> Int {
            return pickerView.selectedRow(inComponent: feature.rawValue)
        }
        var currhouse = homedata.filter{$0.zpid == curr_zpid}[0]
        if thishouse != nil {
            currhouse = thishouse!
            curr_zpid = currhouse.zpid
        }
        let livingArea = pickerDataSource.value(for: selectedRow(for: .livingArea), feature: .livingArea)
        let bathrooms = pickerDataSource.value(for: selectedRow(for: .bathrooms), feature: .bathrooms)
        let bedrooms = pickerDataSource.value(for: selectedRow(for: .bedrooms), feature: .bedrooms)
        //let garage = pickerDataSource.value(for: selectedRow(for: .garage), feature: .garage)
        //let security = pickerDataSource.value(for: selectedRow(for: .security), feature: .security)

        
        //guard let marsHabitatPricerOutput = try? model.prediction(solarPanels: solarPanels, greenhouses: greenhouses, size: size) else {
        //    fatalError("Unexpected runtime error.")
        //}
        
        guard let austinHousingOutput = try? model.prediction(
            propertyTaxRate: currhouse.propertyTaxRate,
            hasAssociation: currhouse.hasAssociation,
            hasCooling: currhouse.hasCooling,
            hasGarage: currhouse.hasGarage,
            //hasGarage: garage,//currhouse.hasGarage,
            hasHeating: currhouse.hasHeating,
            hasSpa: currhouse.hasSpa,
            hasView: currhouse.hasView,
            lotSizeSqFt: currhouse.lotSizeSqFt,
            livingAreaSqFt: livingArea,
            //livingAreaSqFt: currhouse.livingAreaSqFt, //livingArea,
            avgSchoolDistance: currhouse.avgSchoolDistance,
            avgSchoolRating: currhouse.avgSchoolRating,
            avgSchoolSize: currhouse.avgSchoolSize,
            MedianStudentsPerTeacher: currhouse.MedianStudentsPerTeacher,
            BuiltAfter2k: currhouse.BuiltAfter2k,
            HasPhotos: currhouse.HasPhotos,
            HasAccessibilityFeatures: currhouse.HasAccessibilityFeatures,
            HasAppliances: currhouse.HasAppliances,
            HasPatioPorch: currhouse.HasPatioPorch,
            HasSecurityFeatures: currhouse.HasSecurityFeatures,
            //HasSecurityFeatures: security,//currhouse.HasSecurityFeatures,
            HasWaterfront: currhouse.HasWaterfront,
            HasWindowFeatures: currhouse.HasWindowFeatures,
            NearElementarySchools: currhouse.NearElementarySchools,
            NearMiddleSchools: currhouse.NearMiddleSchools,
            NearHighSchools: currhouse.NearHighSchools,
            Bathrooms: bathrooms,
            //Bedrooms: currhouse.Bedrooms,//bedrooms,
            Bedrooms: bedrooms,
            Stories: currhouse.Stories,
            ht_Apartment: currhouse.ht_Apartment,
            ht_Condo: currhouse.ht_Condo,
            ht_Mobile_Manufactured: currhouse.ht_Mobile_Manufactured,
            ht_MultiFamily: currhouse.ht_MultiFamily,
            ht_Multiple_Occupancy: currhouse.ht_Multiple_Occupancy,
            ht_Other: currhouse.ht_Other,
            ht_Residential: currhouse.ht_Residential,
            ht_Single_Family: currhouse.ht_Single_Family,
            ht_Townhouse: currhouse.ht_Townhouse,
            ht_Vacant_Land: currhouse.ht_Vacant_Land,
            zip_78617: currhouse.zip_78617,
            zip_78619: currhouse.zip_78619,
            zip_78652: currhouse.zip_78652,
            zip_78653: currhouse.zip_78653,
            zip_78660: currhouse.zip_78660,
            zip_78701: currhouse.zip_78701,
            zip_78702: currhouse.zip_78702,
            zip_78703: currhouse.zip_78703,
            zip_78704: currhouse.zip_78704,
            zip_78705: currhouse.zip_78705,
            zip_78717: currhouse.zip_78717,
            zip_78719: currhouse.zip_78719,
            zip_78721: currhouse.zip_78721,
            zip_78722: currhouse.zip_78722,
            zip_78723: currhouse.zip_78723,
            zip_78724: currhouse.zip_78724,
            zip_78725: currhouse.zip_78725,
            zip_78726: currhouse.zip_78726,
            zip_78727: currhouse.zip_78727,
            zip_78728: currhouse.zip_78728,
            zip_78729: currhouse.zip_78729,
            zip_78730: currhouse.zip_78730,
            zip_78731: currhouse.zip_78731,
            zip_78732: currhouse.zip_78732,
            zip_78733: currhouse.zip_78733,
            zip_78734: currhouse.zip_78734,
            zip_78735: currhouse.zip_78735,
            zip_78736: currhouse.zip_78736,
            zip_78737: currhouse.zip_78737,
            zip_78738: currhouse.zip_78738,
            zip_78739: currhouse.zip_78739,
            zip_78741: currhouse.zip_78741,
            zip_78742: currhouse.zip_78742,
            zip_78744: currhouse.zip_78744,
            zip_78745: currhouse.zip_78745,
            zip_78746: currhouse.zip_78746,
            zip_78747: currhouse.zip_78747,
            zip_78748: currhouse.zip_78748,
            zip_78749: currhouse.zip_78749,
            zip_78750: currhouse.zip_78750,
            zip_78751: currhouse.zip_78751,
            zip_78752: currhouse.zip_78752,
            zip_78753: currhouse.zip_78753,
            zip_78754: currhouse.zip_78754,
            zip_78756: currhouse.zip_78756,
            zip_78757: currhouse.zip_78757,
            zip_78758: currhouse.zip_78758,
            zip_78759: currhouse.zip_78759
            ) else {
            fatalError("Unexpected runtime error.")
        }

//        print(housedata.count)
        let price = austinHousingOutput.price
        priceLabel.text = priceFormatter.string(for: price)
        detailsLabel.numberOfLines = 4
        detailsLabel.text = "Living Area: " + String(currhouse.livingAreaSqFt) + "\nBathrooms: " + String(currhouse.Bathrooms) + "\nBedrooms: " + String(currhouse.Bedrooms)
        //testDataLabel.text = priceFormatter.string(for: housedata.count)
    }
}
