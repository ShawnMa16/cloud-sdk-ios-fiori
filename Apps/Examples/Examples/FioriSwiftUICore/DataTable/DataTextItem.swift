import SwiftUI

open class DataTextItem: DataItem {
    public var type: DataItemType

    var text: String
    var font: Font
    
    public init(_ text: String, _ font: Font = .system(size: 17)) {
        self.text = text
        self.font = font
        self.type = .text
    }
}
