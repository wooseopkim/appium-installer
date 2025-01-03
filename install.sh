#!/usr/bin/env bash -eu -o pipefail

ANDROID_ARCH='x86_64'
if [ 'arm64e' = $(uname -p) ]; then
    ANDROID_ARCH='arm64-v8a'
fi
ANDROID_SDK_VERSION='34' # https://developer.android.com/tools/releases/platforms
ANDROID_PACKAGE="system-images;android-$ANDROID_SDK_VERSION;google_apis_playstore;$ANDROID_ARCH"
add_path () {
    if [ "$GITHUB_ACTIONS" == 'true' ]; then
        echo "$1" >> "$GITHUB_PATH"
    fi
    echo "export PATH=\$PATH:$1" >> ~/.bashrc
    source ~/.bashrc
}
set_env () {
    if [ "$GITHUB_ACTIONS" == 'true' ]; then
        echo "$1=$2" >> "$GITHUB_ENV"
    fi
    echo "export $1=$2" >> ~/.bashrc
    source ~/.bashrc
}

# https://brew.sh/#install
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# https://docs.brew.sh/Manpage#shellenv-shell-
if [ "$CI" != 'true' ]; then
    if [ -f ~/.zshrc ]; then
        echo 'eval "$(brew shellenv zsh)"' >> ~/.zshrc
    fi
    if [ -f ~/.zprofile ]; then
        echo 'eval "$(brew shellenv zsh)"' >> ~/.zprofile
    fi
    if [ -f ~/.bashrc ]; then
        echo 'eval "$(brew shellenv bash)"' >> ~/.bashrc
    fi
    if [ -f ~/.bash_profile ]; then
        echo 'eval "$(brew shellenv bash)"' >> ~/.bash_profile
    fi
    if [ -f ~/.config/fish/config.fish ]; then
        echo 'eval "$(brew shellenv fish)"' >> ~/.config/fish/config.fish
    fi
fi

# https://appium.io/docs/en/2.12/quickstart/install/
brew install node # https://formulae.brew.sh/formula/node
sudo npm i -g appium

# https://appium.io/docs/en/2.12/quickstart/uiauto2-driver/
brew install --cask temurin # https://formulae.brew.sh/cask/temurin
set_env JAVA_HOME `/usr/libexec/java_home`
brew install --cask android-commandlinetools #https://formulae.brew.sh/cask/android-commandlinetools
brew install --cask android-platform-tools # https://formulae.brew.sh/cask/android-platform-tools
add_path "$(brew --prefix)/share/android-commandlinetools/cmdline-tools/latest/bin"
touch ~/.android/repositories.cfg
yes | sdkmanager --licenses
sdkmanager --update
sdkmanager --install "$ANDROID_PACKAGE" # https://developer.android.com/tools/sdkmanager#install
avdmanager create avd --name 'Appium' --abi "google_apis_playstore/$ANDROID_ARCH" --package "$ANDROID_PACKAGE" --device "Nexus 6P"
appium setup

# https://appium.io/docs/en/2.12/quickstart/next-steps/
brew install python # https://formulae.brew.sh/formula/python@3.13#default
add_path "$(brew --prefix python)/libexec/bin"

# download and install appium-inspector or use web version
# https://github.com/appium/appium-inspector#installation
