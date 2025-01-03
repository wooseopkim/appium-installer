#!/usr/bin/env bash -eu -o pipefail

if [ "${CI:-}" != 'true' ]; then
    echo 'not on CI'
    exit 1
fi

remove_command () {
    which -a $1 | xargs rm
}

unset_environment () {
    unset `awk 'BEGIN{for(v in ENVIRON) print v}' | grep $1`
}

ensure_not_callable () {
    return $(which $1 | wc -l)
}

ensure_environment_empty () {
    return $(awk 'BEGIN{for(v in ENVIRON) print v}' | grep $1 | wc -l)
}

while read name; do
    remove_command $name
    ensure_not_callable $name
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
    unset_environment $pattern
    ensure_environment_empty $pattern
done <<-EOF
    JAVA
    ANDROID
EOF
