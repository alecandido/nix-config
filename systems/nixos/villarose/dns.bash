zone_id=$(jq .zone_id -r <"$1")
dns_record_id=$(jq .dns_record_id -r <"$1")
api_token=$(jq .api_token -r <"$1")
data=$(
	cat <<EOF
{
  "comment": "Domain verification record",
  "name": "villarose.annibale.dev",
  "proxied": true,
  "settings": {},
  "tags": [],
  "ttl": 3600,
  "content": "$(curl -s https://v6.ipinfo.io/ip)",
  "type": "AAAA"
}
EOF
)

curl --request PUT \
	--url "https://api.cloudflare.com/client/v4/zones/${zone_id}/dns_records/${dns_record_id}" \
	--header 'Content-Type: application/json' \
	--header "X-Auth-Email: ${api_token}" \
	--data "$data"
