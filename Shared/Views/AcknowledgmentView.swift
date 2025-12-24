//
//  AcknowledgmentView.swift
//  Nezha Desktop
//
//  Created by Junhui Lou on 9/5/24.
//

import SwiftUI

extension NMUI {
    struct AcknowledgmentView: View {
        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("This project is subject to\nApache License\nVersion 2.0, January 2004\nhttps://www.apache.org/licenses/")
                    Text("Part of this project is related to Project nezhahq/nezha which is subject to\nApache License\nVersion 2.0, January 2004\nhttps://www.apache.org/licenses/")
                    Text("This project has dependency hyperoslo/Cache which is subject to\nMIT License")
                    Text("This project has dependency evgenyneu/keychain-swift which is subject to\nMIT License")
                    Text("This project has dependency SwiftyJSON/SwiftyJSON which is subject to\nMIT License")
                    Text("Intel logo is a trademark of Intel Corporation. AMD logo is a trademark of Advanced Micro Devices, Inc. ARM logo is a trademark of Arm Limited. Windows logo is a trademark of Microsoft Inc. Apple logo, iOS logo and macOS logo are trademarks of Apple Inc.")
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
            .navigationTitle("Acknowledgments")
#if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .padding()
        }
    }
}
