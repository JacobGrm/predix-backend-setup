#/bin/bash
set -e
isAdmin=0
while getopts "e:p:a:" opt; do
    case $opt in
	e)
	    user_email=$OPTARG
	    ;;
  p)
      user_password=$OPTARG
      ;;
  a)
      isAdmin=$OPTARG
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

if [[ -z "$user_email" ]]; then
    echo "Option Required: -e <user-email>"
    echo "Specify the email address of the user to create on the current target UAA server. e.g. test@ge.com"
    exit 1
fi

if [[ -z "$user_password" ]]; then
    echo "Specify the password of the new user:"
    stty_original=`stty -g`
	stty -echo
	read passwd
	stty $stty_original     # restoring terminal
	user_password=$passwd
fi

echo "Adding developer user to UAA: $user_email"

{
	# Create user in currently targeted UAA server.
	uaac user add $user_email --emails $user_email --password $user_password
} ||
{
    echo ""
}

# Add `pm.admin` group to user.
if [ "$isAdmin" -eq "1" ] ; then
    echo "Marking user as admin."
    uaac member add pm.admin $user_email
fi


echo "OK"
