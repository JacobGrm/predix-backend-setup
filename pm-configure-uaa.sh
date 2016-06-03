#/bin/bash
set -e

while getopts "s:u:" opt; do
    case $opt in
        s)
            uaa_server_url="$OPTARG"
            ;;
        u)
            uaa_admin_username="$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done

if [[ -z "$uaa_server_url" ]]; then
    echo "Option Required: -s <uaa-url>"
    echo "Specify the URI of the target UAA server. e.g. https://uaa-host-name/"
    exit 1
fi

if [[ -z "$uaa_admin_username" ]]; then
    echo "Option Required: -u <uaa-admin-user>"
    echo "Specify the username of the admin user on the target UAA server. e.g. admin"
    exit 1
fi

function delete_outh_account_if_exists {
    local account_name=$1
    if uaac curl "/oauth/clients/$account_name" | grep "200 OK" -q; then
        echo "OAuth account exists: $account_name;  Removing account for update."
        uaac client delete "$account_name"
    fi
}

# Read a value without echoing
readSilent()
{
  stty_original=`stty -g`
  stty -echo
  read -p "$1  " $2
  stty $stty_original
  echo "\n"
}


# Target specified UAA server.
uaac target $uaa_server_url --skip-ssl-validation
# Authenticate with UAA, and prompt user for password.
uaac token client get $uaa_admin_username

# Create `pm-api-gateway-oauth` OAuth client account. (re-creating account if it already exists.)
delete_outh_account_if_exists "pm-api-gateway-oauth"
echo "Adding OAuth account: ""pm-api-gateway-oauth"
#readSilent 'Enter secret for pm-api-gateway-oauth account (use: Pr3dixMob1le):' pm_api_gw_secret

pm_api_gw_secret="Pr3dixMob1le"
uaac client add "pm-api-gateway-oauth" --authorities "uaa.resource" --scope "openid" --autoapprove "openid" --authorized_grant_types "authorization_code,client_credentials,refresh_token" --secret $pm_api_gw_secret

# Create `pm` OAuth client account (re-creating account if it already exists.)
delete_outh_account_if_exists "pm"
echo "Adding OAuth account: ""pm"
uaac client add "pm" --authorities "uaa.resource" --scope "openid pm.admin" --autoapprove "openid pm.admin" --authorized_grant_types "implicit,password,refresh_token" --secret ""

# Create `pm.admin` user group, if not already created.
uaac group get "pm.admin" > /dev/null || { echo "Creating group: pm.admin"; uaac group add "pm.admin"; }

echo "OK"
echo ""
echo "*********************************************"
echo "IMPORTANT: If you did not use the default oauth account password, be sure to update your Predix-Mobile instance to use your new password, using the 'cf update-service' command, similar to the one below:"
echo "cf update-service <service-instance-name> -c '{\"oauth_api_username\": \"pm-api-gateway-oauth\", \"oauth_api_password\": \"$pm_api_gw_secret\"}'"
echo "*********************************************"
echo ""
