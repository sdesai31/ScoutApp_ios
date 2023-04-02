//
//  ScoutignTeamLookup.swift
//  ProtoConnect
//
//  Created by Krish Iyengar on 4/1/23.
//

import SwiftUI

struct ScoutingTeamLookup: View {
    
    @State var searchBarProto: String = ""
    @State var searchBarResults: [[String:Any]] = []
    
    var body: some View {
        VStack {
            VStack {
           
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(Color.Neumorphic.secondary).font(.body).bold()
                    TextField("Search Teams", text: $searchBarProto)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 30).fill(Color.Neumorphic.main).softInnerShadow(RoundedRectangle(cornerRadius: 30), darkShadow: Color.Neumorphic.darkShadow, lightShadow: Color.Neumorphic.lightShadow, spread: 0.05, radius: 2))
                
                ScrollView {
                    ForEach(0..<searchBarResults.count, id: \.self) { oneSearchResult in
                        VStack {
                            HStack {
                                Text(searchBarResults[oneSearchResult]["name"] as? String ?? "ERROR")
                                    .font(.system(size: 23, weight: .light, design: .rounded))
                                    .foregroundColor(.black)
                                    .padding(.horizontal)
                                    .padding(.top, 10)
                                    .bold()
                                
                                Spacer()
                            }
                            Spacer()
                            
                            HStack {
                                Text("Team \(String(searchBarResults[oneSearchResult]["teamNum"] as? Int ?? -1))")
                                    .font(.system(size: 19, weight: .light, design: .rounded))
                                    .foregroundColor(Color.Neumorphic.secondary)
                                    .padding(.horizontal)
                                    .bold()
                                Spacer()
                            }
                            
                            Spacer()
                            
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(height: 80)
                        .background(Color.white)
                        .cornerRadius(20)
                        .padding()
                        .shadow(radius: 2)
                    }
                    .onChange(of: searchBarProto) { newValue in
                        if newValue.isEmpty {
                            searchBarResults.removeAll()
                        }
                        else {
                            ProtoFirebase.searchProtoTeams(teamSearch: newValue) { oneProtoDict in
                                searchBarResults = oneProtoDict
                            }
                        }
                    }
                }
            }
            .padding()
            Spacer()
        }
        .navigationTitle("Quick Lookup")
    }
}

struct ScoutingTeamLookup_Previews: PreviewProvider {
    static var previews: some View {
        ScoutingTeamLookup()
    }
}
