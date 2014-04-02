define dosymfony::base (

  # class arguments
  # ---------------
  # setup defaults

  $user = 'web',
  $group = 'www-data',
  
  $app_name = 'symfony-2',
  $vhost_seq = '00',

  $target_path = '/var/www/html',
  $symlinkdir = false,
  
  # by default, open up instance for debugging
  $access_appdev = true,
  $access_appdebug = true,

  # don't monitor by default
  $monitor = false,

  # end of class arguments
  # ----------------------
  # begin class

) {

  # monitor if turned on
  if ($monitor) {
    class { 'dosymfony::monitor' : }
  }

  # install symfony project to web root and symlink from home
  exec { "dosymfony-base-install-${title}" :
    path => '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin',
    command => "bash -c \"export HOME=/home/${user}/; composer.phar --no-interaction create-project symfony/framework-standard-edition ${target_path}/${title}; cd ${target_path}/${title}; composer.phar install\"",
    user => $user,
    group => $group,
    cwd => "/home/${user}",
    require => [Class['dosymfony::composer']],
    # allow 10 minutes for install
    timeout => 600,
    # don't re-install if symfony directory already present (checked by 'src' subfolder)
    creates => "${target_path}/${title}/src",
  }
  
  # hack app_dev.php to allow broader access
  if ($access_appdev) {
    $match_header = "header('HTTP\/1.0 403 Forbidden');"
    $match_exit = "exit('You are not allowed to access this file"
    exec { "dosymfony-base-hack-appdev-${title}" :
      path => '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin',
      command => "sed -i -e \"s/  ${match_header}/\/\/ ${match_header}/\" -e \"s/  ${match_exit}/\/\/ ${match_exit}/\" ${target_path}/${title}/web/app_dev.php",    
      require => [Exec["dosymfony-base-install-${title}"]],
    }
  }
  
  # hack app.php to report error message
  if ($access_appdebug) {
    $match_line = "\$kernel = new AppKernel('prod', "
    exec { "dosymfony-base-hack-appdebug-${title}" :
      path => '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin',
      command => "sed -i -e \"s/${match_line}false/${match_line}true/\" ${target_path}/${title}/web/app.php",    
      require => [Exec["dosymfony-base-install-${title}"]],
    }  
  }
  
  if ($symlinkdir) {
    # create symlink from install to directory (e.g. user's home folder)
    file { "${symlinkdir}/${title}":
      ensure => 'link',
      target => "${target_path}/${title}",
      require => Exec["dosymfony-base-install-${title}"],
    }
  }

  # setup vhost from template as root:root
  include 'apache::params'
  file { "dosymfony-vhost-conf-${title}" :
    path => "${apache::params::vhost_dir}/vhost-${vhost_seq}-${app_name}.conf",
    content => template('dosymfony/vhosts-dosymfony.conf.erb'),
  }->
  exec { "dosymfony-vhosts-refresh-apache-${title}":
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    command => "service ${apache::params::apache_name} graceful",
    tag => ['service-sensitive'],
  }
  
  # Debian derivatives also require an enable step
  case $::operatingsystem {
    ubuntu, debian: {
      exec { "dosymfony-vhost-conf-a2ensite-${title}" :
        path => '/bin:/usr/bin:/sbin:/usr/sbin',
        command => "a2ensite vhost-${vhost_seq}-${app_name}.conf",
        before => [Exec["dosymfony-vhosts-refresh-apache-${title}"]],
        require => [File["dosymfony-vhost-conf-${title}"]],
      }
    }
  }

  # setup writeable directories
  $filewriteable = {
    "dosymfony-base-${title}-sym-cache" => {
      filename => "${target_path}/${title}/app/cache",
    },
    "dosymfony-base-${title}-sym-logs" => {
      filename => "${target_path}/${title}/app/logs",
    },
  }

  $filewriteable_defaults = {
    user => $user,
    group => $group,
    mode => 2660,
    dirmode => 2770,
    groupfacl => 'rwx',
    recurse => true,
    context => 'httpd_sys_content_t',
    require => [Exec["dosymfony-base-install-${title}"]],
  }
  create_resources(docommon::stickydir, $filewriteable, $filewriteable_defaults)

}
