class composer (
  $target_dir       = '/vagrant',   # path to application's base dir where composer.json is located, defaults to /vagrant for dev environments
  $always_update    = false,        # you might want to set this to true in dev environments (runs composer self-update at each puppet run)
  $auto_install     = false,        # you might want to set this to true in dev environments (runs composer install when new composer.json appears)
  $php_package_name = 'php',        # php package name varies between distros and if particular puppet module was used for php installation

) {
  exec { 'install composer':
    command => '/usr/bin/curl -sS https://getcomposer.org/installer | /usr/bin/php -- --install-dir=/usr/local/bin',
    creates => '/usr/local/bin/composer.phar',
    require => Package['curl', "$php_package_name"],
    before  => File['/usr/local/bin/composer'],
  }

  file { '/usr/local/bin/composer':
    ensure => link,
    target => '/usr/local/bin/composer.phar',
  }

  if $always_update {
    exec { 'update composer':
      command => '/usr/local/bin/composer self-update',
      require => File['/usr/local/bin/composer'],
    }
  }

  if $auto_install {
    exec { 'store composer.json':
      command => "/bin/cp -a $target_dir/composer.json /var/tmp/",
      unless  => "/usr/bin/diff -q /var/tmp/composer.json $target_dir/composer.json 2>&1 >/dev/null"
    }

    exec { 'install composer libs in target_dir':
      command     => "/usr/local/bin/composer install -d $target_dir",
      require     => File['/usr/local/bin/composer'],
      refreshonly => true,
      subscribe   => Exec[ 'store composer.json' ],
      timeout     => 0,
    }
  }
}
