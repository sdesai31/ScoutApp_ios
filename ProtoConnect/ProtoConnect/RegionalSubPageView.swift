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
import CodeScanner

struct RegionalSubPageView: View {
    
    var regionalName: String
    var location: CLLocationCoordinate2D
    var competitionKey: String
    var locationName: String
    @State var filteredProtoMatches: [[String:Any]] = []
    @State var finalAssignments: [String] = []
    @State var searchBarProto: String = ""
    @State var scouterScanner = false
    
    var body: some View {
        VStack {
            FancyScrollView(title: locationName, titleColor: Color.blue, scrollUpHeaderBehavior: .parallax) {
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
                    
                    if ProtoFirebase.isAdmin {
                        Button {
                            ProtoSheets.generateScoutingTeam(competitionKey: competitionKey)
                        } label: {
                       
                            HStack {
                              
                                Text("Generate Scouting Assignments")
                                    .foregroundColor(.black)
                                    .bold()
                            }
                            .padding(.horizontal)
                        }
                        
                        .padding(.vertical, 20)
                        .padding(.horizontal)
                        .background(RoundedRectangle(cornerRadius: 30).stroke(Color.black, lineWidth: 2).foregroundColor(.clear))
                        Button {
                            scouterScanner = true
                        } label: {
                       
                            HStack {
                              
                                Text("Scan Scouters Data")
                                    .foregroundColor(.black)
                                    .bold()
                            }
                            .padding(.horizontal)
                        }
                        
                        .padding(.vertical, 20)
                        .padding(.horizontal)
                        .background(RoundedRectangle(cornerRadius: 30).stroke(Color.black, lineWidth: 2).foregroundColor(.clear))

                    }
                    ForEach(0..<filteredProtoMatches.count, id: \.self) { oneProtoMatch in
                       
                        RegionalMatchView(matchInfo: filteredProtoMatches[oneProtoMatch], assignments: finalAssignments)

                        

                    }
                }
                .padding()
            }
            
        }
        .sheet(isPresented: $scouterScanner, content: {
            CodeScannerView(codeTypes: [.qr], scanMode: .once) { scanResult in
                do {
                    let codeScanned = try scanResult.get().string
                    var codeComps = codeScanned.components(separatedBy: ";")
                    let matchNum = codeComps.removeFirst()
                    let teamNum = codeComps.removeFirst()
                    ProtoSheets.setRowDataTeamNumber(data: codeComps, matchNumber: matchNum, teamNumber: teamNum)
                }
                catch {
                    print(error)
                }
            }
        })
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
            if ProtoFirebase.isAdmin {
                ProtoLookup.teamCompetitionMatches(competitionKey: competitionKey) { allProtoMatches in
                    filteredProtoMatches = allProtoMatches
                }
            }
            else {
                guard let myID = ProtoFirebase.currentProtoUser?.id else { return }
                ProtoSheets.getTeamScoutingAssignments { assignments in
                    let myAssignments = assignments.filter { oneAssignment in
                        return oneAssignment.contains(myID)
                    }
                    finalAssignments = myAssignments
                    
                    ProtoLookup.teamCompetitionMatches(competitionKey: competitionKey) { allProtoMatches in
                        filteredProtoMatches = allProtoMatches.filter({ oneMatch in
                            if let matchNumber = ((oneMatch["match_number"] as? Int)) {
                                if (myAssignments.contains(where: { oneString in
                                    return (oneString.components(separatedBy: " ").last ?? "error") == ("Match\(matchNumber)")
                                })) {
                                    return true
                                }
                            }
                            return false
                        })
                        
                    }
                }
            }
        }
    }
}

struct RegionalMatchView: View {
    
    var matchInfo: [String:Any]
    var assignments: [String]
    
    var body: some View {
        
        if var blueAlliance = ((matchInfo["alliances"] as? [String:Any])?["blue"] as? [String:Any])?["team_keys"] as? [String], var redAlliance = ((matchInfo["alliances"] as? [String:Any])?["red"] as? [String:Any])?["team_keys"] as? [String], let blueAllianceScore = ((matchInfo["alliances"] as? [String:Any])?["blue"] as? [String:Any])?["score"] as? Int, let redAllianceScore = ((matchInfo["alliances"] as? [String:Any])?["red"] as? [String:Any])?["score"] as? Int, let regionalKey = ((matchInfo["event_key"] as? String)) {
            
            NavigationLink(destination: {
                if let matchNumber = (((matchInfo["match_number"])) as? Int), let myID = ProtoFirebase.currentProtoUser?.id {
                    var teamAssignment = (assignments.filter { teamNum in
                        return (teamNum.components(separatedBy: " ").last ?? "error") == ("Match\(matchNumber)")
                    }).map { oneString in
                        return oneString.replacingOccurrences(of: myID, with: "").trimmingCharacters(in: .whitespaces).components(separatedBy: " ").first ?? "error"
                    }
                    
                    RegionalSubPageScoutingDataView(redTeams: redAlliance, blueTeams: blueAlliance, regionalKey: regionalKey, matchNumber: String(matchNumber), assignments: teamAssignment)
                    
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
