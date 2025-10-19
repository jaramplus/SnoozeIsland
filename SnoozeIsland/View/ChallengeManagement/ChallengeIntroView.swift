//
//  ChallengeManagementIntroView.swift
//  SnoozeIsland
//
//  Created by jose Yun on 1/31/25.
//

import SwiftUI

struct ChallengeIntroView: View {
    @EnvironmentObject var snoozeViewModel: SnoozeIslandViewModel
    @Binding var startMenu: Bool
    @Binding var sleepTime: Date
    @Binding var wakeTime: Date
    @Binding var control: Bool

    var body: some View {
            VStack(spacing: 0) {
                VStack {
                    HStack(alignment: .center) {
                        Spacer()
                        Text("습관 시작")
                            .bold()
                        Spacer()
                    }
                    .overlay {
                        HStack {
                            Button(action: { withAnimation { control.toggle() } } ) {
                                Image(systemName: "chevron.left")
                                    .foregroundStyle(.black)
                            }
                            .padding()
                            Spacer()
                        }
                    }
                    .navigationBarBackButtonHidden(true)
                    
                    
                    VStack(spacing: 0) {
                        Text("이제 설정한 시간을 지켜")
                        Text("섬을 가꾸어 주세요")
                    }
                    .font(.subheadline)
                    .padding()
                    .navigationBarBackButtonHidden(true)
                    
                    TimeView()
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    
                    Button(action: {
                        // setCycle 메서드를 호출하여 cycle을 설정
                        snoozeViewModel.saveUserProfile()
                        snoozeViewModel.startProcess()
                        
                        withAnimation { startMenu.toggle()
                            control.toggle()
                        }
                    })
                    {
                        HStack {
                            Spacer()
                            Text("시작")
                            Spacer()
                        }
                    }
                    .buttonStyle(PrimaryButton())
                    .padding(.vertical, 16)
                }
            }
            .padding()
            .background(.regularMaterial)
            .mask {
                RoundedRectangle(cornerRadius: 10.0)
            }
            .frame(width: UIScreen.main.bounds.width * 0.9, height: 450)
        }
    
    private func TimeView() -> some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                HStack {
                    Image(systemName: "moon.fill")
                    Text("기상")
                }
                .font(.system(size: 18))
                Spacer()
                Text(wakeTime.formatted(myFormat))
                    .padding()
                    .environment(\.locale, Locale.init(identifier: String(Locale.preferredLanguages[0].prefix(2))))
                    .overlay {
                        DatePicker("", selection: $wakeTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.graphical)
                            .foregroundStyle(.clear)
                            .blendMode(.destinationOver)
                            .font(.system(size: 24))
                            .disabled(true)
                        
                    }
                Spacer()
            }
            .padding(.vertical, 8)
            
            Divider()
                .padding(.horizontal)
            
            HStack {
                Spacer()
                HStack {
                    Image(systemName: "sun.max.fill")
                    Text("취침")
                }
                .font(.system(size: 18))
                
                Spacer()
                Text(sleepTime.formatted(myFormat))
                    .padding()
                    .overlay {
                        DatePicker("", selection: $sleepTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.graphical)
                            .foregroundStyle(.clear)
                            .blendMode(.destinationOver)
                            .font(.system(size: 24))
                            .disabled(true)
                        
                    }
                Spacer()
            }
            .padding(.vertical, 8)
        }
//        .padding(.vertical)
        .environment(\.locale, Locale.init(identifier: String(Locale.preferredLanguages[0].prefix(2))))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke()
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    @Previewable @StateObject var snoozeViewModel = SnoozeIslandViewModel.snoozeViewModel
    
    HomeView()
        .environmentObject(snoozeViewModel)
}
