//
//  TeamsView.swift
//  ProtoConnect
//
//  Created by Krish Iyengar on 4/2/23.
//

import SwiftUI
import CoreLocation

struct TeamsView: View {
    
    @State var protoTeamInfoData: [String:Any] = [:]
    @State var teamLocationLat = 0.0
    @State var teamLocationLong = 0.0
    
    @State var showProtoTeamEnter: Bool = false
    @State var showProtoJoinEnter: Bool = false
    @State var refreshID: String = UUID().uuidString
    @State var showUnlinkConfirmAlert: Bool = false
    @State var viewRefreshID = UUID().uuidString
    var body: some View {
        
        VStack {
            if let protoTeamsNum = ProtoFirebase.currentProtoUser?.teamNum, let protoTeamsCode = ProtoFirebase.currentProtoUser?.teamCode, protoTeamsNum != "-1", protoTeamsCode != "-1" {
                VStack {
                    TeamSubView(lat: teamLocationLat, long: teamLocationLong, city: protoTeamInfoData["city"] as? String ?? "", state: protoTeamInfoData["state_prov"] as? String ?? "", venueLocationName: protoTeamInfoData["school_name"] as? String ?? "", venueAddress: "Team \(protoTeamsNum)", competitionName: "\(protoTeamInfoData["nickname"] as? String ?? "")")
                        .id(refreshID)
                    Spacer()
                    Button {
                        showUnlinkConfirmAlert = true
                    } label: {
                        Text("Unlink Team")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .frame(height: 20)
                        
                    }
                    
                    .softButtonStyle(RoundedRectangle(cornerRadius: 20), padding: 10, mainColor: Color.red, textColor: Color.white, darkShadowColor: Color.clear, lightShadowColor: Color.clear)
                    
                    .padding(.horizontal, 40)
                    .padding(.vertical)
                    
                }
                .toolbar(content: {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        ShareLink(item: "Join Team \(protoTeamsNum) on ProtoConnect with the Team Code: \(protoTeamsCode)")
                    }
                })
                
                .alert(isPresented: $showUnlinkConfirmAlert, content: {
                    Alert(title: Text("Are you sure?"), message: Text("By clicking yes, you agree to lose access to Team \(String(protoTeamsNum)) Scouting team"), primaryButton: Alert.Button.destructive(Text("Yes"), action: {
                        ProtoFirebase.removeTeamNum()
                        viewRefreshID = UUID().uuidString
                    }), secondaryButton: Alert.Button.cancel())
                })
                .onAppear {
                    
                    ProtoLookup.teamLookup(teamNumber: String(protoTeamsNum)) { protoTeamInfo in
                        protoTeamInfoData = protoTeamInfo
                        CLGeocoder().geocodeAddressString(protoTeamInfoData["city"] as? String ?? "Santa Clara") { geoPlacemarks, geoError in
                            if geoError == nil {
                                guard let geoPlacemarkFirst = geoPlacemarks?.first?.location?.coordinate else { return }
                                teamLocationLat = geoPlacemarkFirst.latitude
                                teamLocationLong = geoPlacemarkFirst.longitude
                                refreshID = UUID().uuidString
                            }
                        }
                    }
                }
                
                .navigationTitle("My Team")
            }
            else {
                VStack {
                    VStack {
                        
                        Text("Team Options")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                        HStack {
                            Button {
                                showProtoTeamEnter = true
                                
                            } label: {
                                Text("Create a Team")
                                    .bold()
                            }
                            .softButtonStyle(RoundedRectangle(cornerRadius: 20), padding: 10, mainColor: Color.blue, textColor: Color.white, darkShadowColor: Color.clear, lightShadowColor: Color.clear)
                            .padding()
                            
                            Button {
                                showProtoJoinEnter = true
                            } label: {
                                Text("Join a Team")
                                    .bold()
                            }
                            .softButtonStyle(RoundedRectangle(cornerRadius: 20), padding: 10, mainColor: Color.gray, textColor: Color.white, darkShadowColor: Color.clear, lightShadowColor: Color.clear)
                            .padding()
                        }
                        
                    }  .frame(maxWidth: .infinity)
                        .frame(height: 190)
                        .background(Color.white)
                        .cornerRadius(20)
                        .padding()
                        .shadow(radius: 2)
                        .fullScreenCover(isPresented: $showProtoTeamEnter) {
                            
                            LoginOnboardView(presentOnboard: $showProtoTeamEnter)
                        }
                        .fullScreenCover(isPresented: $showProtoJoinEnter) {
                            
                            ProtoTeamJoinCodeOnboard(presentOnboard: $showProtoJoinEnter)
                        }
                    Spacer()
                }
                
            }
            
        }
        .id(viewRefreshID)

    }
}
struct TeamSubView: View {
    
    var lat: Double
    var long: Double
    var city: String
    var state: String
    var venueLocationName: String
    var venueAddress: String
    var competitionName: String
    
    var body: some View {
        
        VStack {
            VStack {
                
                
                
                ScoutingMapView(focusedLocationCoord: CLLocationCoordinate2D(latitude: lat, longitude: long))
                    .frame(height: 240)
                
                VStack {
                    
                    
                    Text(competitionName)
                        .font(.title2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .bold()
                        .padding(.bottom, 1)
                        .foregroundColor(.black)
                    
                    
                    Text("\(city), \(state)")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(Color.Neumorphic.secondary)
                        .bold()
                    
                    Divider()
                    HStack {
                        
                        Text(venueLocationName)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .bold()
                            .foregroundColor(.black)
                        
                        Divider()
                        
                        Text(venueAddress)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .bold()
                            .foregroundColor(.black)
                        
                    }
                    
                }
                .padding()
                Spacer()
                
            }.frame(maxWidth: .infinity)
                .frame(height: 400)
                .background(Color.white)
                .cornerRadius(20)
                .padding()
                .shadow(radius: 2)
            
        }
    }
}

struct TeamsView_Previews: PreviewProvider {
    static var previews: some View {
        TeamsView()
    }
}
