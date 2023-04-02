//
//  RegionalSubPageScoutingDataView.swift
//  ProtoConnect
//
//  Created by Krish Iyengar on 3/28/23.
//

import SwiftUI
import Neumorphic
import FirebaseFirestore

struct RegionalSubPageScoutingDataView: View {
    
    @State var redTeams: [String]
    @State var blueTeams: [String]
    @State var currentSelectedTeam: String = ""
    @State var regionalKey: String
    @State var matchKey: String
    
    @State var highConesStepper: Int = 0
    @State var midConesStepper: Int = 0
    @State var lowConesStepper: Int = 0
    @State var highCubesStepper: Int = 0
    @State var midCubesStepper: Int = 0
    @State var lowCubesStepper: Int = 0
    
    @State var robotTaxi: Bool = false
    
    @State var robotEngaged: Bool = false
    @State var robotDocked: Bool = false
    
    @State var currentPlayType: String = "auto"
    
    var body: some View {
            ScrollView {
                
                HStack {
                    Text("Team \(currentSelectedTeam.replacingOccurrences(of: "frc", with: ""))")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(Color.black)
                        .padding()
                        
                   
                    
                    Spacer()
                }
                VStack {
                    Picker("", selection: $currentSelectedTeam) {
                        ForEach(redTeams, id: \.self) { oneRedTeam in
                            Text(oneRedTeam.replacingOccurrences(of: "frc", with: ""))
                                .foregroundColor(.red)
                                .font(.headline)
                                .bold()
                                .tag(oneRedTeam)
                        }
                        ForEach(blueTeams, id: \.self) { oneBlueTeam in
                            Text(oneBlueTeam.replacingOccurrences(of: "frc", with: ""))
                                .foregroundColor(.blue)
                                .font(.headline)
                                .bold()
                                .tag(oneBlueTeam)
                        }
                    }
                    .onChange(of: currentSelectedTeam) { newValue in
                        guard let teamNumber = ProtoFirebase.currentProtoUser?.teamNum else {
                            return
                        }
                        ProtoFirebase.teamCollection.document("\(teamNumber)").collection(regionalKey).document(matchKey).collection(newValue).document(currentPlayType).addSnapshotListener { oneDocSnapshot, oneDocError in
                            updateRegionalData()
                        }
                    }

                    Picker("", selection: $currentPlayType) {
                        
                            Text("Auto")
                                .foregroundColor(.blue)
                                .font(.headline)
                                .bold()
                                .tag("auto")
                        Text("Teleoperated")
                            .foregroundColor(.blue)
                            .font(.headline)
                            .bold()
                            .tag("teleoperated")
                    }
                    .onChange(of: currentPlayType) { newValue in
                        guard let teamNumber = ProtoFirebase.currentProtoUser?.teamNum else {
                            return
                        }
                        ProtoFirebase.teamCollection.document("\(teamNumber)").collection(regionalKey).document(matchKey).collection(currentSelectedTeam).document(newValue).addSnapshotListener { oneDocSnapshot, oneDocError in
                            updateRegionalData()
                        }
                    }
                  
                    
                }
                .padding()
                .pickerStyle(.segmented)
                .frame(maxWidth: .infinity)
                .frame(height: 90)
                .background(redTeams.contains(currentSelectedTeam) ? Color.red : Color.blue)
                .cornerRadius(20)
                .padding()
                .softOuterShadow()
                
                VStack {
                    HStack {
                        Text("Cubes")
                            .font(.system(size: 25, weight: .bold, design: .rounded))
                            .bold()
                            .foregroundColor(Color.black)
                            .padding()
                        
                        
                        Spacer()
                    }
                    VStack {
                        VStack {
                            
                            Stepper {
                                Text("\(highCubesStepper) High Cubes")
                                    .bold()
                            } onIncrement: {
                                highCubesStepper += 1
                            } onDecrement: {
                                if (highCubesStepper > 0) {
                                    highCubesStepper -= 1
                                }
                            } onEditingChanged: { oneEditing in
                               
                            }
                            .padding(.horizontal)
                            .onChange(of: highCubesStepper, perform: { newValue in
                                ProtoFirebase.uploadCompetitionKeyMatch(playType: currentPlayType, regionalKey: regionalKey, matchKey: matchKey, teamNum: currentSelectedTeam, dataKey: "highCubes", dataValue: String(newValue))
                                
                            })
                            
                        }

                        Spacer()
                        VStack {
                            
                            Stepper {
                                Text("\(midCubesStepper) Middle Cubes")
                                    .bold()
                            } onIncrement: {
                                midCubesStepper += 1
                            } onDecrement: {
                                if (midCubesStepper > 0) {
                                    midCubesStepper -= 1
                                }
                            } onEditingChanged: { oneEditing in
                                
                            }
                            .onChange(of: midCubesStepper, perform: { newValue in
                                ProtoFirebase.uploadCompetitionKeyMatch(playType: currentPlayType, regionalKey: regionalKey, matchKey: matchKey, teamNum: currentSelectedTeam, dataKey: "midCubes", dataValue: String(newValue))
                            })
                            
                        }
                        .padding(.horizontal)
                        Spacer()
                        VStack {
                            
                            Stepper {
                                Text("\(lowCubesStepper) Hybrid Cubes")
                                    .bold()
                            } onIncrement: {
                                lowCubesStepper += 1
                            } onDecrement: {
                                if (lowCubesStepper > 0) {
                                    lowCubesStepper -= 1
                                }
                            } onEditingChanged: { oneEditing in
                                
                            }
                            .onChange(of: lowCubesStepper, perform: { newValue in
                                ProtoFirebase.uploadCompetitionKeyMatch(playType: currentPlayType, regionalKey: regionalKey, matchKey: matchKey, teamNum: currentSelectedTeam, dataKey: "hybridCubes", dataValue: String(newValue))
                            })
                            
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom)
                    Spacer()
                }.frame(maxWidth: .infinity)
                    .frame(height: 230)
                    .background(LinearGradient(colors: [Color(red: 0.55, green: 0.78, blue: 0.93), Color(red: 0.58, green: 0.6, blue: 0.89)], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(20)
                    .padding()
                    .shadow(radius: 2)
                VStack {
                    HStack {
                        Text("Cones")
                            .font(.system(size: 25, weight: .bold, design: .rounded))
                            .bold()
                            .foregroundColor(Color.black)
                            .padding()
                        
                        
                        Spacer()
                    }
                    VStack {
                        VStack {
                            
                            Stepper {
                                Text("\(highConesStepper) High Cones")
                                    .bold()
                            } onIncrement: {
                                highConesStepper += 1
                            } onDecrement: {
                                if (highConesStepper > 0) {
                                    highConesStepper -= 1
                                }
                            } onEditingChanged: { oneEditing in
                                
                            }
                            .padding(.horizontal)
                            .onChange(of: highConesStepper, perform: { newValue in
                                ProtoFirebase.uploadCompetitionKeyMatch(playType: currentPlayType, regionalKey: regionalKey, matchKey: matchKey, teamNum: currentSelectedTeam, dataKey: "highCones", dataValue: String(newValue))
                            })
                            
                        }

                        Spacer()
                        VStack {
                            
                            Stepper {
                                Text("\(midConesStepper) Middle Cones")
                                    .bold()
                            } onIncrement: {
                                midConesStepper += 1
                            } onDecrement: {
                                if (midConesStepper > 0) {
                                    midConesStepper -= 1
                                }
                            } onEditingChanged: { oneEditing in
                                
                            }

                            
                        }
                        .padding(.horizontal)
                        .onChange(of: midConesStepper, perform: { newValue in
                            ProtoFirebase.uploadCompetitionKeyMatch(playType: currentPlayType, regionalKey: regionalKey, matchKey: matchKey, teamNum: currentSelectedTeam, dataKey: "midCones", dataValue: String(newValue))
                        })
                        Spacer()
                        VStack {
                            
                            Stepper {
                                Text("\(lowConesStepper) Hybrid Cones")
                                    .bold()
                            } onIncrement: {
                                lowConesStepper += 1
                            } onDecrement: {
                                if (lowConesStepper > 0) {
                                    lowConesStepper -= 1
                                }
                            } onEditingChanged: { oneEditing in
                                
                            }

                            
                        }
                        .padding(.horizontal)
                        .onChange(of: lowConesStepper, perform: { newValue in
                            ProtoFirebase.uploadCompetitionKeyMatch(playType: currentPlayType, regionalKey: regionalKey, matchKey: matchKey, teamNum: currentSelectedTeam, dataKey: "lowCones", dataValue: String(newValue))
                        })
                    }
                    .padding(.bottom)
                    Spacer()
                }.frame(maxWidth: .infinity)
                    .frame(height: 230)
                    .background(LinearGradient(colors: [Color(red: 0.97, green: 0.81, blue: 0.41), Color(red: 0.98, green: 0.67, blue: 0.49)], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(20)
                    .padding()
                    .shadow(radius: 2)
                
                VStack {
                        
                    if !robotDocked {
                        
                        VStack {
                            Toggle(isOn: $robotEngaged) {
                                Text("Engaged")
                                    .font(.system(size: 23, weight: .bold, design: .rounded))
                                    .bold()
                                    .foregroundColor(Color.black)
                                    .padding(.bottom, 1)
                                
                                
                            }
                            .padding(.horizontal)
                            .onChange(of: robotEngaged, perform: { newValue in
                                ProtoFirebase.uploadCompetitionKeyMatch(playType: currentPlayType, regionalKey: regionalKey, matchKey: matchKey, teamNum: currentSelectedTeam, dataKey: "chargeStation", dataValue: newValue ? String("engaged") : "")
                            })
                            Text("The state of the ROBOT if the following are true: the CHARGE STATION is LEVEL & all ALLIANCE ROBOTS contacting the CHARGE STATION are DOCKED.")
                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                .bold()
                                .foregroundColor(Color.Neumorphic.secondary)
                                .padding(.horizontal)
                        }
                    }
                    if !robotEngaged {
                        VStack {
                            Toggle(isOn: $robotDocked) {
                                Text("Docked")
                                    .font(.system(size: 23, weight: .bold, design: .rounded))
                                    .bold()
                                    .foregroundColor(Color.black)
                                    .padding(.bottom, 1)
                                
                                
                            }
                            .padding(.horizontal)
                            .onChange(of: robotDocked, perform: { newValue in
                                ProtoFirebase.uploadCompetitionKeyMatch(playType: currentPlayType, regionalKey: regionalKey, matchKey: matchKey, teamNum: currentSelectedTeam, dataKey: "chargeStation", dataValue: newValue ? String("docked") : "")
                            })
                            Text("A ROBOT is DOCKED if it is contacting only the CHARGE STATION and/or other items also directly or transitively fully supported by the CHARGE STATION.")
                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                .bold()
                                .foregroundColor(Color.Neumorphic.secondary)
                                .padding(.horizontal)
                        }
                        .padding(.top, robotDocked ? 0 : 20)

                    }
                    if currentPlayType == "auto" {
                        VStack {
                            Toggle(isOn: $robotTaxi) {
                                Text("Taxi")
                                    .font(.system(size: 23, weight: .bold, design: .rounded))
                                    .bold()
                                    .foregroundColor(Color.black)
                                    .padding(.bottom, 1)
                                
                                
                            }
                            .padding(.horizontal)
                            .onChange(of: robotTaxi, perform: { newValue in
                                ProtoFirebase.uploadCompetitionKeyMatch(playType: currentPlayType, regionalKey: regionalKey, matchKey: matchKey, teamNum: currentSelectedTeam, dataKey: "taxi", dataValue: newValue ? "taxied" : "stayed")
                            })
                            Text("A ROBOT is TAXIED when it leaves the community.")
                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                .bold()
                                .foregroundColor(Color.Neumorphic.secondary)
                                .padding(.horizontal)
                        }
                        .padding(.top, robotDocked ? 0 : 20)
                    }
                
                }
                .frame(maxWidth: .infinity)
                    .frame(height: (robotEngaged || robotDocked) ? 150 : 300)
                    .background(LinearGradient(colors: [Color(red: 0.883, green: 0.80, blue: 0.89), Color(red: 0.91, green: 0.89, blue: 0.94)], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(20)
                    .padding()
                    .shadow(radius: 2)
                 
                Spacer()
               
            }
            .onAppear {
                currentSelectedTeam = redTeams.first ?? "frc-1"
               
            }

     
        
    }
    func updateRegionalData() {
        ProtoFirebase.retrieveCompetitionKeyMatch(playType: currentPlayType, regionalKey: regionalKey, matchKey: matchKey, teamNum: currentSelectedTeam) { protoData in
           
         
            
            highConesStepper = Int(protoData["highCones"] as? String ?? "0") ?? 0
            midConesStepper = Int(protoData["midCones"] as? String ?? "0") ?? 0
            lowConesStepper = Int(protoData["hybridCones"] as? String ?? "0") ?? 0
            highCubesStepper = Int(protoData["highCubes"] as? String ?? "0") ?? 0
            midCubesStepper = Int(protoData["midCubes"] as? String ?? "0") ?? 0
            lowCubesStepper = Int(protoData["hybridCubes"] as? String ?? "0") ?? 0
            
            robotEngaged = protoData["chargeStation"] as? String ?? "" == "engaged" ? true : false
            robotDocked = protoData["chargeStation"] as? String ?? "" == "docked" ? true : false
            robotTaxi = protoData["taxi"] as? String ?? "" == "taxied" ? true : false

        }
    }
    
}

struct RegionalSubPageScoutingDataView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello")
//        RegionalSubPageScoutingDataView(redTeams: ["frc2854", "frc972", "frc972"], blueTeams: ["frc1232", "frc2343", "frc3442"], currentSelectedTeam: "", highConesStepper: 0)
    }
}
