# Ethereal

Ethereal is a AirDrop based project based on #Breezy for jailbroken tvOS 11+

It is broken up into a few different pieces, there is the Ethereal Application that manages video playback and file browsing, the preference loader, a TVSettings application tweak, and a daemon.

## Daemon

The daemon (ethereald) has a few responsibilities:

1. Toggle whether or not AirDrop is available on/off based on a DistributedSynchronizationHandler
2. Setting up said DistributedSynchronizationHandler to sync preferences between Ethereal application and its daemon
3. Receive NSDistributedNotifications from Breezy (com.nito.AirDropper/airDropFileReceived) and process the files / URLs accordingly

### Toggle AirDrop state 

To toggle the AirDrop state without needing a persistent UIViewController (like Romulator needs) an instace of SFAirDropDiscoveryController from the Sharing framework is created & saved as a property. To toggle AirDrop 'discoverable mode' I call setDiscoverableMode: on 'discoveryController' (our property for SFAirDropDiscoveryController) to SDAirDropDiscoverableModeOff or SDAirDropDiscoverableModeEveryone respectively.

### DistributedSynchronizationHandler

This is how to listen for changes from a preferenceloader bundle

    - (void)setupListener {
        [TVSPreferences addObserverForDomain:@"com.nito.Ethereal" withDistributedSynchronizationHandler:^(id object) {
            [self preferencesUpdated];
            }];
     }

and preferenceUpdates tracks what the discovery mode is set to and either turns AirDrop on or off and updates the preferences accordingly.

### Breezy Notifications

Receive distributed notification from Breezy in this method

    - (void)adr:(NSNotification *)n
    
from there it detects whether we are dealing with files or URL's (both relayed through differently to the ethereal application)

If it is a URL it processes it immediately, and if its a file path it will copy it into the /var/mobile/Documents/Ethereal folder. If there is currently any kind of media playing, it will not start playing your new content immediately and will alert the user that new material is available in ethereal. If the media makes it through to be played back immediately it will pass the necessary notification on to the Ethereal application.

## Ethereal Application

The etheal application is currently (improperly) launched and then fed info through a distributed notification, this will change in the near future to be done through a custom URL Scheme like it should've been done originally!

Once it processes the file or URL (currently it doesn't handle batches, on the todo list!) it will choose the necessary playback framework and play the file.

The application also functions as a media file browser starting at /var/mobile/Documents. It also has a shortcut to get to the preference loader bundle

## Preference loader bundle

Handles whether or not AirDrop sharing is turned on or off, opens ethereal application and the ability to restart sharingd in case injection didn't happen properly during installation. (bundle/EtherealSettings.m)

#### Flaws

The flaws of ethereal are kind of inherent in the implementation of Breezy to begin with, sending indistriminate distributed notifications that several applications can listen to and fight over actions thereof (who gets the file first? Ethereal or VLC?) I am working on a solution for this based around how it is handled on iOS. No ETA for when that will be completed.

