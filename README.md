OVERVIEW

This project provides an automated solution for deploying a default desktop wallpaper for Windows users in a managed environment.
The system is designed to configure a standard background for new users logging into a device, while still allowing full customization afterward. It was developed as part of a real-world deployment scenario to streamline device setup and reduce manual configuration.

HOW IT WORKS
Copies required files (images and scripts) to:
C:\ProgramData\DefaultWallpaper
Modifies the Default User profile so that new users inherit the wallpaper
Uses Active Setup to apply the wallpaper automatically when a user logs in for the first time
Ensures:
New users receive the configured wallpaper
Existing users are not affected unless forced

DEPLOYMENT
Package the solution as an .intunewin file
Use install.ps1 as the setup file
Upload the package to Microsoft Intune
Assign the app to target devices/users

UPDATING THE WALLPAPER
Replace the image file with a new one using the same filename
Repackage the solution into a new .intunewin file
Upload the updated package to the same app in Intune
Behavior:
New users > receive the updated wallpaper automatically
Existing users > will NOT be affected

Forcing Updates on Existing Users
If you want to apply the new wallpaper to users who already logged in:
Uninstall the app
Reinstall the app
This forces the configuration to run again.

KEY FEATURES
Automated wallpaper deployment for new users
No lock in (users can change wallpaper freely)
Clean update process without duplicate files
No unnecessary reinstalls for existing users
Scalable via Microsoft Intune

TECH USED
PowerShell
Microsoft Intune
Windows Registry (Active Setup)
Windows User Profile configuration

This solution was developed for a real client to:
Reduce manual setup time for IT administrators
Ensure consistent branding/user experience
Simplify ongoing updates without disrupting users

NOTES
Existing users are only affected if explicitly reconfigured
The solution is designed to be lightweight and reusable
No duplicate files are created during updates
