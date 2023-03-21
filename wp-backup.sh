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
    if  [ $website="*"]
    then 
        mysqldump -u root -p${db_root_password} --all-databases --master-data | gzip > /alldatabases.sql.gz
    else
        mysqldump -u root -p${db_root_password} ${dbname} --master-data | gzip > /${dbname}.sql.gz
    fi 
}
outpout_websitefiles(){
    if  [ $website="*"]
    then 
        tar -cpvzf /allsitesfile.tar.gz /var/www/*
    else
        tar -cpvzf /${websitefolder}files.tar.gz /var/www/${websitefolder}/* 
    fi    
}

packaging(){

    if  [ $website="*"]
    then 
        tar -cpvzf /full-backups/allsites.tar.gz /allsitesfile.tar.gz /alldatabases.sql.gz
        rm /allsitesfile.tar.gz /alldatabases.sql.gz
    else
        tar -cpvzf /site-backups/${websitefolder}.tar.gz /${websitefolder}files.tar.gz /${dbname}.sql.gz
        rm /${websitefolder}files.tar.gz /${dbname}.sql.gz
    fi   
}

upload_packages(){

    if  [ $website="*"]
    then 
        DESTINATION='/full-backups' 
        ALL_FILES="/full-backups/allsites.tar.gz"
        ftp -inv $FTPHOST <<EOF
user $FTPUSER $FTPPASSWORD
cd $DESTINATION
mput $ALL_FILES
bye
EOF
    else
        DESTINATION="/site-backups"
        ALL_FILES="/site-backups/${websitefolder}.tar.gz"
        ftp -inv $FTPHOST <<EOF
user $FTPUSER $FTPPASSWORD
cd $DESTINATION
mput $ALL_FILES
bye
EOF
    fi  

}

pre_activities
outpout_db
outpout_websitefiles
packaging
upload_packages
