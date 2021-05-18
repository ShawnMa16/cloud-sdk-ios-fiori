import FioriSwiftUICore
import SwiftUI

class InfoViewDataModel: InfoViewModel {
    var title_: String = "SAP BTP SDK for iOS"
    var descriptionText_: String? = "SAP BTP SDK for iOS enables you to quickly develop your own native apps, with Swift. The SDK extends the standard Swift Apple iOS frameworks with the reusable UI components from the SAP Fiori for iOS Design Language, and provides APIs which seamlessly integrate apps with SAP BTP services. "
    var progressIndicatorText_: String? = "Loading..."
    var actionText_: String? = "Next"
    var secondaryActionText_: String? = "Start Tutorial"
    
    func didSelectAction() {
        print("InfoView Primary button clicked")
    }
    
    func didSelectSecondaryAction() {
        print("InfoView secondary button clicked")
    }
}

struct InfoViewSample: View {
    private var model = InfoViewDataModel()
    
    public init() {
        self.model.progressIndicatorText_ = ""
    }
    
    var body: some View {
        VStack {
            InfoView(model: model)
        }
    }
}

struct InfoViewWithLoadingLabel: View {
    private var model = InfoViewDataModel()
    
    public init() {}
    
    var body: some View {
        VStack {
            InfoView(model: model)
        }
    }
}

struct InfoViewCustomized: View {
    private var model = InfoViewDataModel()
    
    public init() {
        self.model.progressIndicatorText_ = ""
    }
    
    var body: some View {
        if #available(iOS 14.0, *) {
            VStack {
                InfoView(model: model)
                    .descriptionTextModifier { $0.font(.subheadline).foregroundColor(.blue) }
                    .actionTextModifier { $0.foregroundColor(.blue) }
                    .progressIndicatorTextModifier { content in
                        content
                            .progressViewStyle(ShadowProgressViewStyle())
                    }
            }
        } else {
            VStack {
                InfoView(model: model)
                    .descriptionTextModifier { $0.font(.subheadline).foregroundColor(.blue) }
                    .actionTextModifier { $0.foregroundColor(.blue) }
                    .progressIndicatorTextModifier { $0.scaleEffect(x: 2, y: 2, anchor: .center) }
            }
        }
    }
}

@available(iOS 14.0, *)
struct ShadowProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ProgressView(configuration)
            .shadow(color: Color(red: 0, green: 0, blue: 0.4),
                    radius: 4.0, x: 1.0, y: 2.0)
            .accentColor(Color.green)
            .scaleEffect(x: 1.5, y: 1.5, anchor: .center)
    }
}

struct InfoViewSample_Previews: PreviewProvider {
    static var previews: some View {
        InfoViewSample()
    }
}