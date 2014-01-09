class dosymfony::base (

  # class arguments
  # ---------------
  # setup defaults

  $user = 'web',
  $group = 'www-data',
  $target_path = '/var/www/html',

  # end of class arguments
  # ----------------------
  # begin class

) {

  # install symfony project to web root and symlink from home
  exec { 'dosymfony-base-install-symfony' :
    path => '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin',
    command => "bash -c \"export HOME=/home/${user}/; composer.phar --no-interaction create-project symfony/framework-standard-edition ${target_path}/symfony-demo; ln -s ${target_path}/symfony-demo /home/${user}/\"",
    user => $user,
    group => $group,
    require => [Class['dosymfony::composer']],
  }
  
}
