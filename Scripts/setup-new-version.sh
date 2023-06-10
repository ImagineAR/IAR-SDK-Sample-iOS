#!/bin/bash

echo Version increment for Sample Apps
echo Enter the marketing version number: eg: 1.5.0 and press Enter

read marketingVersion

if [ -z $marketingVersion ]; then
    echo "Marketing Version is required. Terminating...";
    exit 1;
fi

projectDirectories+=( "IAR-CoreSDK-Sample" "IAR-SurfaceSDK-Sample" "IAR-TargetSDK-Sample" "IAR-UISDK-Sample" )
for cmd in ${projectDirectories[@]}; do
    cd ${cmd}
    agvtool bump -all && agvtool new-marketing-version $marketingVersion;
    cd ..
done

