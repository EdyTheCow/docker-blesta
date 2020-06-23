#!/bin/bash
set -e

if [ ! -d /var/www/app ]; then
	cp -Rp /var/www/docker-backup-app /var/www/app
else
	IN_STORAGE_BACKUP="$(ls /var/www/docker-backup-app/)"
	for path in $IN_STORAGE_BACKUP; do
		if [ ! -e "/var/www/app/$path" ]; then
			cp -Rp "/var/www/docker-backup-app/$path" "/var/www/app/"
		fi
	done
fi

# compare app volume version with image version
if [ ! -e /var/www/app/version ] || [ "$BLESTA_VERSION" != "$(cat /var/www/app/version)" ]; then
  echo 'clone app directory...'
  cp -Rp /var/www/docker-backup-app/* /var/www/app/
  echo $BLESTA_VERSION > /var/www/app/version

  # unbranded
  if [ "${BLESTA_UNBRANDED}" == "true" ]; then
    sed -i 's/^.*Powered by.*Blesta.*$//g' /var/www/app/blesta/app/views/client/bootstrap/structure.pdt
  fi
  
  # custom admin route
  if [ -n "${BLESTA_ADMIN_ROUTE}" ]; then
    sed -i "s=^Configure::set('Route.admin', 'admin');$=Configure::set('Route.admin', '"${BLESTA_ADMIN_ROUTE}"');=g" /var/www/app/blesta/config/routes.php
  fi

  # custom client route
  if [ -n "${BLESTA_CLIENT_ROUTE}" ]; then
    sed -i "s=^Configure::set('Route.client', 'client');$=Configure::set('Route.client', '"${BLESTA_CLIENT_ROUTE}"');=g" /var/www/app/blesta/config/routes.php
  fi

  # robots.txt to block all
  if [ "${BLESTA_ROBOTS_TXT}" == "true" ]; then
    cat <<- EOF >> /var/www/app/blesta/robots.txt
	User-agent: *
	Disallow: /

	User-agent: ia_archiver 
	Disallow: / 

	User-agent: archive.org_bot 
	Disallow: /
EOF
  fi

  # run custom upgrade script if present 
  if [ -x /var/www/app/custom-upgrade.sh ]; then
    /var/www/app/custom-upgrade.sh 
  fi
fi

# download the GeoLite2 database if not present
if [ ! -e /var/www/app/uploads/system/GeoLite2-City.mmdb ]; then
  echo 'downloading GeoLite2 database...'
  wget -O GeoLite2-City.tar.gz 'https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&license_key='${MAXMIND_KEY}'&suffix=tar.gz'
  tar -tf GeoLite2-City.tar.gz | grep mmdb | xargs tar -xf  GeoLite2-City.tar.gz --strip-components 1 -C /var/www/app/uploads/system/
fi 

echo 'start'
exec "$@"
