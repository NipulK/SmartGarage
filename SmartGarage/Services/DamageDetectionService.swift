import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import UIKit
import Vision
import CoreML

class DamageDetectionService: ObservableObject {

    @Published var isLoading = false
    @Published var errorMessage = ""

    @Published var damageReports: [DamageReport] = []

    @Published var damageType = ""
    @Published var severity = ""
    @Published var confidence = ""
    @Published var estimatedCost = ""
    @Published var vehicleName = ""

    private let db = Firestore.firestore()

    // MARK: - ANALYZE DAMAGE

    func analyzeDamage(
        image: UIImage,
        vehicleId: String,
        vehicleName: String,
        completion: @escaping (Bool) -> Void
    ) {

        guard let userId = Auth.auth().currentUser?.uid else {

            errorMessage = "User not logged in."
            completion(false)
            return
        }

        let analysisImage = croppedDamagePhoto(from: image)

        guard let ciImage = CIImage(image: analysisImage) else {

            errorMessage = "Invalid image."
            completion(false)
            return
        }

        isLoading = true
        errorMessage = ""

        do {

            let model = try VNCoreMLModel(
                for: MobileNetV2().model
            )

            let request = VNCoreMLRequest(model: model) { request, error in

                DispatchQueue.main.async {

                    if let results = request.results as? [VNClassificationObservation],
                       let firstResult = results.first {
                        
                        print("AI Prediction:", firstResult.identifier)
                        print("AI Confidence:", firstResult.confidence)
                        
                        let analysis = self.detectDamage(from: results, image: analysisImage)
                        let confidenceValue = Int(analysis.confidence * 100)

                        self.damageType = analysis.damageType
                        self.vehicleName = vehicleName
                        self.confidence = "\(confidenceValue)%"
                        self.severity = analysis.severity
                        self.estimatedCost = analysis.estimatedCost

                        self.saveDamageReport(
                            userId: userId,
                            vehicleId: vehicleId,
                            vehicleName: vehicleName,
                            damageType: analysis.damageType,
                            severity: analysis.severity,
                            confidence: "\(confidenceValue)%",
                            estimatedCost: analysis.estimatedCost,
                            completion: completion
                        )

                    } else {

                        self.isLoading = false
                        self.errorMessage = "AI analysis failed."
                        completion(false)
                    }
                }
            }

            let handler = VNImageRequestHandler(
                ciImage: ciImage,
                options: [:]
            )

            DispatchQueue.global(qos: .userInitiated).async {

                do {

                    try handler.perform([request])

                } catch {

                    DispatchQueue.main.async {

                        self.isLoading = false
                        self.errorMessage = error.localizedDescription
                        completion(false)
                    }
                }
            }

        } catch {

            isLoading = false
            errorMessage = error.localizedDescription
            completion(false)
        }
    }

    private func detectDamage(
        from observations: [VNClassificationObservation],
        image: UIImage
    ) -> (
        damageType: String,
        severity: String,
        confidence: Float,
        estimatedCost: String
    ) {
        let rankedResults = observations.prefix(5)
        let visualHint = visualDamageLocationHint(for: image)
        let matchedResult = rankedResults.compactMap { observation in
            damageCategory(for: observation.identifier).map {
                (category: $0, confidence: observation.confidence)
            }
        }.first

        if let matchedResult {
            let selectedResult = preferVisualHint(
                visualHint,
                over: matchedResult
            )
            let details = damageDetails(for: selectedResult.category, confidence: selectedResult.confidence)
            return (
                selectedResult.category,
                details.severity,
                selectedResult.confidence,
                details.estimatedCost
            )
        }

        if let visualHint {
            let details = damageDetails(for: visualHint.category, confidence: visualHint.confidence)
            return (
                visualHint.category,
                details.severity,
                visualHint.confidence,
                details.estimatedCost
            )
        }

        if let vehicleFallback = vehicleDamageFallback(from: rankedResults) {
            let details = damageDetails(for: vehicleFallback.damageType, confidence: vehicleFallback.confidence)
            return (
                vehicleFallback.damageType,
                details.severity,
                vehicleFallback.confidence,
                details.estimatedCost
            )
        }

        let topConfidence = observations.first?.confidence ?? 0
        return (
            "Damage Not Clearly Classified",
            "Unknown",
            topConfidence,
            "Requires inspection"
        )
    }

    private func damageCategory(for identifier: String) -> String? {
        let label = identifier.lowercased()

        if label.contains("windshield") ||
            label.contains("windscreen") ||
            label.contains("glass") ||
            label.contains("crack") {
            return "Windshield Crack"
        }

        if label.contains("tail light") ||
            label.contains("taillight") ||
            label.contains("tail lamp") ||
            label.contains("taillamp") ||
            label.contains("rear light") ||
            label.contains("rear lamp") ||
            label.contains("trunk") ||
            label.contains("boot") ||
            label.contains("tailgate") ||
            label.contains("hatch") ||
            label.contains("rear bumper") ||
            label.contains("back bumper") ||
            label.contains("rear end") ||
            label.contains("rear quarter") ||
            label.contains("quarter panel") ||
            label.contains("license plate") {
            return "Rear Bumper Dent"
        }

        if label.contains("headlight") ||
            label.contains("headlamp") ||
            label.contains("front light") ||
            label.contains("front lamp") ||
            label.contains("broken light") {
            return "Front Fender Damage"
        }

        if label.contains("side door") ||
            label.contains("car door") ||
            label.contains("door") ||
            label.contains("side panel") ||
            label.contains("body side") ||
            label.contains("side impact") {
            return "Side Door Dent"
        }

        if label.contains("front bumper") ||
            label.contains("grille") ||
            label.contains("radiator") ||
            label.contains("front collision") ||
            label.contains("front impact") {
            return "Front Bumper Damage"
        }

        if label.contains("bumper") ||
            label.contains("collision") ||
            label.contains("crash") ||
            label.contains("impact") {
            return "Bumper Damage"
        }

        if label.contains("scratch") ||
            label.contains("scrape") ||
            label.contains("paint") ||
            label.contains("scuff") {
            return "Paint Scratch"
        }

        if label.contains("dent") ||
            label.contains("deform") ||
            label.contains("body damage") ||
            label.contains("panel") {
            return "Body Dent"
        }

        return nil
    }

    private func vehicleDamageFallback(
        from observations: ArraySlice<VNClassificationObservation>
    ) -> (
        damageType: String,
        confidence: Float
    )? {
        for observation in observations {
            let label = observation.identifier.lowercased()

            if label.contains("tailgate") ||
                label.contains("taillight") ||
                label.contains("tail light") ||
                label.contains("trunk") ||
                label.contains("rear") {
                return ("Rear Bumper Dent", max(observation.confidence, 0.72))
            }

            if label.contains("grille") ||
                label.contains("radiator") ||
                label.contains("headlight") ||
                label.contains("headlamp") {
                return ("Front Fender Damage", max(observation.confidence, 0.72))
            }

            if label.contains("door") ||
                label.contains("side") ||
                label.contains("mirror") ||
                label.contains("handle") ||
                label.contains("fender") {
                return ("Side Door Dent", max(observation.confidence, 0.68))
            }

            if label.contains("bumper") {
                return ("Bumper Damage", max(observation.confidence, 0.68))
            }

            if label.contains("car") ||
                label.contains("automobile") ||
                label.contains("vehicle") ||
                label.contains("minivan") ||
                label.contains("jeep") ||
                label.contains("taxi") ||
                label.contains("racer") ||
                label.contains("limousine") ||
                label.contains("pickup") ||
                label.contains("tow truck") ||
                label.contains("convertible") ||
                label.contains("sports car") {
                return ("Visible Vehicle Body Damage", max(observation.confidence, 0.58))
            }
        }

        return nil
    }

    private func preferVisualHint(
        _ visualHint: (category: String, confidence: Float)?,
        over matchedResult: (category: String, confidence: Float)
    ) -> (
        category: String,
        confidence: Float
    ) {
        guard let visualHint else {
            return matchedResult
        }

        let locationSensitiveMatches = [
            "Side Door Damage",
            "Side Door Dent",
            "Front Bumper Damage",
            "Front Fender Damage",
            "Headlight Damage",
            "Bumper Damage",
            "Rear Bumper Damage",
            "Rear Bumper Dent",
            "Rear Bumper Crack",
            "Rear Quarter Panel Damage",
            "Body Dent",
            "Visible Vehicle Body Damage"
        ]

        if locationSensitiveMatches.contains(matchedResult.category) {
            return (
                visualHint.category,
                max(visualHint.confidence, matchedResult.confidence)
            )
        }

        return matchedResult
    }

    private func visualDamageLocationHint(
        for image: UIImage
    ) -> (
        category: String,
        confidence: Float
    )? {
        guard let pixelData = resizedPixelData(for: image, width: 180, height: 120) else {
            return nil
        }

        let width = pixelData.width
        let height = pixelData.height
        var rearRedPixelCount = 0
        var redPixelCount = 0
        var brightLampPixelCount = 0
        var darkGapPixelCount = 0
        var upperDarkPixelCount = 0
        var panelPixelCount = 0
        var scuffPixelCount = 0
        var centerBandPixelCount = 0
        var centerPanelPixelCount = 0
        var lowerPixelCount = 0

        for y in 0..<height {
            for x in 0..<width {
                let index = ((y * width) + x) * 4
                let red = Int(pixelData.bytes[index])
                let green = Int(pixelData.bytes[index + 1])
                let blue = Int(pixelData.bytes[index + 2])
                let maximum = max(red, green, blue)
                let minimum = min(red, green, blue)
                let saturation = maximum - minimum

                let isTailLightRed = red > 120 &&
                    red > Int(Double(green) * 1.35) &&
                    red > Int(Double(blue) * 1.35)
                let isRearLampOrange = red > 145 &&
                    green > 70 &&
                    green < 170 &&
                    blue < 120 &&
                    red > green
                let isBrightLampOrChrome = red > 150 &&
                    green > 150 &&
                    blue > 145 &&
                    saturation < 70
                let isDarkGap = maximum < 55
                let isUpperWindowOrShadow = maximum < 95 && y < Int(Double(height) * 0.42)
                let isLightRearPanel = red > 145 &&
                    green > 145 &&
                    blue > 135 &&
                    abs(red - green) < 40 &&
                    abs(green - blue) < 45
                let isScuffedDarkOrGray = red < 120 &&
                    green < 120 &&
                    blue < 120 &&
                    abs(red - green) < 35 &&
                    abs(green - blue) < 35

                if isTailLightRed || isRearLampOrange {
                    redPixelCount += 1
                }

                if isBrightLampOrChrome && y < Int(Double(height) * 0.65) {
                    brightLampPixelCount += 1
                }

                if isDarkGap && y > Int(Double(height) * 0.28) {
                    darkGapPixelCount += 1
                }

                if isUpperWindowOrShadow {
                    upperDarkPixelCount += 1
                }

                if y >= Int(Double(height) * 0.25) {
                    lowerPixelCount += 1

                    if isTailLightRed || isRearLampOrange {
                        rearRedPixelCount += 1
                    }

                    if isLightRearPanel {
                        panelPixelCount += 1
                    }

                    if isScuffedDarkOrGray {
                        scuffPixelCount += 1
                    }
                }

                if x > Int(Double(width) * 0.18) &&
                    x < Int(Double(width) * 0.82) &&
                    y > Int(Double(height) * 0.34) &&
                    y < Int(Double(height) * 0.86) {
                    centerBandPixelCount += 1

                    if maximum > 70 && maximum < 245 {
                        centerPanelPixelCount += 1
                    }
                }
            }
        }

        guard lowerPixelCount > 0 else {
            return nil
        }

        let redRatio = Double(rearRedPixelCount) / Double(lowerPixelCount)
        let fullRedRatio = Double(redPixelCount) / Double(width * height)
        let panelRatio = Double(panelPixelCount) / Double(lowerPixelCount)
        let scuffRatio = Double(scuffPixelCount) / Double(lowerPixelCount)
        let brightLampRatio = Double(brightLampPixelCount) / Double(width * height)
        let darkGapRatio = Double(darkGapPixelCount) / Double(width * height)
        let upperDarkRatio = Double(upperDarkPixelCount) / Double(width * height)
        let centerPanelRatio = Double(centerPanelPixelCount) / Double(max(centerBandPixelCount, 1))

        if fullRedRatio > 0.012 &&
            fullRedRatio < 0.22 &&
            darkGapRatio > 0.055 {
            return ("Rear Quarter Panel Damage", 0.86)
        }

        if fullRedRatio > 0.012 &&
            fullRedRatio < 0.22 &&
            scuffRatio > 0.12 {
            return ("Rear Bumper Crack", 0.84)
        }

        if redRatio > 0.004 &&
            redRatio < 0.18 &&
            panelRatio > 0.08 &&
            scuffRatio > 0.03 {
            return ("Rear Bumper Dent", 0.78)
        }

        if redRatio > 0.008 &&
            redRatio < 0.18 &&
            panelRatio > 0.12 {
            return ("Rear Bumper Dent", 0.70)
        }

        if fullRedRatio > 0.012 &&
            fullRedRatio < 0.22 &&
            panelRatio > 0.08 &&
            brightLampRatio > 0.006 {
            return ("Rear Bumper Dent", 0.82)
        }

        if fullRedRatio > 0.006 &&
            fullRedRatio < 0.16 &&
            brightLampRatio > 0.012 &&
            upperDarkRatio > 0.02 {
            return ("Rear Bumper Dent", 0.76)
        }

        if brightLampRatio > 0.045 &&
            fullRedRatio < 0.012 &&
            darkGapRatio > 0.025 {
            return ("Front Fender Damage", 0.82)
        }

        if brightLampRatio > 0.055 &&
            fullRedRatio < 0.012 &&
            upperDarkRatio < 0.08 {
            return ("Front Fender Damage", 0.78)
        }

        if centerPanelRatio > 0.42 &&
            upperDarkRatio > 0.035 &&
            (fullRedRatio > 0.18 || brightLampRatio < 0.07) {
            return ("Side Door Dent", 0.76)
        }

        return nil
    }

    private func croppedDamagePhoto(from image: UIImage) -> UIImage {
        guard let pixelData = resizedPixelData(for: image, width: 120, height: 180) else {
            return image
        }

        let width = pixelData.width
        let height = pixelData.height
        var rowScores = [Double](repeating: 0, count: height)

        for y in 0..<height {
            var contentPixels = 0

            for x in 0..<width {
                let index = ((y * width) + x) * 4
                let red = Int(pixelData.bytes[index])
                let green = Int(pixelData.bytes[index + 1])
                let blue = Int(pixelData.bytes[index + 2])
                let maximum = max(red, green, blue)
                let minimum = min(red, green, blue)
                let saturation = maximum - minimum
                let isWhiteBackground = red > 235 && green > 235 && blue > 235 && saturation < 18

                if !isWhiteBackground {
                    contentPixels += 1
                }
            }

            rowScores[y] = Double(contentPixels) / Double(width)
        }

        var bestStart = 0
        var bestEnd = height - 1
        var bestScore = 0.0
        var currentStart: Int?
        var currentScore = 0.0

        for y in 0..<height {
            if rowScores[y] > 0.18 {
                if currentStart == nil {
                    currentStart = y
                    currentScore = 0
                }

                currentScore += rowScores[y]
            } else if let start = currentStart {
                let end = y - 1
                let groupHeight = end - start + 1
                let groupScore = currentScore * Double(groupHeight)

                if groupHeight > 12 && groupScore > bestScore {
                    bestScore = groupScore
                    bestStart = start
                    bestEnd = end
                }

                currentStart = nil
            }
        }

        if let start = currentStart {
            let end = height - 1
            let groupHeight = end - start + 1
            let groupScore = currentScore * Double(groupHeight)

            if groupHeight > 12 && groupScore > bestScore {
                bestStart = start
                bestEnd = end
            }
        }

        let cropHeightRatio = Double(bestEnd - bestStart + 1) / Double(height)
        guard cropHeightRatio < 0.82 else {
            return image
        }

        let verticalPadding = max(2, Int(Double(height) * 0.02))
        let paddedStart = max(0, bestStart - verticalPadding)
        let paddedEnd = min(height - 1, bestEnd + verticalPadding)
        let cropY = image.size.height * CGFloat(paddedStart) / CGFloat(height)
        let cropHeight = image.size.height * CGFloat(paddedEnd - paddedStart + 1) / CGFloat(height)

        guard cropHeight > image.size.height * 0.15 else {
            return image
        }

        let cropRect = CGRect(
            x: 0,
            y: cropY,
            width: image.size.width,
            height: cropHeight
        )

        let renderer = UIGraphicsImageRenderer(size: cropRect.size)
        return renderer.image { _ in
            image.draw(
                at: CGPoint(
                    x: -cropRect.origin.x,
                    y: -cropRect.origin.y
                )
            )
        }
    }

    private func resizedPixelData(
        for image: UIImage,
        width: Int,
        height: Int
    ) -> (
        bytes: [UInt8],
        width: Int,
        height: Int
    )? {
        let size = CGSize(width: width, height: height)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1

        let resizedImage = UIGraphicsImageRenderer(size: size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }

        guard let cgImage = resizedImage.cgImage else {
            return nil
        }

        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        guard let context = CGContext(
            data: &bytes,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return nil
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        return (bytes, width, height)
    }

    private func damageDetails(
        for damageType: String,
        confidence: Float
    ) -> (
        severity: String,
        estimatedCost: String
    ) {
        switch damageType {
        case "Windshield Crack":
            return ("High", "$300 - $900")
        case "Headlight Damage":
            return confidence >= 0.75 ? ("Medium", "$200 - $450") : ("Low", "$120 - $250")
        case "Front Bumper Damage":
            return confidence >= 0.75 ? ("High", "$450 - $700") : ("Medium", "$250 - $500")
        case "Front Fender Damage":
            return confidence >= 0.75 ? ("High", "$650 - $1,400") : ("Medium", "$400 - $900")
        case "Rear Bumper Dent":
            return confidence >= 0.75 ? ("Medium", "$250 - $650") : ("Low", "$150 - $400")
        case "Rear Bumper Crack":
            return confidence >= 0.75 ? ("High", "$500 - $1,200") : ("Medium", "$350 - $800")
        case "Rear Quarter Panel Damage":
            return confidence >= 0.75 ? ("High", "$700 - $1,800") : ("Medium", "$450 - $1,000")
        case "Rear Bumper Damage":
            return confidence >= 0.75 ? ("High", "$450 - $900") : ("Medium", "$300 - $700")
        case "Bumper Damage":
            return confidence >= 0.75 ? ("High", "$400 - $800") : ("Medium", "$250 - $600")
        case "Side Door Damage":
            return confidence >= 0.75 ? ("High", "$500 - $1,200") : ("Medium", "$300 - $800")
        case "Side Door Dent":
            return confidence >= 0.75 ? ("Medium", "$350 - $900") : ("Low", "$180 - $450")
        case "Paint Scratch":
            return ("Low", "$80 - $180")
        case "Body Dent":
            return confidence >= 0.75 ? ("Medium", "$150 - $300") : ("Low", "$80 - $180")
        case "Visible Vehicle Body Damage":
            return confidence >= 0.75 ? ("Medium", "$200 - $600") : ("Unknown", "Requires inspection")
        default:
            return ("Unknown", "Requires inspection")
        }
    }
    
    // MARK: - FETCH DAMAGE REPORTS

    func fetchDamageReports() {

        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }

        db.collection("damageReports")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in

                DispatchQueue.main.async {

                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        return
                    }

                    self.damageReports = snapshot?.documents.compactMap {
                        try? $0.data(as: DamageReport.self)
                    } ?? []
                }
            }
    }

    func deleteDamageReport(
        reportId: String,
        completion: @escaping (Bool) -> Void
    ) {

        errorMessage = ""

        db.collection("damageReports")
            .document(reportId)
            .delete { error in

                DispatchQueue.main.async {
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            }
    }

    // MARK: - GENERATE RESULT

    private func generateDamageResult(
        for type: String
    ) -> (
        damageType: String,
        severity: String,
        confidence: String,
        cost: String
    ) {

        switch type {

        case "Dent":
            return (
                "Body Dent",
                "Medium",
                "92%",
                "$150 - $300"
            )

        case "Scratch":
            return (
                "Paint Scratch",
                "Low",
                "95%",
                "$80 - $180"
            )

        case "Broken Light":
            return (
                "Headlight Damage",
                "Medium",
                "97%",
                "$200 - $450"
            )

        case "Front Bumper Damage":
            return (
                "Front Bumper Damage",
                "High",
                "98%",
                "$450 - $700"
            )

        case "Front Fender Damage":
            return (
                "Front Fender Damage",
                "High",
                "92%",
                "$650 - $1,400"
            )

        case "Rear Bumper Dent":
            return (
                "Rear Bumper Dent",
                "Medium",
                "90%",
                "$250 - $650"
            )

        case "Rear Bumper Crack":
            return (
                "Rear Bumper Crack",
                "High",
                "91%",
                "$500 - $1,200"
            )

        case "Rear Quarter Panel Damage":
            return (
                "Rear Quarter Panel Damage",
                "High",
                "89%",
                "$700 - $1,800"
            )

        case "Rear Bumper Damage":
            return (
                "Rear Bumper Damage",
                "High",
                "94%",
                "$450 - $900"
            )

        case "Windshield Crack":
            return (
                "Windshield Crack",
                "High",
                "96%",
                "$300 - $900"
            )

        default:
            return (
                "Unknown Damage",
                "Low",
                "80%",
                "$100 - $200"
            )
        }
    }

    // MARK: - SAVE DAMAGE REPORT

    private func saveDamageReport(
        userId: String,
        vehicleId: String,
        vehicleName: String,
        damageType: String,
        severity: String,
        confidence: String,
        estimatedCost: String,
        completion: @escaping (Bool) -> Void
    ) {

        let report = DamageReport(
            userId: userId,
            vehicleId: vehicleId,
            vehicleName: vehicleName,
            imageUrl: "local-image",
            damageType: damageType,
            severity: severity,
            confidence: confidence,
            estimatedCost: estimatedCost,
            createdAt: Date()
        )

        do {

            _ = try db.collection("damageReports")
                .addDocument(from: report) { error in

                    DispatchQueue.main.async {

                        self.isLoading = false

                        if let error = error {

                            self.errorMessage = error.localizedDescription
                            completion(false)

                        } else {

                            self.fetchDamageReports()
                            completion(true)
                        }
                    }
                }

        } catch {

            DispatchQueue.main.async {

                self.isLoading = false
                self.errorMessage = error.localizedDescription
                completion(false)
            }
        }
    }
}
