# Write in this file customization code that will get executed before 
# autoproj is loaded.

# Set the path to 'make'
# Autobuild.commands['make'] = '/path/to/ccmake'

# Set the parallel build level (defaults to the number of CPUs)
# Autobuild.parallel_build_level = 10

# Uncomment to initialize the environment variables to default values. This is
# useful to ensure that the build is completely self-contained, but leads to
# miss external dependencies installed in non-standard locations.
#
# set_initial_env
#
# Additionally, you can set up your own custom environment with calls to env_add
# and env_set:
#
# env_add 'PATH', "/path/to/my/tool"
# env_set 'CMAKE_PREFIX_PATH', "/opt/boost;/opt/xerces"
# env_set 'CMAKE_INSTALL_PATH', "/opt/orocos"
#
# NOTE: Variables set like this are exported in the generated 'env.sh' script.
#

require 'autoproj/git_server_configuration'

Autoproj.env_inherit 'CMAKE_PREFIX_PATH'


Autoproj.gitorious_server_configuration('DFKIGIT', 'git.hb.dfki.de', default: 'http,http', :http_url => 'https://git.hb.dfki.de')


available_ros_versions = []
Dir.glob('/opt/ros/*') do |path|
    if path >= '/opt/ros/g'
        available_ros_versions << path
    end
end

configuration_option('ROS_PREFIX', 'string',
    :default => available_ros_versions.max,
    :doc => ["Which ROS prefix should we be using ? (needs to be groovy or newer)"]) do |path|
    path = File.expand_path(path)
    if !File.directory?(path)
        raise Autoproj::InputError, "#{path} does not exist or is not a directory"
    elsif !File.directory?(cmake_path = File.join(path, 'share', 'catkin', 'cmake'))
        raise Autoproj::InputError, "#{path} does not look like a ROS install path (#{cmake_path} does not exist)"
    end
    path
end

Autobuild.update_environment Autoproj.user_config('ROS_PREFIX')
Autoproj.env_add_path 'CMAKE_PREFIX_PATH', Autoproj.user_config('ROS_PREFIX')
Autoproj.env_set 'ROS_SETUP', Autoproj.user_config('ROS_PREFIX') + "/setup.sh"
Autoproj.env_add_path 'PYTHONPATH', File.join(Autoproj.user_config('ROS_PREFIX'), 'lib', 'python2.7', 'dist-packages')
#Autoproj.env_set 'ROS_MASTER_URI', 'http://localhost:11311'
Autobuild.env_clear 'ROS_ROOT'

Autobuild::Orogen.transports << 'ros'

# We cannot set ROS_ROOT within the autoproj environment as some of the RTT
# stuff still tries to build as ROS when set. Instead, set ROS_ROOT in a
# separate env file and source it at the end of the env.sh
env_ros = File.join(Autoproj.root_dir, ".env-ros.sh")
File.open(env_ros, 'w') do |io|
    io.puts "export ROS_ROOT=#{Autoproj.user_config('ROS_PREFIX')}/share/ros"
end
Autoproj.env_source_after env_ros

