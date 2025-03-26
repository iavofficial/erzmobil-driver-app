fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
### cleanRepo
```
fastlane cleanRepo
```


----

## iOS
### ios buildFlutter
```
fastlane ios buildFlutter
```
Build flutter source
### ios buildXCArchive
```
fastlane ios buildXCArchive
```
Build iOS xcarchive
### ios exportIPAForAppStore
```
fastlane ios exportIPAForAppStore
```

### ios exportIPAForEnterprise
```
fastlane ios exportIPAForEnterprise
```

### ios buildIPA
```
fastlane ios buildIPA
```

### ios deployIPAToAppCenter
```
fastlane ios deployIPAToAppCenter
```
Deploy IPA to Microsoft AppCenter
### ios deployIPAToTestflight
```
fastlane ios deployIPAToTestflight
```

### ios deployIPAForTesting
```
fastlane ios deployIPAForTesting
```

### ios downloadProfiles
```
fastlane ios downloadProfiles
```


----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
