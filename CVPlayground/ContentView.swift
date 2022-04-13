//
//  ContentView.swift
//  CVPlayground
//
//  Created by Noah Pikielny on 4/12/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MetalView(
            frame: CGRect(x: 0, y: 0, width: 512, height: 512),
            shader: ResourcelessShader.UVShader()!
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
