//
//  RegionalSubPageView.swift
//  ProtoConnect
//
//  Created by Krish Iyengar on 3/27/23.
//

import SwiftUI
import FancyScrollView
import MapKit
import CoreLocation

struct RegionalSubPageView: View {
    
    var regionalName: String
    var location: CLLocationCoordinate2D
    var competitionKey: String
    var locationName: String
    @State var filteredProtoMatches: [[String:Any]] = []
    
    @State var searchBarProto: String = ""
    
    var body: some View {
        VStack {
            FancyScrollView(title: locationName, titleColor: Color.black, scrollUpHeaderBehavior: .parallax) {
                ScoutingMapView(focusedLocationCoord: location)
                    .padding(.bottom, -25)
            } content: {
                VStack {
                    Text(regionalName)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(Color.Neumorphic.secondary).font(.body).bold()
                        TextField("Search Matches", text: $searchBarProto)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 30).fill(Color.Neumorphic.main).softInnerShadow(RoundedRectangle(cornerRadius: 30), darkShadow: Color.Neumorphic.darkShadow, lightShadow: Color.Neumorphic.lightShadow, spread: 0.05, radius: 2))

                    ForEach(0..<filteredProtoMatches.count, id: \.self) { oneProtoMatch in
                       
                            RegionalMatchView(matchInfo: filteredProtoMatches[oneProtoMatch])

                        

                    }
                }
                .padding()
            }
            
        }
        .onChange(of: searchBarProto, perform: { newValue in
            if newValue.isEmpty {
                filteredProtoMatches = ProtoLookup.specificCompProtoMatches
                return 
            }
            filteredProtoMatches = ProtoLookup.specificCompProtoMatches.filter { oneProtoMatch in
                if let blueAlliance = ((oneProtoMatch["alliances"] as? [String:Any])?["blue"] as? [String:Any])?["team_keys"] as? [String], let redAlliance = ((oneProtoMatch["alliances"] as? [String:Any])?["red"] as? [String:Any])?["team_keys"] as? [String], let matchNumber = ((oneProtoMatch["match_number"] as? Int)) {
                    
                    if ((blueAlliance.contains(where: { oneTeam in
                        if "team \(oneTeam.replacingOccurrences(of: "frc", with: ""))".contains(newValue.lowercased()) {
                            return true
                        }
                        return false
                    })) || redAlliance.contains(where: { oneTeam in
                        if "team \(oneTeam.replacingOccurrences(of: "frc", with: ""))".contains(newValue.lowercased()) {
                            return true
                        }
                        return false
                    }) || "qualification \(matchNumber)".contains("\(newValue.lowercased())")) {
                        return true
                    }
                    
                }
                    return false
                
            }
        })
        .onAppear {
            ProtoLookup.teamCompetitionMatches(competitionKey: competitionKey) { allProtoMatches in
                filteredProtoMatches = allProtoMatches
                
            }
        }
    }
}

struct RegionalMatchView: View {
    
    var matchInfo: [String:Any]
    
    
    var body: some View {
        
        if let blueAlliance = ((matchInfo["alliances"] as? [String:Any])?["blue"] as? [String:Any])?["team_keys"] as? [String], let redAlliance = ((matchInfo["alliances"] as? [String:Any])?["red"] as? [String:Any])?["team_keys"] as? [String], let blueAllianceScore = ((matchInfo["alliances"] as? [String:Any])?["blue"] as? [String:Any])?["score"] as? Int, let redAllianceScore = ((matchInfo["alliances"] as? [String:Any])?["red"] as? [String:Any])?["score"] as? Int, let regionalKey = ((matchInfo["event_key"] as? String)) {
            
            NavigationLink(destination: {
                if let matchNumber = (((matchInfo["match_number"])) as? Int) {
                    RegionalSubPageScoutingDataView(redTeams: redAlliance, blueTeams: blueAlliance, regionalKey: regionalKey, matchNumber: String(matchNumber))
                }
            }, label: {
                VStack {
                    if let matchNumber = ((matchInfo["match_number"] as? Int)) {
                        Text("Qualification \(matchNumber)")
                            .font(.system(size: 23, weight: .bold, design: .rounded))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding([.top, .horizontal])
                            .foregroundColor(.black)
                        HStack {
                            
                            
                            
                            VStack {
                                Text("\(redAllianceScore) Points")
                                    .font(.system(size: 23, weight: .light, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                    .padding(.vertical, 5)
                                    .bold()
                                    .background(Color.red)
                                    .cornerRadius(20)
                                
                                Divider()
                                
                                ForEach(redAlliance, id: \.self) { oneTeam in
                                    
                                    
                                    Text("Team " + oneTeam.replacingOccurrences(of: "frc", with: ""))
                                        .font(.system(size: 18, weight: oneTeam == "frc\(ProtoFirebase.currentProtoUser?.teamNum ?? "-1")" ? .bold : .light, design: .rounded))
                                        .foregroundColor(.white)
                                        .padding(.horizontal)
                                        .padding(.vertical, 5)
                                        .bold()
                                        .background(Color.red)
                                        .cornerRadius(20)
                                }
                            }
                            Divider()
                            VStack {
                                Text("\(blueAllianceScore) Points")
                                    .font(.system(size: 23, weight: .light, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                    .padding(.vertical, 5)
                                    .bold()
                                    .background(Color.blue)
                                    .cornerRadius(20)
                                Divider()
                                ForEach(blueAlliance, id: \.self) { oneTeam in
                                    Text("Team " + oneTeam.replacingOccurrences(of: "frc", with: ""))
                                        .font(.system(size: 18, weight: .light, design: .rounded))
                                        .foregroundColor(.white)
                                        .padding(.horizontal)
                                        .padding(.vertical, 5)
                                        .bold()
                                        .background(Color.blue)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 240)
                .background(Color.white)
                .cornerRadius(20)
                .padding()
                .shadow(radius: 2)
            })
        }
    }
}


struct RegionalSubPageView_Previews: PreviewProvider {
    static var previews: some View {
        RegionalSubPageView(regionalName: "Silicon Valley Regional", location: CLLocationCoordinate2D(), competitionKey: "2023casf", locationName: "San Jose State University")
    }
}
