class dosymfony (

  # class arguments
  # ---------------
  # setup defaults

  $user = 'web',

  # end of class arguments
  # ----------------------
  # begin class

) {

  if ! defined(Class['dosymfony::composer']) {
    class { 'dosymfony::composer': }
  }
  
}
