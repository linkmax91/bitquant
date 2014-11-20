#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if ! $(groups $(whoami) | grep &>/dev/null '\btomcat\b'); then
    echo "User not in tomcat group"
    exit
fi

export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.40-4.b02.4.mga5.x86_64/jre
export TOMCAT_HOME=/var/lib/tomcat
mysqladmin -uroot -pmysql create 'mifosplatform-tenants'
mysqladmin -uroot -pmysql create 'mifostenant-default'
mkdir -p ~/tmp
pushd ~/tmp
if [ ! -d mifosplatform-1.25.1.RELEASE ] ; then
curl --location http://downloads.sourceforge.net/project/mifos/Mifos%20X/mifosplatform-1.25.1.RELEASE.zip -O mifosplatform-1.25.1.RELEASE.zip
unzip mifosplatform-1.25.1.RELEASE.zip
fi
pushd mifosplatform-1.25.1.RELEASE
mysql -uroot -pmysql mifosplatform-tenants < database/mifospltaform-tenants-first-time-install.sql


if [ ! -e /usr/share/tomcat/.keystore ] ; then 
echo "" | sudo keytool -genkey -alias mifostom -keyalg RSA \
  -storepass changeit -noprompt \
  -dname "CN=Unknown, OU=Unknown, O=Unknown, L=Unknown,S=Unknown, C=Unknown" \
  -keystore /usr/share/tomcat/.keystore
fi
cp mifosng-provider.war $TOMCAT_HOME/webapps
mkdir $TOMCAT_HOME/webapps/ROOT
cp -r api-docs $TOMCAT_HOME/webapps/ROOT
cp -r apps/community-app $TOMCAT_HOME/webapps/ROOT
popd
cp $SCRIPT_DIR/server.xml /etc/tomcat
popd