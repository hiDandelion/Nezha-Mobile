//
//  ServerDetailView.swift
//  Nezha Mobile
//
//  Created by Junhui Lou on 7/31/24.
//

import SwiftUI
import Charts

enum ServerDetailTab: String, CaseIterable, Identifiable {
    var id: String {
        self.rawValue
    }
    
    case basic = "Basic"
    case status = "Status"
    case ping = "Ping"
    
    func localized() -> String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

struct ServerDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var scheme
    var server: Server
    @State private var selectedSection: Int = 0
    @State private var activeTab: ServerDetailTab = .basic
    @StateObject private var offsetObserver = PageOffsetObserver()
    
    var body: some View {
        NavigationStack {
            VStack {
                if server.status.uptime != 0 {
                    ZStack {
                        Color(UIColor.systemGroupedBackground)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 15) {
                            Tabbar(.gray)
                                .overlay {
                                    GeometryReader {
                                        let width = $0.size.width
                                        let tabCount = CGFloat(ServerDetailTab.allCases.count)
                                        let capsuleWidth = width / tabCount
                                        let progress = offsetObserver.offset / (offsetObserver.collectionView?.bounds.width ?? 1)
                                        
                                        Capsule()
                                            .fill(scheme == .dark ? .white : .black)
                                            .frame(width: capsuleWidth)
                                            .offset(x: progress * capsuleWidth)
                                        
                                        Tabbar(scheme == .dark ? .black : .white, .semibold)
                                            .mask(alignment: .leading) {
                                                Capsule()
                                                    .frame(width: capsuleWidth)
                                                    .offset(x: progress * capsuleWidth)
                                            }
                                    }
                                    .allowsTightening(false)
                                }
                                .background(.ultraThinMaterial)
                                .clipShape(.capsule)
                                .shadow(color: .black.opacity(0.1), radius: 5, x: 5, y: 5)
                                .shadow(color: .black.opacity(0.05), radius: 5, x: -5, y: -5)
                                .padding([.horizontal, .top], 15)
                            
                            TabView(selection: $activeTab) {
                                Form {
                                    ServerDetailBasicView(server: server)
                                    ServerDetailHostView(server: server)
                                }
                                .tag(ServerDetailTab.basic)
                                .background {
                                    if !offsetObserver.isObserving {
                                        FindCollectionView {
                                            offsetObserver.collectionView = $0
                                            offsetObserver.observe()
                                        }
                                    }
                                }
                                
                                Form {
                                    ServerDetailStatusView(server: server)
                                }
                                .tag(ServerDetailTab.status)
                                
                                Form {
                                    ServerDetailPingChartView(server: server)
                                }
                                .tag(ServerDetailTab.ping)
                            }
                            .tabViewStyle(.page(indexDisplayMode: .never))
                            .animation(.easeInOut(duration: 0.3), value: activeTab)
                            .ignoresSafeArea()
                        }
                    }
                }
                else {
                    if #available(iOS 17.0, *) {
                        ContentUnavailableView("Server Unavailable", systemImage: "square.stack.3d.up.slash.fill")
                    }
                    else {
                        // ContentUnavailableView ×
                        Text("Server Unavailable")
                    }
                }
            }
            .navigationTitle(server.name)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func Tabbar(_ tint: Color, _ weight: Font.Weight = .regular) -> some View {
        HStack(spacing: 0) {
            ForEach(ServerDetailTab.allCases, id: \.rawValue) { tab in
                Text(tab.localized())
                    .font(.system(size: 14))
                    .fontWeight(weight)
                    .foregroundStyle(tint)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .contentShape(.rect)
                    .onTapGesture {
                        withAnimation(.snappy(duration: 0.3, extraBounce: 0)) {
                            activeTab = tab
                        }
                    }
            }
        }
    }
}

class PageOffsetObserver: NSObject, ObservableObject {
    @Published var collectionView: UICollectionView?
    @Published var offset: CGFloat = 0
    @Published private(set) var isObserving: Bool = false
    
    deinit {
        remove()
    }
    
    func observe() {
        guard !isObserving else { return }
        collectionView?.addObserver(self, forKeyPath: "contentOffset", context: nil)
        isObserving = true
    }
    
    func remove() {
        isObserving = false
        collectionView?.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == "contentOffset" else { return }
        if let contentOffset = (object as? UICollectionView)?.contentOffset {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.offset = contentOffset.x
            }
        }
    }
}

struct FindCollectionView: UIViewRepresentable {
    var result: (UICollectionView) -> ()
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if let collectionView = view.collectionSuperView {
                result(collectionView)
            }
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}

extension UIView {
    var collectionSuperView: UICollectionView? {
        if let collectionView = superview as? UICollectionView {
            return collectionView
        }
        
        return superview?.collectionSuperView
    }
}
