//
//  SprayerSettingFinder.swift
//  GardenDial
//
//  Created by Luna Zhang on 4/13/25.
//

import Foundation

struct SprayerSettingFinder {
    
    func getInstruction(sprayerModel: String, totalVolumeGallon: Double, concentrationPerGallcon: String, selectedStrengthPercentage: Double, unitPerGallon: String, concentrationRatio: Double, isRatioActive: Bool) -> String {
        
        guard let sprayer = allSprayers[sprayerModel] else {
            return "Sprayer model not found."
        }
        
        // 1. calculate desired cencenration in %
        var desiredConcentration: Double
        
        // If concentrationRatio is provided, calculate the adjusted concentration as 1 / concentrationRatio
        if isRatioActive {
            desiredConcentration = 1 / concentrationRatio
        } else {
            // Validate concenrtation
            guard let concentration = Double(concentrationPerGallcon), concentration > 0 else {
                return "Please enter a valid concentration."
            }
            var concentrationTBSpGAL = concentration
            switch unitPerGallon {
            case "Teaspoon":
                concentrationTBSpGAL /= 3 // Convert from tsp to tbs
            case "OZ":
                concentrationTBSpGAL *= 2 // Convert from oz to tbs
            default:
                break // Default is tbs, no conversion needed
            }
            concentrationTBSpGAL *= (selectedStrengthPercentage / 100.0)
            desiredConcentration = concentrationTBSpGAL / 256 // convert to % by tbs/tbs
        }
        // 2. calculateProductVolume
        let productVolumeTBS = calculateProductVolume(desiredConcentration: desiredConcentration, totalVolumeGallon: totalVolumeGallon)
        // If product needed exceeds half of sprayer capacity, suggest batching. Calculated in oz
        if (productVolumeTBS/2) > (sprayer.volumeOptions.max()! / 2)  {
            let batchesNeeded = max(2, Int(ceil( (productVolumeTBS/2) / sprayer.volumeOptions.max()!)) + 1)
            return "Product needed exceeds half of the sprayer capacity. Make \(batchesNeeded) batches with proportionally reduced total water volume."
        }
        // If product needed is too little
        if productVolumeTBS <= (1.0 / 6.0) {
            return "Unable to create a suitable mixture. Try increasing total water volume or using a higher concentration."
        }
        // 3. findSettings
        let settings = findSettings(sprayer: sprayer, productVolumeTBS: productVolumeTBS, desiredConcentration: desiredConcentration)
        // 4. put together the message
        let productVolumeFormatted = formatFraction(productVolumeTBS)
        guard let waterVolumeStr = settings.waterVolumeOZ,
              let dialSetting = settings.dialSetting,
              waterVolumeStr != "N/A",
              dialSetting != "N/A",
              let waterVolumeOZ = Double(waterVolumeStr)else {
            return "Unable to create a suitable mixture."
        }
        // Calculate actual concentration based on selected water & dial
        let actualConcentration = (productVolumeTBS / (waterVolumeOZ * 2)) * sprayer.dialOptions[dialSetting]!
        let differencePercent = ((actualConcentration - desiredConcentration) / desiredConcentration) * 100

        var message = """
        1. Mix \(productVolumeFormatted) Tablespoon product with \(Int(waterVolumeOZ)) OZ water.
        2. Set Dial to \(dialSetting).
        """

        if differencePercent > 20 {
            message += "\nNote: Concentration might be higher than desired."
        } else if differencePercent < -20 {
            message += "\nNote: Concentration might be lower than desired."
        }
        
        return message
    }
    
    func calculateProductVolume(desiredConcentration: Double, totalVolumeGallon: Double) -> Double {
        let totalVolumeTBS = 256.0 * totalVolumeGallon // convert to tbs
        // Calculate productTBS needed
        let productTBS = totalVolumeTBS * desiredConcentration
        return productTBS // in tbs
    }
    
    func findSettings(sprayer: Sprayer, productVolumeTBS: Double, desiredConcentration: Double) -> (waterVolumeOZ: String?, dialSetting: String?)  {
        // find the combination of waterVolumeOZ and dialSetting that makes productVolumeTBS/waterVolumeOZ*dialSetting closest to desiredConcentration
        var bestMatch: (water: Double, dial: String)? = nil
        var smallestDiff = Double.greatestFiniteMagnitude
        
        for waterVolumeOZ in sprayer.volumeOptions {
            for (dialLabel, dialRatio) in sprayer.dialOptions {
                // Calculate concentration: productVolume / waterVolume * dialRatio
                let estimatedConcentration = (productVolumeTBS / (waterVolumeOZ * 2.0)) * dialRatio
                
                let diff = abs(estimatedConcentration - desiredConcentration)
                if diff < smallestDiff {
                    smallestDiff = diff
                    bestMatch = (waterVolumeOZ, dialLabel)
                }
            }
        }
        
        guard let match = bestMatch else {
            return ("N/A", "N/A")
        }
        
        let formattedWaterOZ = String(format: "%.1f", match.water)
            return (formattedWaterOZ, match.dial)
    }
    
    private func formatFraction(_ value: Double) -> String {
            let wholeNumber = Int(value)
            let decimalPart = value - Double(wholeNumber)
            
            let fractionValues: [(Double, String)] = [
                (1.0/4.0, "1/4"), (1.0/3.0, "1/3"), (1.0/2.0, "1/2"), (2.0/3.0, "2/3"), (3.0/4.0, "3/4")
            ]
            
            if decimalPart == 0 {
                return "\(wholeNumber)"
            }
            
            if let closest = fractionValues.min(by: { abs($0.0 - decimalPart) < abs($1.0 - decimalPart) }) {
                return wholeNumber > 0 ? "\(wholeNumber) \(closest.1)" : closest.1
            }
            
            return String(format: "%.2f", value)
        }
    
}
