//
//  HomeSubpage.swift
//  ProtoConnect
//
//  Created by Krish Iyengar on 3/26/23.
//

import SwiftUI

struct HomeSubpage: View {
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    HStack {
                        Text("Scouting")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .bold()
                            .padding()
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .background(Color.Neumorphic.main)
                .cornerRadius(20)
                .padding()
                .softOuterShadow()
            }
        }
        .navigationTitle("Hey Krish")
    }
}

struct HomeSubpage_Previews: PreviewProvider {
    static var previews: some View {
        HomeSubpage()
    }
}
