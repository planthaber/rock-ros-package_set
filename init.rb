available_ros_versions = []
Dir.glob('/opt/ros/*') do |path|
    if path >= '/opt/ros/f'
        available_ros_versions << path
    end
end

configuration_option('ROS_PREFIX', 'string',
    :default => available_ros_versions.max,
    :doc => ["Which ROS prefix should we be using ? (needs to be fuerte or newer)"]) do |path|
    path = File.expand_path(path)
    if !File.directory?(path)
        raise Autoproj::InputError, "#{path} does not exist or is not a directory"
    elsif !File.directory?(cmake_path = File.join(path, 'share', 'ros', 'cmake'))
        raise Autoproj::InputError, "#{path} does not look like a ROS install path (#{cmake_path} does not exist)"
    end
    path
end

Autobuild.update_environment Autoproj.user_config('ROS_PREFIX')
Autoproj.env_add_path 'CMAKE_PREFIX_PATH', Autoproj.user_config('ROS_PREFIX')
Autoproj.env_add_path 'PYTHONPATH', File.join(Autoproj.user_config('ROS_PREFIX'), 'lib', 'python2.7', 'dist-packages')
Autoproj.env_set 'ROS_MASTER_URI', 'http://localhost:11311'
Autobuild::Orogen.transports << 'ros'