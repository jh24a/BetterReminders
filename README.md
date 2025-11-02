A work-in-progress simple menu bar app that will send reminders at a time interval to help create habits while on the computer. 

Ex. Drinking water, Getting up to stretch every 1-2 hours, avoid eye strain by looking away for a minute, etc.

Currently only works for one reminder at a time. It can be toggled to repeat continously to behave like an endless pomodoro timer.

To make it a standalone app, open the folder BetterReminders in your terminal and run: 

xcodebuild -scheme BetterReminders -configuration Release -destination 'platform=macOS' build 


