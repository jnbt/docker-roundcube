#!/bin/bash
set -e

export MYSQL_HOST
export MYSQL_USER
export MYSQL_PASSWORD
export MYSQL_DATABASE
export RC_DEFAULT_HOST
export RC_DEFAULT_PORT
export RC_SMTP_PORT
export RC_SMTP_USER
export RC_SMTP_PASS
export RC_SKIN
export RC_SUPPORT_URL
export RC_PRODUCT_NAME

MYSQL_HOST=${MYSQL_HOST:-mysql}
MYSQL_USER=${MYSQL_USER:-roundcube}
MYSQL_PASSWORD=${MYSQL_PASSWORD:-roundcube}
MYSQL_DATABASE=${MYSQL_DATABASE:-roundcube}

RC_DEFAULT_HOST=${RC_DEFAULT_HOST:-localhost}
RC_DEFAULT_PORT=${RC_DEFAULT_PORT:-143}
RC_SMTP_PORT=${RC_SMTP_PORT:-587}
RC_SMTP_USER=${RC_SMTP_USER:-%u}
RC_SMTP_PASS=${RC_SMTP_PASS:-%p}
RC_SKIN=${RC_SKIN:-larry}
RC_SUPPORT_URL=""
RC_PRODUCT_NAME="Roundcube Webmail"

wait_for_mysql() {
  until mysql --host=$MYSQL_HOST --user=$MYSQL_USER --password=$MYSQL_PASSWORD --execute="USE $MYSQL_DATABASE;" &>/dev/null; do
    echo "waiting for mysql to start..."
    sleep 2
  done
}

init_config() {
  config="$ROUNDCUBE_DIR/config/config.inc.php"
  env_config="$ROUNDCUBE_DIR/config/__config.inc.php"
  custom="$ROUNDCUBE_DIR/config/custom/*.php"

  echo "[INFO] Prepare basic configuration via $env_config"
  echo "require '$env_config';" >> "$config"
  echo "<?php" > "$env_config"

  db="'mysql://' . getenv('MYSQL_USER') . ':' . getenv('MYSQL_PASSWORD') . '@' . getenv('MYSQL_HOST') . '/' . getenv('MYSQL_DATABASE')"
  echo "\$config['db_dsnw'] = $db;" >> "$env_config"

  key=`openssl rand -base64 24`
  echo "\$config['des_key'] = '$key';" >> "$env_config"

  for e in $(env); do
    case $e in
      RC_*)
        e1=$(expr "$e" : 'RC_\([A-Z_]*\)')
        e2=$(expr "$e" : '\([A-Z_]*\)')
        echo "\$config['${e1,,}'] = getenv('$e2');" >> "$env_config"
    esac
  done

  echo "[INFO] Prepare extended configuration via $custom"
  cat >> $config <<EOF
foreach (glob('$custom') as \$f) {
  require \$f;
}
EOF
}

init_db() {
  echo "[INFO] Importing MySQL tables"
  bin/initdb.sh --dir "$ROUNDCUBE_DIR/SQL"
}

update() {
  echo "[INFO] Updating Roundcube"
  bin/update.sh
}

start_server() {
  exec apache2-foreground
}

case ${1} in
  app:help)
    echo "Available options:"
    echo " app:start        - Starts the roundcube server (default)"
    echo " app:init         - Initializes the database"
    echo " app:update       - Updates the config and database"
    echo " app:help         - Displays this help"
    echo " [command]        - Execute the specified command, eg. bash."
    ;;
  app:start)
    wait_for_mysql
    init_config
    start_server
    ;;
  app:init)
    wait_for_mysql
    init_config
    init_db
    ;;
  app:update)
    wait_for_mysql
    init_config
    update
    ;;
  *)
    init_config
    exec "$@"
    ;;
esac
