hot backup for mysql and restore mysql data
in single script

1.backup
use crontab job  to run :
such as:10 */1 * * * path/mysql-backup-percona.sh

2.restore
mysql-backup-percona.sh 2017-12-6
make sure the date format

