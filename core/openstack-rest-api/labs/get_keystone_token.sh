#!/bin/bash

REQUEST_BODY=$(cat <<EOF
{
  "auth": {
    "identity": {
      "methods": ["password"],
      "password": {
        "user": {
          "name": "$OS_USERNAME",
          "domain": {
            "name": "$OS_USER_DOMAIN_NAME"
          },
          "password": "$OS_PASSWORD"
        }
      }
    },
    "scope": {
      "project": {
        "name": "$OS_PROJECT_NAME",
        "domain": {
          "name": "$OS_PROJECT_DOMAIN_ID"
        }
      }
    }
  }
}
EOF
)

RESPONSE_HEADERS=$(curl -sSL -D - -H "Content-Type: application/json" -d "$REQUEST_BODY" "$OS_AUTH_URL/v3/auth/tokens" -o /dev/null)

# The token is returned in the "x-subject-token" header
TOKEN=$(echo "$RESPONSE_HEADERS" | awk -v IGNORECASE=1 '/x-subject-token/ {print $2}' | tr -d '\r')

echo "Token: $TOKEN"
