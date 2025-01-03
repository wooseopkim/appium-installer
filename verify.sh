#!/usr/bin/env bash -eu -o pipefail

echo '::group::node'
node --version
whereis node
echo '::endgroup::'

echo '::group::appium'
appium --version
whereis appium
echo '::endgroup::'

echo '::group::java'
java -version
whereis java
echo '::endgroup::'

echo '::group::sdkmanager'
sdkmanager --list &> /dev/null
sdkmanager --list | sed -e '/Available Packages/q'
whereis sdkmanager
echo '::endgroup::'

echo '::group::avdmanager'
avdmanager list avd -c
whereis avdmanager
echo '::endgroup::'

echo '::group::python'
python --version
whereis python
echo '::endgroup::'
