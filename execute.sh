# Change these parameters as needed
#GIT config
GIT_BRANCH=Master
GIT_LOC=multicontainerwordpress
GIT_ACCT=Azure-Samples
GIT_SERVICE=https://github.com

#APP config
ACI_SUBSCRIPTION=Sandbox
APPNAME=jimfin
ACI_SUBSCRIPTION=Sandbox
ACI_PERS_LOCATION=eastus
ACI_PERS_SHARE_NAME=source
WORDPRESS_DB_NAME=wordpress
WORDPRESS_DB_PASSWORD=My5up3rStr0ngPaSw0rd!
CONTAINERTYPE=Kube



#---------------------------------------------
ACI_RANDOM=$RANDOM
ACI_APPNAME=$APPNAME$ACI_RANDOM
ACI_PERS_RESOURCE_GROUP=$ACI_APPNAME
ACI_PERS_STORAGE_ACCOUNT_NAME=$ACI_PERS_RESOURCE_GROUP$ACI_APPNAME
ACI_APP_SERVICE_PLAN=$ACI_APPNAME
ACI_SQL=database$ACI_APPNAME
ACI_FIREWALL=firewallrule$ACI_RANDOM

WORDPRESS_DB_HOST=$ACI_SQL.mysql.database.azure.com
WORDPRESS_DB_USER=$WORDPRESS_DB_NAME@$ACI_SQL


if [ "$CONTAINERTYPE" = "Kube" ]
then
    multicontainerconfigfile=kubernetes-wordpress.yml
else
    multicontainerconfigfile=docker-compose-wordpress.yml
    CONTAINERTYPE=multicontainer
fi




GIT_URL=$GIT_SERVICE/$GIT_ACCT/$GIT_LOC

cd ~
rm -rf $GIT_LOC
cd ~
git clone $GIT_URL
cd $GIT_LOC

#Create APP SERVICE ELEMENTS
az group create --subscription $ACI_SUBSCRIPTION --name $ACI_PERS_RESOURCE_GROUP --location "$ACI_PERS_LOCATION"
az appservice plan create --name $ACI_APP_SERVICE_PLAN --subscription $ACI_SUBSCRIPTION --resource-group $ACI_PERS_RESOURCE_GROUP --sku S1 --is-linux
az webapp create --subscription $ACI_SUBSCRIPTION --resource-group $ACI_PERS_RESOURCE_GROUP --plan $ACI_APP_SERVICE_PLAN --name $ACI_APPNAME --multicontainer-config-type $CONTAINERTYPE --multicontainer-config-file $multicontainerconfigfile
#PERSISTENT STORAGE
az webapp config appsettings set --subscription $ACI_SUBSCRIPTION --resource-group $ACI_PERS_RESOURCE_GROUP --name $ACI_APPNAME --settings WEBSITES_ENABLE_APP_SERVICE_STORAGE=TRUE

# Create Persistent sQL DB
az mysql server create --subscription $ACI_SUBSCRIPTION --resource-group $ACI_PERS_RESOURCE_GROUP --name $ACI_SQL  --location "$ACI_PERS_LOCATION" --admin-user $WORDPRESS_DB_NAME --admin-password $WORDPRESS_DB_PASSWORD --sku-name B_Gen4_1 --version 5.7
az mysql server firewall-rule create --name ACI_FIREWALL --server $ACI_SQL --subscription $ACI_SUBSCRIPTION --resource-group $ACI_PERS_RESOURCE_GROUP --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0
az mysql db create --subscription $ACI_SUBSCRIPTION --resource-group $ACI_PERS_RESOURCE_GROUP --server-name $ACI_SQL --name $WORDPRESS_DB_NAME
az webapp config appsettings set --subscription $ACI_SUBSCRIPTION --resource-group $ACI_PERS_RESOURCE_GROUP --name $ACI_APPNAME --settings WORDPRESS_DB_HOST="$WORDPRESS_DB_HOST" WORDPRESS_DB_USER="$WORDPRESS_DB_USER" WORDPRESS_DB_PASSWORD="$WORDPRESS_DB_PASSWORD" WORDPRESS_DB_NAME="$WORDPRESS_DB_NAME"

#UPDATE WEBAPP
az webapp create --subscription $ACI_SUBSCRIPTION --resource-group $ACI_PERS_RESOURCE_GROUP --plan $ACI_APP_SERVICE_PLAN --name $ACI_APPNAME --multicontainer-config-type $CONTAINERTYPE --multicontainer-config-file $multicontainerconfigfile

#PERSISTENT STORAGE

az webapp config appsettings set --subscription $ACI_SUBSCRIPTION --resource-group $ACI_PERS_RESOURCE_GROUP --name $ACI_APPNAME --settings WEBSITES_ENABLE_APP_SERVICE_STORAGE=TRUE

az webapp create --subscription $ACI_SUBSCRIPTION --resource-group $ACI_PERS_RESOURCE_GROUP --plan $ACI_APP_SERVICE_PLAN --name $ACI_APPNAME --multicontainer-config-type $CONTAINERTYPE --multicontainer-config-file $multicontainerconfigfile
