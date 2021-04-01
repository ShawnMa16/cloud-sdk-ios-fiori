import Foundation
import SwiftUI

struct GridTableView: View {
    @Environment(\.layoutDirection) var layoutDirection
    
    @EnvironmentObject var layoutManager: TableLayoutManager
    @EnvironmentObject var dataManager: TableDataManager
    
    @State var lastScaleX: CGFloat = 1.0
    @State var lastScaleY: CGFloat = 1.0
    @State var lastCenterPosition: CGPoint? = nil
    
    @State var dropVerticalShadow: Bool = false
    @State var dropHorizontalShadow: Bool = false
    
    var body: some View {
        GeometryReader { proxy in
            self.makeBody(in: proxy.frame(in: .local))
        }
    }
    
    func makeBody(in rect: CGRect) -> some View {
        let items: [[TableDataItem]] = self.layoutManager.dataItemsForTable(rect: rect)
        
        let drag = DragGesture()
            .onChanged { value in
                let scaleX = self.layoutManager.scaleX(rect: rect)
                let scaleY = self.layoutManager.scaleY(rect: rect)
                
                var tmpLastCenterPosition: CGPoint
                if let tmpPosition = self.lastCenterPosition {
                    tmpLastCenterPosition = tmpPosition
                } else {
                    tmpLastCenterPosition = self.layoutManager.centerPosition(rect: rect)
                    self.lastCenterPosition = tmpLastCenterPosition
                }
                
                let tmpX = self.layoutDirection == .leftToRight ? (tmpLastCenterPosition.x * scaleX * rect.size.width - value.translation.width) / (scaleX * rect.size.width) : (tmpLastCenterPosition.x * scaleX * rect.size.width + value.translation.width) / (scaleX * rect.size.width)
                let x = max(0.5 / scaleX, min(1 - 0.5 / scaleX, tmpX))
                
                let tmpY = (tmpLastCenterPosition.y * scaleY * rect.size.height - value.translation.height) / (scaleY * rect.size.height)
                let y = max(0.5 / scaleY, min(1 - 0.5 / scaleY, tmpY))
                
                self.layoutManager.centerPosition = CGPoint(x: self.layoutManager.horizontalScrolling ? x : 0, y: y)
                
                self.dropVerticalShadow = self.layoutManager.startPosition(rect: rect).x != 0
                self.dropHorizontalShadow = self.layoutManager.startPosition(rect: rect).y != 0
            }
            .onEnded { _ in
                self.lastCenterPosition = self.layoutManager.centerPosition(rect: rect)
            }
        
        // zoom in & out
        let mag = MagnificationGesture()
            .onChanged { value in
                self.layoutManager.scaleX = max(0.5, self.lastScaleX * value.magnitude)
                self.layoutManager.scaleY = max(0.5, self.lastScaleY * value.magnitude)
                
                self.layoutManager.centerPosition = self.layoutManager.centerPosition(rect: rect)
            }
            .onEnded { _ in
                self.lastScaleX = self.layoutManager.scaleX
                self.lastScaleY = self.layoutManager.scaleY
            }
        
        return
            ZStack {
                ForEach(0 ..< items.count, id: \.self) { i in
                    
                    let isHeader: Bool = i == 0 && !self.layoutManager.model.headerData.isEmpty
                    
                    ForEach(0 ..< items[i].count, id: \.self) { j in
                        let currentItem = items[i][j]
                        let view = ItemView(currentItem, (i, j), isHeader, dropShadow: self.dropVerticalShadow)
                        let x = currentItem.pos.x
                        let y = currentItem.pos.y
                        let zIndex: Double = (i, j) == (0, 0) ? 700 : Double(600 - i * j)
                        view
                            .position(x: x, y: y)
                            .offset(x: currentItem.offset.x * self.layoutManager.scaleX, y: currentItem.offset.y * self.layoutManager.scaleY)
                            .zIndex(zIndex)
                    }
                    
                    if let leadingItem = items[i].first {
                        let currentIndex = leadingItem.rowIndex

                        let lAccessoriess: [AccessoryItem] = self.dataManager.rowData[currentIndex].leadingAccessories
                        let tAccessory: AccessoryItem? = currentIndex < 0 ? nil : self.dataManager.rowData[currentIndex].trailingAccessory
                        let leadingMargin = lAccessoriess.count == 0 ? 0 : TableViewLayout.accessoryViewLeadingMargin(width: rect.width, sizeClass: self.layoutManager.sizeClass)
                        
                        let y = leadingItem.pos.y == 0 ? leadingItem.offset.y : leadingItem.pos.y
                        
                        LeadingAccessoryView(items: lAccessoriess, index: currentIndex, isHeader: isHeader)
                            .position(x: rect.minX, y: y)
                            .padding(.leading, leadingMargin)
                            .zIndex(Double(800 - currentIndex))

                        TrailingAccessoryView(item: tAccessory, rowIndex: currentIndex)
                            .position(x: rect.maxX, y: y)
                        
                        horizontalDivider(rect: rect, pos: leadingItem.pos, rowHeight: leadingItem.rowHeight, index: i)
                            .zIndex(Double(900 - currentIndex))
                    }
                }
            }
            .gesture(drag)
            .gesture(mag)
    }
    
    func horizontalDivider(rect: CGRect, pos: CGPoint, rowHeight: CGFloat, index: Int) -> some View {
        let offetY = pos.y == 0 ? rowHeight : (rowHeight / 2)
        return
            Divider()
                .frame(width: rect.size.width)
                .position(x: rect.size.width / 2, y: pos.y)
                .offset(y: offetY * self.layoutManager.scaleY)
                .dropShadow(isVertical: false, show: index == 0 && self.dropHorizontalShadow)
    }
}
