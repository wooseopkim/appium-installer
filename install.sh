#!/bin/sh

set -e

ANDROID_ARCH='x86_64'
if [ 'arm64e' = $(uname -p) ]; then
    ANDROID_ARCH='arm64-v8a'
fi
ANDROID_SDK_VERSION='34' # https://developer.android.com/tools/releases/platforms
ANDROID_PACKAGE="system-images;android-$ANDROID_SDK_VERSION;google_apis_playstore;$ANDROID_ARCH"
add_path () {
    if [ $GITHUB_ACTIONS ]; then
        echo "$1" >> $GITHUB_PATH
    else
    echo "export PATH=\$PATH:$1" >> ~/.bashrc
    source ~/.bashrc
}

# https://brew.sh/#install
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && \

`# https://appium.io/docs/en/2.0/quickstart/install/`
brew install node@18 `# https://formulae.brew.sh/formula/node` && \
sudo npm i -g appium@next && \

`# https://appium.io/docs/en/2.0/quickstart/uiauto2-driver/`
brew install --cask android-platform-tools `# https://formulae.brew.sh/cask/android-platform-tools` && \
brew tap homebrew/cask-versions && brew install --cask temurin17 `# https://adoptium.net/installation/` && \
ANDROID_SDK_ROOT=$HOME/Library/Android/sdk && \
add_path $ANDROID_SDK_ROOT/emulator && \
add_path $ANDROID_SDK_ROOT/cmdline-tools/latest/bin && \
add_path $ANDROID_SDK_ROOT/tools && \
add_path $ANDROID_SDK_ROOT/tools/bin && \
add_path $ANDROID_SDK_ROOT/platform-tools && \
add_path $ANDROID_SDK_ROOT/build-tools && \
touch ~/.android/repositories.cfg && \
yes | sdkmanager --licenses && \
sdkmanager --update && \
sdkmanager --install "$ANDROID_PACKAGE" `# https://developer.android.com/tools/sdkmanager#install` && \
avdmanager create avd --name 'Appium' --abi "google_apis_playstore/$ANDROID_ARCH" --package "$ANDROID_PACKAGE" --device "Nexus 6P" && \

`# https://appium.io/docs/en/2.0/quickstart/next-steps/`
brew install python # https://formulae.brew.sh/formula/python@3.11#default

# download and install appium-inspector or use web version
# https://github.com/appium/appium-inspector#installation
