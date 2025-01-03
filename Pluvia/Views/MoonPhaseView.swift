//
//  MoonPhaseView.swift
//  Pluvia
//
//  Created by Dumindu Sameendra on 2024-12-26.
//


import SwiftUI
import SpriteKit

struct MoonPhaseView: View {
    @State private var moonPhaseValue: Double = 0.0 // Moon phase value from 0.0 to 1.0
    @State private var moonPhaseDescription: String = "New Moon" // Description of the phase
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Moon Phase")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            SpriteView(scene: MoonPhaseScene(phase: moonPhaseValue))
                .frame(width: 200, height: 200)
                .cornerRadius(100)
            
            Text(moonPhaseDescription)
                .font(.title)
                .fontWeight(.medium)
            
            Text(String(format: "Phase Value: %.2f", moonPhaseValue))
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Button(action: fetchMoonPhase) {
                Text("Fetch Moon Phase")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
    
    /// Simulate fetching moon phase value and update UI
    func fetchMoonPhase() {
        let startOfDayPhase = Double.random(in: 0...1) // Replace with API data
        let endOfDayPhase = Double.random(in: 0...1)   // Replace with API data
        let averagePhase = (startOfDayPhase + endOfDayPhase) / 2.0
        
        if [0.0, 0.25, 0.5, 0.75, 1.0].contains(startOfDayPhase) {
            moonPhaseValue = startOfDayPhase
        } else if [0.0, 0.25, 0.5, 0.75, 1.0].contains(endOfDayPhase) {
            moonPhaseValue = endOfDayPhase
        } else {
            moonPhaseValue = averagePhase
        }
        
        moonPhaseDescription = phaseDescription(for: moonPhaseValue)
    }
    
    /// Get moon phase description
    func phaseDescription(for phase: Double) -> String {
        switch phase {
        case 0.0, 1.0:
            return "New Moon"
        case 0.25:
            return "First Quarter Moon"
        case 0.5:
            return "Full Moon"
        case 0.75:
            return "Last Quarter Moon"
        case 0.0..<0.25:
            return "Waxing Crescent"
        case 0.25..<0.5:
            return "Waxing Gibbous"
        case 0.5..<0.75:
            return "Waning Gibbous"
        case 0.75..<1.0:
            return "Waning Crescent"
        default:
            return "Unknown Phase"
        }
    }
}

class MoonPhaseScene: SKScene {
    private let moonNode = SKShapeNode(circleOfRadius: 100)
    private let maskNode = SKShapeNode()
    private let phase: Double
    
    init(phase: Double) {
        self.phase = phase
        super.init(size: CGSize(width: 200, height: 200))
        scaleMode = .resizeFill
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        createMoon()
        applyPhaseMask()
    }
    
    private func createMoon() {
        // Add the moon as a white circle
        moonNode.fillColor = .white
        moonNode.strokeColor = .clear
        moonNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(moonNode)
    }
    
    private func applyPhaseMask() {
        let maskWidth = size.width * CGFloat(abs((phase - 0.5) * 2)) // Proportional shading width
        let offset = size.width * CGFloat((phase - 0.5)) // Offset for waxing/waning
        
        // Create a mask for the phase
        maskNode.path = CGPath(rect: CGRect(
            x: size.width / 2 - maskWidth / 2 + offset,
            y: 0,
            width: maskWidth,
            height: size.height
        ), transform: nil)
        maskNode.fillColor = .black
        maskNode.strokeColor = .clear
        moonNode.addChild(maskNode)
    }
}

#Preview {
    MoonPhaseView()
}
