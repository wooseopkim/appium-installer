#!/bin/sh

ANDROID_ARCH='x86_64'
if [ 'arm64e' = $(uname -p) ]; then
    ANDROID_ARCH='arm64-v8a'
fi
ANDROID_SDK_LEVEL='33' # https://developer.android.com/tools/releases/platforms
ANDROID_PACKAGE="system-images;android-33;google_apis;$ANDROID_ARCH"

# https://brew.sh/#install
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && \

`# https://appium.io/docs/en/2.0/quickstart/install/`
brew install node@18 `# https://formulae.brew.sh/formula/node` && \
sudo npm i -g appium@next && \

`# https://appium.io/docs/en/2.0/quickstart/uiauto2-driver/`
brew install --cask android-platform-tools `# https://formulae.brew.sh/cask/android-platform-tools` && \
brew tap homebrew/cask-versions && brew install --cask temurin8 `# https://adoptium.net/installation/` && \
export ANDROID_SDK_ROOT=”/usr/local/share/android-sdk” && \
sdkmanager "$ANDROID_PACKAGE" `# https://developer.android.com/tools/sdkmanager#install` && \
avdmanager create avd --name 'Appium' --abi "google_apis/$ANDROID_ARCH" --package "$ANDROID_PACKAGE" --device "Nexus 6P" && \

`# https://appium.io/docs/en/2.0/quickstart/next-steps/`
`# download and install appium-inspector or use web version`
`# https://github.com/appium/appium-inspector#installation`
brew install python # https://formulae.brew.sh/formula/python@3.11#default
