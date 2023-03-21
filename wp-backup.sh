# root password of databases (in the file)
# upload server ( in the file)
# site urls ( input from cli)

FTPHOST="192.168.0.0"
FTPUSER="user1"
FTPPASSWORD="1234"

db_root_password="sdvbhksdv"

########
website="$1"
dbname="${website//[^[:alnum:]]/}db"
websitefolder="${website//[^[:alnum:]]/}"



pre_activities(){
     cd /
     mkdir /site-backups/
     mkdir /full-backups/
}

outpout_db(){
        mysqldump -u root -p${db_root_password} ${dbname} --master-data | gzip > /${dbname}.sql.gz 
}
outpout_websitefiles(){
        tar -cpvzf /${websitefolder}files.tar.gz /var/www/${website}/*     
}

packaging(){
        tar -cpvzf /site-backups/${websitefolder}.tar.gz /${websitefolder}files.tar.gz /${dbname}.sql.gz
        rm /${websitefolder}files.tar.gz /${dbname}.sql.gz   
}

upload_packages(){

        DESTINATION="/site-backups"
        ALL_FILES="/site-backups/${websitefolder}.tar.gz"
        ftp -inv $FTPHOST <<EOF
user $FTPUSER $FTPPASSWORD
cd $DESTINATION
mput $ALL_FILES
bye
EOF  

}

pre_activities
outpout_db
outpout_websitefiles
packaging
upload_packages
