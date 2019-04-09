# Write in this file customization code that will get executed after all the
# soures have beenloaded.

# Uncomment to reenable building the RTT test suite
# This is disabled by default as it requires a lot of time and memory
#
# Autobuild::Package['rtt'].define "BUILD_TESTING", "ON"

# Package specific prefix:
# Autobuild::Package['rtt'].prefix='/opt/autoproj/2.0'
#
# See config.yml to set the prefix:/opt/autoproj/2.0 globally for all packages.

Autoproj.manifest.each_autobuild_package do |pkg|
    if pkg.kind_of?(Autobuild::Orogen) 
        pkg.depends_on 'tools/rtt_transports/ros'
        pkg.define "CMAKE_PREFIX_PATH", Autoproj.user_config('ROS_PREFIX') + ";" + ENV["AUTOPROJ_CURRENT_ROOT"] + "/install"
    end
end
