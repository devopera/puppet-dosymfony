class dosymfony (

  # class arguments
  # ---------------
  # setup defaults

  # end of class arguments
  # ----------------------
  # begin class

) {

  if ! defined(Class['dosymfony::composer']) {
    class { 'dosymfony::composer': }
  }

  # anchor dosymfony contained classes
  # @see http://docs.puppetlabs.com/puppet/2.7/reference/lang_containment.html#known-issues
  anchor { 'dosymfony-comp-first': } -> Class['dosymfony::composer'] -> anchor { 'dosymfony-comp-last': }
}
