#!/bin/bash
#read password - password by input
password="yourpassword"
username="yourusername"
create_user='db.createUser( { user: "Admin", pwd: "password", roles: [ { role: "root", db: "admin" } ] } )'
create_user=${create_user/"password"/$password}
create_user=${create_user/"password"/$user}
#function which start mongo shell and parse command create_user
function user_creation {
    mongo --host 192.168.100.4 <<EOF
    $create_user
EOF
}
