#!/bin/bash

echo "Starting development environment configuration..."

# installs pre-commit hooks
cp Scripts/git-hooks/pre-commit-check-for-keys.rb .git/hooks/pre-commit
# mark as executable
chmod +x .git/hooks/pre-commit

# check if homebrew is installed, if not, installs it
which -s brew
if [[ $? != 0 ]] ; then
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
    # otherwise, updates it
    brew update
fi

which -s swiftlint
if [[ $? != 0 ]] ; then
  echo "🖥  - Swiftlint not installed... proceeding with install"
  brew install swiftlint
else 
  echo "🖥 - Swiftlint detected - skipping install..."
fi


which -s bundle
if [[ $? != 0 ]] ; then
  echo "📚 - Bundler not installed... proceeding with install"
  sudo gem install bundler
else
  echo "📚 - Bundler deteced - updating to mach version..."
  bundle update --bundler
fi

bundle
bundle update
bundle install

which -s pod
if [[ $? != 0 ]] ; then
  echo "📚 - Cocoapods not installed... proceeding with install"
  sudo gem install cocoapods
else
  echo "📚 - Cocoapods deteced - skipping install..."
fi

bundle exec pod setup
bundle exec pod repo add IAR-Beta git@github.com:ImagineAR/IAR-SDK-Beta-Podspecs.git

echo "📚 - Starting pod updates on all projects..."
projectDirectories+=( "IAR-CoreSDK-Sample" "IAR-SurfaceSDK-Sample" "IAR-TargetSDK-Sample")
for directory in ${projectDirectories[@]}; do
    # install pods on each project
    cd ${directory}
    bundle exec pod deintegrate
    bundle exec pod install --repo-update
    cd ..
done

echo "✅ - Environment setup is completed."