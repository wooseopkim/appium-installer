#!/usr/bin/env bash -eu -o pipefail

if [ "${CI:-}" != 'true' ]; then
    echo 'not on CI'
    exit 1
fi

remove_command () {
    which -a $1 | xargs -I % bash -ceu -o pipefail 'rm % && echo "command removed: %"'
}

destroy_environment () {
    keys=`awk 'BEGIN{for(v in ENVIRON) print v}' | grep $1`
    if [ "$GITHUB_ACTIONS" == 'true' ]; then
        echo "$keys" | xargs -I % bash -ceu -o pipefail 'if [ -e "$%" ]; then rm -rf "$%" && echo "environment variable content removed: %"; fi'
    fi
    echo "$keys" | xargs -I % bash -ceu -o pipefail 'unset % && echo "environment variable removed: %"'
}

assert_not_callable () {
    return $(which $1 | wc -l)
}

assert_environment_does_not_match () {
    return $(awk 'BEGIN{for(v in ENVIRON) print v}' | grep $1 | wc -l)
}

while read name; do
    remove_command "$name"
    assert_not_callable "$name"
done <<-EOF
    sdkmanager
    avdmanager
    java
    gradle
    node
    npm
    python
    appium
    choco
EOF

while read pattern; do
    destroy_environment "$pattern"
    assert_environment_does_not_match "$pattern"
done <<-EOF
    JAVA
    ANDROID
EOF
