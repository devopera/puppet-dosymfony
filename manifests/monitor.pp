class dosymfony::monitor (

  # class arguments
  # ---------------
  # setup defaults
  
  $port = 80,
  $site_name = 'Welcome!',
  $site_url = '/app_dev.php',
  
  # end of class arguments
  # ----------------------
  # begin class

) {

  # check content of http response
  @nagios::service { "http_content:${port}-dosymfony-${::fqdn}":
    # no DNS, so need to refer to machine by external IP address
    check_command => "check_http_port_url_content!${::ipaddress}!${port}!${site_url}!'>${site_name}<'",
  }

}


