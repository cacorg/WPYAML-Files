# Change these four parameters as needed
ACI_RANDOM=$RANDOM
GIT_BRANCH=$Master
ACI_APPNAME=wordpress-jf-$ACI_RANDOM
ACI_SUBSCRIPTION=Sandbox
ACI_PERS_RESOURCE_GROUP=$ACI_APPNAME
ACI_PERS_STORAGE_ACCOUNT_NAME=$ACI_PERS_RESOURCE_GROUP$ACI_APPNAME
ACI_PERS_LOCATION=eastus
ACI_PERS_SHARE_NAME=source
ACI_APP_SERVICE_PLAN=$ACI_APPNAME
ACI_SQL=database$ACI_APPNAME
ACI_FIREWALL=firewallrule$ACI_RANDOM
WORDPRESS_DB_NAME=wordpress
WORDPRESS_DB_HOST=$ACI_SQL.mysql.database.azure.com
WORDPRESS_DB_PASSWORD=My5up3rStr0ngPaSw0rd!
WORDPRESS_DB_USER=$WORDPRESS_DB_NAME@$ACI_SQL

#Get most current version of files
cd ~
rm -rf WPYAML-Files
cd ~
git clone -b $GIT_BRANCH --single-branch https://github.com/cacorg/WPYAML-Files
cd WPYAML-Files

#Create APP SERVICE ELEMENTS
az group create --subscription $ACI_SUBSCRIPTION --name $ACI_PERS_RESOURCE_GROUP --location "$ACI_PERS_LOCATION"
az appservice plan create --name $ACI_APP_SERVICE_PLAN --subscription $ACI_SUBSCRIPTION --resource-group $ACI_PERS_RESOURCE_GROUP --location "$ACI_PERS_LOCATION" --sku S1 --is-linux
az webapp create --subscription $ACI_SUBSCRIPTION --resource-group $ACI_PERS_RESOURCE_GROUP --plan $ACI_APP_SERVICE_PLAN --name $ACI_APPNAME --multicontainer-config-type compose --multicontainer-config-file docker-compose-wordpress.yml
#PERSISTENT STORAGE
az webapp config appsettings set --subscription $ACI_SUBSCRIPTION --resource-group $ACI_PERS_RESOURCE_GROUP --name $ACI_APPNAME --settings WEBSITES_ENABLE_APP_SERVICE_STORAGE=TRUE

#TODO
#az extension add --name webapp
#az extension update --name webapp
#az webapp remote-connection create --subscription $ACI_SUBSCRIPTION --resource-group $ACI_PERS_RESOURCE_GROUP -n $ACI_APPNAME -p 22 &
# Storage deploy
# SSH into webapp
# git clone: htdocs
#cd ..
#git clone https://github.com/WordPress/WordPress
#creds=($(az webapp deployment list-publishing-profiles --name $ACI_APPNAME --subscription $ACI_SUBSCRIPTION --resource-group $ACI_PERS_RESOURCE_GROUP \
#--query "[?contains(publishMethod, 'FTP')].[publishUrl,userName,userPWD]" --output tsv))
#wget --no-parent --recursive \
#--no-directories --user=${creds[1]} --password=${creds[2]} ${creds[0]}

az webapp config appsettings set --subscription $ACI_SUBSCRIPTION --resource-group $ACI_PERS_RESOURCE_GROUP --name $ACI_APPNAME --settings WP_REDIS_HOST="redis"


# Create Persistent sQL DB
az mysql server create --subscription $ACI_SUBSCRIPTION --resource-group $ACI_PERS_RESOURCE_GROUP --location "$ACI_PERS_LOCATION" --name $ACI_SQL  --location "$ACI_PERS_LOCATION" --admin-user $WORDPRESS_DB_NAME --admin-password $WORDPRESS_DB_PASSWORD --sku-name B_Gen4_1 --version 5.7
az mysql server firewall-rule create --name ACI_FIREWALL --server $ACI_SQL --subscription $ACI_SUBSCRIPTION --resource-group $ACI_PERS_RESOURCE_GROUP --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0
az mysql db create --subscription $ACI_SUBSCRIPTION --resource-group $ACI_PERS_RESOURCE_GROUP --server-name $ACI_SQL --name $WORDPRESS_DB_NAME
az webapp config appsettings set --subscription $ACI_SUBSCRIPTION --resource-group $ACI_PERS_RESOURCE_GROUP --name $ACI_APPNAME --settings WORDPRESS_DB_HOST="$WORDPRESS_DB_HOST" WORDPRESS_DB_USER="$WORDPRESS_DB_USER" WORDPRESS_DB_PASSWORD="$WORDPRESS_DB_PASSWORD" WORDPRESS_DB_NAME="$WORDPRESS_DB_NAME" WP_REDIS_HOST="redis"

#UPDATE WEBAPP
az webapp config container set --subscription $ACI_SUBSCRIPTION --resource-group $ACI_PERS_RESOURCE_GROUP --name $ACI_APPNAME --multicontainer-config-type compose --multicontainer-config-file docker-compose-wordpress.yml

#PERSISTENT STORAGE

az webapp config appsettings set --subscription $ACI_SUBSCRIPTION --resource-group $ACI_PERS_RESOURCE_GROUP --name $ACI_APPNAME --settings WEBSITES_ENABLE_APP_SERVICE_STORAGE=TRUE

az webapp config container set --subscription $ACI_SUBSCRIPTION --resource-group $ACI_PERS_RESOURCE_GROUP --name $ACI_APPNAME --multicontainer-config-type compose --multicontainer-config-file docker-compose-wordpress.yml
