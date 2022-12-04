import SwiftUI

@available(iOS 15.0, macOS 10.15, *)
public protocol AppColorScheme {
    func getBackgroundColor() -> Color
    
    func getSurfaceColor() -> Color
    
    func getOnSurfaceColor() -> Color
    
    func getPrimaryColor() -> Color
    
    func getSecondaryColor() -> Color
    
    func getOnSecondaryColor() -> Color
    
    func getBodyTextColor() -> Color
    
    func getDividerColor() -> Color
}
