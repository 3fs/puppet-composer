class composer (
  $base_dir = '/vagrant',
) {
  exec { 'install composer':
    command => '/usr/bin/curl -sS https://getcomposer.org/installer | /usr/bin/php -- --install-dir=/usr/local/bin',
    creates => '/usr/local/bin/composer.phar',
    require => Package['curl', 'php5'],
    before  => File['/usr/local/bin/composer'],
  }

  file { '/usr/local/bin/composer':
    ensure => link,
    target => '/usr/local/bin/composer.phar',
  }

  exec { 'update composer':
    command => '/usr/local/bin/composer self-update',
    require => File['/usr/local/bin/composer'],
    notify  => Exec[ 'install composer libs in base_dir' ],
  }

  exec { 'install composer libs in base_dir':
    command => "/usr/local/bin/composer install -d $base_dir",
    require => File['/usr/local/bin/composer'],
  }
}
