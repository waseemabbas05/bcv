[ESTA PÁGINA EN ESPAÑOL](phone_documentation_es.md)


### 1. Installation

- *ANDROID*: Install Traccar client via the [Google Play Store](https://play.google.com/store/apps/details?id=org.traccar.client)
- *APPLE*:Install Traccar client via the [Apple App Store](https://apps.apple.com/us/app/traccar-client/id843156974)

### 2. Configuration

- On the phone, make sure location (in settings > privacy) is enabled, AND that the locating method is as high as possible (GPS and Wi-Fi).

- Open the Traccar app

<img src="img/a.png" height="400">


- Set the Device Identifier to _your Identification number_ (see the "Registration" section above to get a device ID)

<img src="img/b.png" height="400">

- Set the address of the server URL: `https://databrew.app`

<img src="img/c.png" height="400">


- Set location accuracy to: `high`

<img src="img/d.png" height="400">


- Set the Frequency field to: `60`

<img src="img/e.png" height="400">

- Do not change the Distance or Angles fields

- At the top set "Service status" to on/running

<img src="img/f.png" height="400">

- You're all done. To check that everything is working, you can click on "status". It should say "Location update". If it says "Send failed", double check your configuration parameters.



### 3. Use

- The Traccar app should be running ("Service status" set to on) at all times during operations
- The app will automatically initialize upon device reboot
- If for some reason the app is turned off, please turn it back on
- We have tested the app on many devices. At the 60 second recording interval, it has only minimal effect on battery life.
- When the device is offline, GPS coordinates are stored locally; when an internet connection is found, GPS coordinates are sent to the server.
