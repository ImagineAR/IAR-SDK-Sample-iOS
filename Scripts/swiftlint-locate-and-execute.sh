#!/bin/sh

# Parameters:
# 1 - Derived Data location (to resolve SPM location)
# 2 - Optional (--fix) self corrects the source based on ruleset

# Following block is required for arm64 mac devices (different homebrew path than Intel counterpart)
if test -d "/opt/homebrew/bin/"; then
  PATH="/opt/homebrew/bin/:${PATH}"
fi

export PATH

# assuming script will be directly invoked by xcode build - adjust the common lint repository path
if which swiftlint >/dev/null; then
  # check if fix parameter is present
  if [ $2 = "--fix" ]; then
    # calls swiftlint with the autofix option
    swiftlint autocorrect --config ../Scripts/swiftlint-rules.yml
  fi

  swiftlint --config ../Scripts/swiftlint-rules.yml
else
  echo "❌ warning: SwiftLint not installed - run bash Scripts/setup-environment.sh"
fi