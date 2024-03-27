//
//  ScoutingSubpage.swift
//  ProtoConnect
//
//  Created by Krish Iyengar on 3/26/23.
//

import SwiftUI
import MapKit
import CoreLocation
import ActivityIndicatorView

struct ScoutingSubpage: View {
    
    @State var showProtoTeamEnter: Bool = false
    @State var showProtoJoinEnter: Bool = false
    let protoLocationInputDateFormatter: DateFormatter = {
        let tempDateOutputFormatter = DateFormatter()
        tempDateOutputFormatter.dateFormat = "yyyy-MM-dd"

        return tempDateOutputFormatter
    }()
    let protoLocationOutputDateFormatter: DateFormatter = {
        let tempDateInputFormatter = DateFormatter()
        tempDateInputFormatter.timeStyle = .none
        tempDateInputFormatter.dateFormat = "MMM d"
        return tempDateInputFormatter
    }()
 
    @State var shouldShowLoadedSpinner: Bool = true
    @State var showScoutingSettings: Bool = false
    
    @State var refreshID: String = UUID().uuidString
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    
                    ScrollView {
                        
                        if (shouldShowLoadedSpinner) {
                            if ((ProtoFirebase.currentProtoUser?.teamNum ?? "-1") == "-1") {
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
                            }
                            else {
                                VStack {
                                    Text("Loading...")
                                        .font(.headline)
                                    ActivityIndicatorView(isVisible: $shouldShowLoadedSpinner, type: .arcs(count: 3, lineWidth: 2))
                                        .frame(width: 50, height: 50)
                                }
                            }
                        }
                        
                        
                      
                        ForEach(0..<ProtoLookup.teamCompetitionsInfo.count, id: \.self) { i in
                            
                            
                            if let teamNameCompetitionValueLat = ProtoLookup.teamCompetitionsInfo[i].keys.firstIndex(of: "lat"), let teamNameCompetitionValueLong = ProtoLookup.teamCompetitionsInfo[i].keys.firstIndex(of: "lng"), let teamCompetitionInfoCoordinateLat = ProtoLookup.teamCompetitionsInfo[i].values[teamNameCompetitionValueLat] as? Double, let teamCompetitionInfoCoordinateLong = ProtoLookup.teamCompetitionsInfo[i].values[teamNameCompetitionValueLong] as? Double, let teamNameCompetitionValue = ProtoLookup.teamCompetitionsInfo[i].keys.firstIndex(of: "name"), let teamCompetitionInfo = ProtoLookup.teamCompetitionsInfo[i].values[teamNameCompetitionValue] as? String, let teamNameCompetitionValueCity = ProtoLookup.teamCompetitionsInfo[i].keys.firstIndex(of: "city"), let teamCompetitionInfoCity = ProtoLookup.teamCompetitionsInfo[i].values[teamNameCompetitionValueCity] as? String, let teamNameCompetitionValueState = ProtoLookup.teamCompetitionsInfo[i].keys.firstIndex(of: "state_prov"), let teamCompetitionInfoState = ProtoLookup.teamCompetitionsInfo[i].values[teamNameCompetitionValueState] as? String, let teamNameCompetitionLocationNameValue = ProtoLookup.teamCompetitionsInfo[i].keys.firstIndex(of: "location_name"), let teamCompetitionLocationNameInfo = ProtoLookup.teamCompetitionsInfo[i].values[teamNameCompetitionLocationNameValue] as? String, let teamNameCompetitionLocationNameAddress = ProtoLookup.teamCompetitionsInfo[i].keys.firstIndex(of: "address"), let teamCompetitionLocationNameAddress = ProtoLookup.teamCompetitionsInfo[i].values[teamNameCompetitionLocationNameAddress] as? String, let teamNameCompetitionLocationWeekNumber = ProtoLookup.teamCompetitionsInfo[i].keys.firstIndex(of: "week"), let teamCompetitionLocationWeek = ProtoLookup.teamCompetitionsInfo[i].values[teamNameCompetitionLocationWeekNumber] as? Int, let teamNameCompetitionLocationStartDate = ProtoLookup.teamCompetitionsInfo[i].keys.firstIndex(of: "start_date"), let teamCompetitionStartDateValue = ProtoLookup.teamCompetitionsInfo[i].values[teamNameCompetitionLocationStartDate] as? String, let teamNameCompetitionLocationEndDate = ProtoLookup.teamCompetitionsInfo[i].keys.firstIndex(of: "end_date"), let teamCompetitionEndDateValue = ProtoLookup.teamCompetitionsInfo[i].values[teamNameCompetitionLocationEndDate] as? String, let teamNameCompetitionEventCode = ProtoLookup.teamCompetitionsInfo[i].keys.firstIndex(of: "event_code"), let teamCompetitionEventCode = ProtoLookup.teamCompetitionsInfo[i].values[teamNameCompetitionEventCode] as? String {
                                
                                if let tempDateStart = protoLocationInputDateFormatter.date(from: teamCompetitionStartDateValue), let tempDateEnd = protoLocationInputDateFormatter.date(from: teamCompetitionEndDateValue) {
                                    
                                    
                                    
                                    NavigationLink {
                                        RegionalSubPageView(regionalName: teamCompetitionInfo, location: CLLocationCoordinate2D(latitude: teamCompetitionInfoCoordinateLat, longitude: teamCompetitionInfoCoordinateLong), competitionKey: teamCompetitionEventCode, locationName: teamCompetitionLocationNameInfo)
                                    } label: {
                                        
                                        ScoutingSubRegionalsView(lat: teamCompetitionInfoCoordinateLat, long: teamCompetitionInfoCoordinateLong, weekNumber: teamCompetitionLocationWeek, competitionName: teamCompetitionInfo, city: teamCompetitionInfoCity, state: teamCompetitionInfoState, venueLocationName: teamCompetitionLocationNameInfo, venueAddress: teamCompetitionLocationNameAddress, startDate: protoLocationOutputDateFormatter.string(from: tempDateStart), endDate: protoLocationOutputDateFormatter.string(from: tempDateEnd))
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }
                    }
                    
                }
                
                
                
            }
            .fullScreenCover(isPresented: $showProtoTeamEnter) {
                
                LoginOnboardView(presentOnboard: $showProtoTeamEnter)
            }
            .fullScreenCover(isPresented: $showProtoJoinEnter) {
                
                ProtoTeamJoinCodeOnboard(presentOnboard: $showProtoJoinEnter)
            }
            .id(refreshID)
            .onAppear {
                if (ProtoLookup.teamCompetitionsInfo.isEmpty) {
                    shouldShowLoadedSpinner = true
                    ProtoLookup.teamCompetitionKey { didFinishLookup in
                        if didFinishLookup {
                            shouldShowLoadedSpinner = false
                        }
                    }
                }
                else {
                    shouldShowLoadedSpinner = false
                }
            }
            .toolbar(content: {
                ToolbarItem {
                    Button {
                        showScoutingSettings = true
                    } label: {
                        Image(systemName: "gear.circle.fill")
                            .foregroundColor(Color.black)
                    }

                }
            })
            .sheet(isPresented: $showScoutingSettings, content: {
                ProtoConnectSettings(logOutProtoConnect: $showScoutingSettings)
            })
            .onChange(of: showProtoJoinEnter, perform: { newValue in
                if !newValue {
                    refreshID = UUID().uuidString

                }
            })
            .onChange(of: showProtoTeamEnter, perform: { newValue in
                if !newValue {
                    refreshID = UUID().uuidString

                }
            })
            .onChange(of: showScoutingSettings, perform: { newValue in
                if !newValue {
                    refreshID = UUID().uuidString
                }
            })
            .navigationTitle("Scouting")
        }
    }
}

struct ScoutingSubpage_Previews: PreviewProvider {
    static var previews: some View {
        ScoutingSubpage()
    }
}

struct ScoutingSubRegionalsView: View {
    
    var lat: Double
    var long: Double
    var weekNumber: Int
    var competitionName: String
    var city: String
    var state: String
    var venueLocationName: String
    var venueAddress: String
    var startDate: String
    var endDate: String
    
    var body: some View {
        
        VStack {
            VStack {
                
                
                
                ScoutingMapView(focusedLocationCoord: CLLocationCoordinate2D(latitude: lat, longitude: long))
                    .frame(height: 240)
                    .overlay {
                        VStack {
                            HStack {
                             
                                    Text("Week \(weekNumber)")
                                        .font(.system(size: 18, weight: .light, design: .rounded))
                                        .foregroundColor(.white)
                                        .padding(.horizontal)
                                        .padding(.vertical, 5)
                                        .bold()
                                        .background(Color.blue)
                                        .cornerRadius(20)
                                        
                                
                                .padding()
                                Spacer()
                                Text("\(startDate) - \(endDate)")
                                    .font(.system(size: 18, weight: .light, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                    .padding(.vertical, 5)
                                    .bold()
                                    .background(Color.blue)
                                    .cornerRadius(20)
                                    
                            .padding()
                            }
                            Spacer()
                            
                        }
                        
                    }
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
struct ScoutingMapView: UIViewRepresentable {
    
    let focusedLocationCoord: CLLocationCoordinate2D
    let scoutMapView = MKMapView(frame: .zero)
    
    func makeUIView(context: Context) -> MKMapView {
        scoutMapView.isUserInteractionEnabled = false
        return scoutMapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        scoutMapView.region = MKCoordinateRegion(center: focusedLocationCoord, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        
    }
    
    typealias UIViewType = MKMapView
    
    
}
