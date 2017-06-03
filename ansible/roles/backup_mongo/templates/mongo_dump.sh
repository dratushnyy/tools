#! /bin/bash

function backup {
    item=$1
    echo "$(date +"%Y%m%d %H:%M:%S"): Backup of ${item} - started" >> {{logs_dir}}/backup.log
    echo "$(date +"%Y%m%d %H:%M:%S"): Backup of ${item} - running mongodump ..." >> {{logs_dir}}/backup.log
    mongodump -h {{mongo_ip}} -p {{mongo_port}} -u{{mongo_admin_user}} -p{{mongo_admin_pass}} --db ${item} --out "{{backup_dir}}/$(date +'%Y%m%d')"
    echo "$(date +"%Y%m%d %H:%M:%S"): Backup of ${item} - mongodump DONE!" >> {{logs_dir}}/backup.log
    echo "$(date +"%Y%m%d %H:%M:%S"): Backup of ${item} - creating  /backup/${item}.$(date +'%Y%m%d').tar.gz ..." >> {{logs_dir}}/backup.log
    tar -czvf ${item}.$(date +'%Y%m%d').tar.gz {{backup_dir}}/$(date +'%Y%m%d')/${item}
    echo "$(date +"%Y%m%d %H:%M:%S"): Backup of ${item} - creating  ${item}.$(date +'%Y%m%d').tar.gz DONE!" >> {{logs_dir}}/backup.log
    echo "$(date +"%Y%m%d %H:%M:%S"): Backup of ${item} - uploading to S3 ..." >> {{logs_dir}}/backup.log
    aws s3 cp  ${item}.$(date +'%Y%m%d').tar.gz s3://{{S3_BUCKET}}
    echo "$(date +"%Y%m%d %H:%M:%S"): Backup of ${item} - uploading to S3 DONE!" >> {{logs_dir}}/backup.log
    echo "$(date +"%Y%m%d %H:%M:%S"): Backup of ${item} - cleaning up local data dump ..." >> {{logs_dir}}/backup.log
    rm -rf  "{{backup_dir}}/$(date +'%Y%m%d')"
    rm -rf  "${item}.$(date +'%Y%m%d').tar.gz"
    echo "$(date +"%Y%m%d %H:%M:%S"): Backup of ${item} - cleaning up local data dump DONE!" >> {{logs_dir}}/backup.log
}

{% for db in mongo_databases %}
backup {{db}}
{% endfor %}