**Work In Progress**

Make room for a little **magic**. Say hello to **Isle**, a new macOS dynamic notch application. Isle introduces an interactive dynamic island where you can control your music, monitor live activities, and access information, all in one place. 
Enjoy fluid animations, intuitive controls, and a seamless experience that feels right at home. 


https://github.com/user-attachments/assets/259ea5fe-1a2a-4b2e-b176-c7f8463db9d3


**Completed Features**
- Dynamic Island with working animations
- Working Spotify & Apple Music Compatibility
- Album Cover & Visualizer Color Matching
- Time Slider / Multimedia Buttons

**To be Developed**
- [ ] Swipe to other Widgets
- [ ] Youtube Integration
- [ ] Pill shape rather than just a notch
- [ ] Other widgets (Timer, Calendar, Weather, Notes)
- [ ] Animated Album Cover (Transition when new song is played)
- [ ] Email & Calendar Integration
- [ ] And more...

**Tech Stack**
- SwiftUI

**Requirements**
- macOS 14.0 or later
- Xcode 26 or later

## Run it
1. Clone the repo:
   ```bash
   git clone https://github.com/gnaollol/Isle_Project.git
   ```
2. Open `Isle_Project.xcodeproj` in Xcode.
3. Select the **Isle_Project** target → **Signing & Capabilities** → choose your own **Team**. (A free personal team works (Apple ID))
4. Press _commandR_ to build and run

## Permissions
During the first time launching Isle, macOS will ask if Isle can control Apple Music or Spotify. Please click **allow**

If you did not click allow, you can turn it back on in **System Settings** -> **Privacy & Security** ->  **Automation**

## Quitting
Isle has no dock icon. To quit, click the star icon in the menu bar (should be to the right of the notch) and choose _Quit App_ (Other buttons WIP). 
  
