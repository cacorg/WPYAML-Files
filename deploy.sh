# Change these four parameters as needed
ACI_RANDOM=$RANDOM
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
WORDPRESS_DB_PASSWORD=wordpress
WORDPRESS_DB_USER=wordpress

#Get most current version of files
cd ~
rm -rf WPYAML-Files
cd ~
git clone https://github.com/cacorg/WPYAML-Files
cd WPYAML-Files

#Create APP SERVICE ELEMENTS
az group create --subscription $ACI_SUBSCRIPTION --name $ACI_PERS_RESOURCE_GROUP --location "$ACI_PERS_LOCATION"
az appservice plan create --name $ACI_APP_SERVICE_PLAN --subscription $ACI_SUBSCRIPTION --resource-group $ACI_PERS_RESOURCE_GROUP --location "$ACI_PERS_LOCATION" --sku S1 --is-linux
az webapp create --subscription $ACI_SUBSCRIPTION --resource-group $ACI_PERS_RESOURCE_GROUP --plan $ACI_APP_SERVICE_PLAN --name $ACI_APPNAME --multicontainer-config-type compose --multicontainer-config-file docker-compose-wordpress.yml

#create database folder in webapp root
creds=($(az webapp deployment list-publishing-profiles --name $ACI_APPNAME --subscription $ACI_SUBSCRIPTION --resource-group $ACI_PERS_RESOURCE_GROUP \
--query "[?contains(publishMethod, 'FTP')].[publishUrl,userName,userPWD]" --output tsv))
curl -u ${creds[1]}:${creds[2]} $creds -Q "MKD db_data" -v

#PERSISTENT STORAGE
#az webapp config appsettings set --subscription $ACI_SUBSCRIPTION --resource-group $ACI_PERS_RESOURCE_GROUP --name $ACI_APPNAME --settings WORDPRESS_DB_USER="wordpress" WORDPRESS_DB_PASSWORD="wordpress" WORDPRESS_DB_NAME="wordpress" WP_REDIS_HOST="redis"
az webapp config appsettings set --subscription $ACI_SUBSCRIPTION --resource-group $ACI_PERS_RESOURCE_GROUP --name $ACI_APPNAME --settings WEBSITES_ENABLE_APP_SERVICE_STORAGE=TRUE

#deploy
az webapp config container set --subscription $ACI_SUBSCRIPTION --resource-group $ACI_PERS_RESOURCE_GROUP --name $ACI_APPNAME --multicontainer-config-type compose --multicontainer-config-file docker-compose-wordpress.yml


#links
echo "Visit Resource --- https://portal.azure.com/#@cac.org/resource/subscriptions/a2ca24e0-461a-45f1-937c-531dd1fc24ee/resourceGroups/$ACI_APPNAME/providers/Microsoft.Web/sites/$ACI_APPNAME/appServices"
echo "visit site --- https://$ACI_APPNAME.azurewebsites.net"


#az group delete --subscription $ACI_SUBSCRIPTION --name $ACI_PERS_RESOURCE_GROUP --no-wait --verbose --yes


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
#curl -u ${creds[1]}:${creds[2]} $creds -Q "MKD database" -v
#wget --no-parent --recursive \
#--no-directories --user=${creds[1]} --password=${creds[2]} ${creds[0]}



# Create Persistent sQL DB
#az mysql server create --subscription $ACI_SUBSCRIPTION --resource-group $ACI_PERS_RESOURCE_GROUP --location "$ACI_PERS_LOCATION" --name $ACI_SQL  --location "$ACI_PERS_LOCATION" --admin-user $WORDPRESS_DB_NAME --admin-password $WORDPRESS_DB_PASSWORD --sku-name B_Gen4_1 --version 5.7
#az mysql server firewall-rule create --name ACI_FIREWALL --server $ACI_SQL --subscription $ACI_SUBSCRIPTION --resource-group $ACI_PERS_RESOURCE_GROUP --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0
#az mysql db create --subscription $ACI_SUBSCRIPTION --resource-group $ACI_PERS_RESOURCE_GROUP --server-name $ACI_SQL --name $WORDPRESS_DB_NAME
#az webapp config appsettings set --subscription $ACI_SUBSCRIPTION --resource-group $ACI_PERS_RESOURCE_GROUP --name $ACI_APPNAME --settings WORDPRESS_DB_HOST="$WORDPRESS_DB_HOST" WORDPRESS_DB_USER="$WORDPRESS_DB_USER" WORDPRESS_DB_PASSWORD="$WORDPRESS_DB_PASSWORD" WORDPRESS_DB_NAME="$WORDPRESS_DB_NAME" WP_REDIS_HOST="redis"

#UPDATE WEBAPP
#az webapp config container set --subscription $ACI_SUBSCRIPTION --resource-group $ACI_PERS_RESOURCE_GROUP --name $ACI_APPNAME --multicontainer-config-type compose --multicontainer-config-file docker-compose-wordpress.yml

#PERSISTENT STORAGE

#az webapp config appsettings set --subscription $ACI_SUBSCRIPTION --resource-group $ACI_PERS_RESOURCE_GROUP --name $ACI_APPNAME --settings WEBSITES_ENABLE_APP_SERVICE_STORAGE=TRUE

#az webapp config container set --subscription $ACI_SUBSCRIPTION --resource-group $ACI_PERS_RESOURCE_GROUP --name $ACI_APPNAME --multicontainer-config-type compose --multicontainer-config-file docker-compose-wordpress.yml
#echo "https://portal.azure.com/#@cac.org/resource/subscriptions/a2ca24e0-461a-45f1-937c-531dd1fc24ee/resourceGroups/$ACI_APPNAME/providers/Microsoft.Web/sites/$ACI_APPNAME/appServices"
