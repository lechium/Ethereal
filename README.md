# Ethereal

Ethereal is a AirDrop based media player (video / audio / streaming URLs) project based on #Breezy for jailbroken tvOS 11+

Ethereal USED to be broken up into a few different parts, now that Breezy has been modernized and improved a lot of the functionality here was frivolous, and shoudl've been part of Breezy to begin with. Some of the files in the repo are no longer necessary and will be pruned in the near future when I do housecleaning.

## Ethereal Application

Receives URL's through launchservices handle through Breezy based on document types added to the Info.plist (same way its done on iOS!)

Once it processes the file or URL (currently it doesn't handle batches, on the todo list!) it will choose the necessary playback framework and play the file.

The application also functions as a media file browser starting at /var/mobile/Documents. 


