#!/bin/sh

ANDROID_ARCH='x86_64'
if [ 'arm64e' = $(uname -p) ]; then
    ANDROID_ARCH='arm64-v8a'
fi
ANDROID_SDK_VERSION='34' # https://developer.android.com/tools/releases/platforms
ANDROID_PACKAGE="system-images;android-$ANDROID_SDK_VERSION;google_apis_playstore;$ANDROID_ARCH"
RC_FILE="$HOME/.zshrc"
if [ $GITHUB_ACTIONS ]; then
    RC_FILE="$HOME/.bashrc"
fi

touch $RC_FILE

# https://brew.sh/#install
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" && \

`# https://appium.io/docs/en/2.0/quickstart/install/`
brew install node@18 `# https://formulae.brew.sh/formula/node` && \
sudo npm i -g appium@next && \

`# https://appium.io/docs/en/2.0/quickstart/uiauto2-driver/`
brew install gradle `# https://gist.github.com/patrickhammond/4ddbe49a67e5eb1b9c03` `# https://formulae.brew.sh/formula/gradle` && \
brew install --cask android-platform-tools `# https://formulae.brew.sh/cask/android-platform-tools` && \
brew tap homebrew/cask-versions && brew install --cask temurin17 `# https://adoptium.net/installation/` && \
echo '
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_SDK_ROOT/emulator
export PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_SDK_ROOT/tools
export PATH=$PATH:$ANDROID_SDK_ROOT/tools/bin
export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools
export PATH=$PATH:$ANDROID_SDK_ROOT/build-tools
' >> $RC_FILE && \
source $RC_FILE && \
touch ~/.android/repositories.cfg && \
yes | sdkmanager --licenses && \
sdkmanager --update && \
sdkmanager --install "$ANDROID_PACKAGE" `# https://developer.android.com/tools/sdkmanager#install` && \
avdmanager create avd --name 'Appium' --abi "google_apis_playstore/$ANDROID_ARCH" --package "$ANDROID_PACKAGE" --device "Nexus 6P" && \

`# https://appium.io/docs/en/2.0/quickstart/next-steps/`
brew install python # https://formulae.brew.sh/formula/python@3.11#default

# download and install appium-inspector or use web version
# https://github.com/appium/appium-inspector#installation
