//
//  AnimatedTabView.swift
//  AnimatedTabBar
//
//  Created by Balaji Venkatesh on 02/12/25.
//

import SwiftUI

protocol AnimatedTabSelectionProtocol: CaseIterable, Hashable {
    var title: String { get }
    var systemName: String { get }
}

@available(iOS 18.0, *)
struct AnimatedTabView<Selection: AnimatedTabSelectionProtocol, Content: TabContent<Selection>>: View {
    @Binding var selection: Selection
    @TabContentBuilder<Selection> var content: () -> Content
    var effects: (Selection) -> [any DiscreteSymbolEffect & SymbolEffect]
    @State private var imageViews: [Selection: UIImageView] = [:]
    
    var body: some View {
        TabView(selection: $selection) {
            content()
        }
        .tabViewStyle(.tabBarOnly)
        .background(ExtractImageViewsFromTabView {
            imageViews = $0
        })
        .compositingGroup()
        .onChange(of: selection) { oldValue, newValue in
            guard let imageView = imageViews[newValue] else { return }
            let symbolEffects = effects(newValue)
            
            for effect in symbolEffects {
                imageView.addSymbolEffect(effect, options: .nonRepeating)
            }
        }
    }
}

fileprivate struct ExtractImageViewsFromTabView<Value: AnimatedTabSelectionProtocol>: UIViewRepresentable {
    var result: ([Value: UIImageView]) -> ()
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        
        DispatchQueue.main.async {
            if let compostingGroup = view.superview?.superview {
                guard let tabHostingController = compostingGroup.subviews.last else { return }
                guard let tabController = tabHostingController.subviews.first?.next as? UITabBarController else { return }
                
                extractImageViews(tabController.tabBar)
            }
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {  }
    
    private func extractImageViews(_ tabBar: UITabBar) {
        let imageViews = tabBar.subviews(type: UIImageView.self)
            .filter({ $0.image?.isSymbolImage ?? false })
            .filter({ isiOS26 ? ($0.tintColor == tabBar.tintColor) : true })
        
        var dict: [Value: UIImageView] = [:]
        
        for tab in Value.allCases {
            if let imageView = imageViews.first(where: {
                /// Finding the associated image using the symbol name
                $0.description.contains(tab.systemName)
            }) {
                dict[tab] = imageView
            }
        }
        
        result(dict)
    }
    
    private var isiOS26: Bool {
        if #available(iOS 26, *) {
            return true
        }
        
        return false
    }
}

fileprivate extension UIView {
    func subviews<T: UIView>(type: T.Type) -> [T] {
        subviews.compactMap { $0 as? T } +
        subviews.flatMap { $0.subviews(type: type) }
    }
}
