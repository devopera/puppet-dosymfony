define dosymfony::base (

  # class arguments
  # ---------------
  # setup defaults

  $user = 'web',
  $group = 'www-data',
  $target_path = '/var/www/html',
  $symlinkdir = false,

  # end of class arguments
  # ----------------------
  # begin class

) {

  # install symfony project to web root and symlink from home
  exec { "dosymfony-base-install-${title}" :
    path => '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin',
    command => "bash -c \"export HOME=/home/${user}/; composer.phar --no-interaction create-project symfony/framework-standard-edition ${target_path}/${title}\"",
    user => $user,
    group => $group,
    cwd => "/home/${user}",
    require => [Class['dosymfony::composer']],
    # don't re-install if symfony directory already present (checked by 'src' subfolder)
    creates => "${target_path}/${title}/src",
  }
  
  if ($symlinkdir) {
    # create symlink from install to directory (e.g. user's home folder)
    file { "${symlinkdir}/${title}":
      ensure => 'link',
      target => "${target_path}/${title}",
      require => Exec["dosymfony-base-install-${title}"],
    }
  }
  
}
