# StayHome_iOS

Stayhome KSA is a mobile application of machinestalk with a triple objective:

Features:

1- Helps and notify users to be out of his quarantine location
2- Collect company users having the machinestalk beacon bracelet to help for contact tracing purpose
3- All users data are saved on the phone and not shared with a server
4- Detect and calculate using our backend how much remining days still on your quarantine, for example if you stayed at home for 3 days. The app recognizes this via your home network and show this info to encourage user

services:

When starting DashboardActivity, the MylocationService starts within AlarmManager. This checks every 1 minutes whether the user is on the home network, app detect all user / phone data like GPS Info, wifi status, Bluetooth status, internet connection status, Accelerometer status (user moving or stopped), Cell Id info, near by bluetooth (BLE) and near by bracelets ... App is using popups and notifications to inform user he / she is outside or inside his trust zone
Those informations are saved locally on log file inside Logger / files and service is running Foreground / Background / And app killed also if Tel rebooted app run again services to track user

Libraries:
We used Library beaconplus SDK to detect All beacon bracelet using App Service.
