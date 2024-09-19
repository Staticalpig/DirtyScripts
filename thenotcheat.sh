#!/bin/bash

## Step 1: create users:

#Update the system
apt-get update
apt-get upgrade -y
apt-get dist-upgrade -y

# # Define groups
EMPLOYEES_GROUP="employees"
FINANCE_GROUP="finance"
EXECUTIVES_GROUP="executives"
SSH_GROUP="ssh-users"

UNMASK_FILE="/etc/pam.d/common-session"
UNMASK_REQUIRED_LINE="session optional pam_umask.so umask=0007"

# Standard password
standardPassword="Syn9393"

# Check if a user is create, if it isn't create it. 
#Else return
create_user() {
    # Retrieve the full name, username, and password from the function arguments
    fullname=$1
    username=$2
    password=$3

    # Check if the user already exists
    if id "$username" >/dev/null 2>&1; then
        echo "Skipped creating user '$username' because it already exists."
        return
    fi

    echo "Creating user '$username' with password '$password'."

    # Create the user with the specified full name and disabled password
    if adduser --gecos "$fullname" --disabled-password "$username"; then
        echo "-> Successfully created user '$username'."

        # Set the password for the newly created user. 
        # "chpasswd" changes the username acount from null to the password 
        echo "$username:$password" | chpasswd

        echo "-> Set password to '$password'."
    else
        echo "Error: Failed to create user '$username'."
    fi

    echo "\n\n"
}


# Function to check if group exists, if not create it
create_group_if_not_exists() {
    local group_name=$1
    # Check if it exists
    if ! getent group "$group_name" > /dev/null; then 
        groupadd "$group_name"
        echo "Group $group_name created."
    else
        echo "Group $group_name already exists."
    fi
}


group_assignment(){
    local username=$1
    local group=$2

    # id checks user groups, and grep checks if the user is in it
    # The user is added to the group if they aren't in it alredy
    # (n == name(s) | G == group(s) [togheter = names of groups] )
    if ! id -nG "$username" | grep -qw "$group"; then
        # User mod edits the user by add them to the group (a == append | G == group)
        usermod -aG "$group" "$username" 
        echo "User $username added to group $group."
    else
        echo "User $username is already in group $group."
    fi
    
}

# # Lists the members of different groups. Super stolen btw :) -ep
list_members() {
  local group=$1
  echo "### $group Group ###"
  getent group "$group" | cut -d: -f4 | tr ',' '\n' | while read -r user; do
    echo " * $user"
  done
  echo ""
}


# Create User  | Full name | username | Password |

echo "\nUsers:"

create_user  "Gustav Wells" guwe $standardPassword
create_user  "Alva Åberg" alab $standardPassword
create_user "Max Holmgren" maho  $standardPassword
create_user "Hanna Andersson" haan  $standardPassword
create_user "Albin Nyberg" alny  $standardPassword
create_user "Klara Holm" klho  $standardPassword
create_user "Elin Berggren" elbe  $standardPassword
create_user "Erik Berg" erbe  $standardPassword

echo "\nGroups:"

# Create groups | Group name |
create_group_if_not_exists $EMPLOYEES_GROUP
create_group_if_not_exists $FINANCE_GROUP
create_group_if_not_exists $EXECUTIVES_GROUP

echo "\nAssign to Groups:"
echo "->$EMPLOYEES_GROUP:"
group_assignment guwe $EMPLOYEES_GROUP
group_assignment alab $EMPLOYEES_GROUP
group_assignment maho $EMPLOYEES_GROUP
group_assignment haan $EMPLOYEES_GROUP
group_assignment alny $EMPLOYEES_GROUP
group_assignment klho $EMPLOYEES_GROUP
group_assignment elbe $EMPLOYEES_GROUP
group_assignment erbe $EMPLOYEES_GROUP

echo "\n->$FINANCE_GROUP:"
group_assignment haan $FINANCE_GROUP
group_assignment klho $FINANCE_GROUP
group_assignment erbe $FINANCE_GROUP

echo "\n->$EXECUTIVES_GROUP:"
group_assignment erbe $EXECUTIVES_GROUP
group_assignment maho $EXECUTIVES_GROUP

echo "\n->$SSH_GROUP:"
group_assignment erbe $SSH_GROUP
group_assignment alab $SSH_GROUP

echo "\n"
list_members "$EMPLOYEES_GROUP"
list_members "$FINANCE_GROUP"
list_members "$EXECUTIVES_GROUP"
