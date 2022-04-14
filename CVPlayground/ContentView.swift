//
//  ContentView.swift
//  CVPlayground
//
//  Created by Noah Pikielny on 4/12/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MetalView(frame: .zero) { view in
            EdgeShader.edgeShader(radius: 1, view: view)!
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
