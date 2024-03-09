user=$(jq .user -r < "$1")
pwd=$(jq .pwd -r < "$1")
url="https://${user}:${pwd}\
     @domains.google.com/nic/update\
     ?hostname=villarose.annibale.dev\
     &myip=$(curl -s https://v6.ipinfo.io/ip)"

curl -s --request POST "${url// /}"
