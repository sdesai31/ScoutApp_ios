//
//  HomeView.swift
//  ProtoConnect
//
//  Created by Krish Iyengar on 3/24/23.
//

import SwiftUI
import BottomBar_SwiftUI

struct HomeView: View {
    
    @State var currentProtoIndex: Int = 0
//    var protoBarViews = [AnyView(ScoutingSubpage()), AnyView(ProtoConnectSettings())]
    var protoBottomBarItems = [BottomBarItem(icon: "house", title: "Home", color: Color.blue), BottomBarItem(icon: "gear", title: "Settings", color: Color.green)]
    var body: some View {
        
        NavigationStack {
            
//            protoBarViews[currentProtoIndex]
            Spacer()
            BottomBar(selectedIndex: $currentProtoIndex, items: protoBottomBarItems)
            
        }
    
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
