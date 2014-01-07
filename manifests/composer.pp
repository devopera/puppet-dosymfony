class dosymfony::composer (

  # class arguments
  # ---------------
  # setup defaults

  $target_path = '/usr/local/bin',

  # end of class arguments
  # ----------------------
  # begin class

) {

  exec { 'dosymfony-composer-install':
    path => '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/zend/bin',
    command => "bash -c \"cd ${target_path} && curl -sS https://getcomposer.org/installer | php\"",
  }

}
