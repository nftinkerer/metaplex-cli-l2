#!/bin/sh

confirm (){
  echo ""
  read -p "Confirm $1 (y/n/c): " choice
    case "$choice" in 
      y|Y ) return 0;; # 0 = true
      n|N ) return 1;; # 1 = false
      c|C ) exit;;
      * ) return confirm "$1";;
    esac
}

## Guides through parts of this https://hackmd.io/FxCiD20ETZeMbfA8on9WMg?view#Fair-Launch-Protocol
## Run with: bash ./withdraw-funds.sh

## Sets variables from .env
set -a
source <(cat .env | sed -e '/^#/d;/^\s*$/d' -e "s/'/'\\\''/g" -e "s/=\(.*\)/='\1'/g")
set +a

## Makes ASSETS and WHITELIST_JSON non relatative
ASSETS="$(pwd)/${ASSETS}"
WHITELIST_JSON="$(pwd)/${WHITELIST_JSON}"

FL_CLI="$CLI_PATH/src/fair-launch-cli.ts"

echo ""
read -r -p "<fair-launch-id>: " FAIR_LAUNCH_ID

if confirm "punch_and_refund_all_outstanding"; then
  ## Will show a <token-mint-address>
  ts-node $FL_CLI punch_and_refund_all_outstanding \
    -f $FAIR_LAUNCH_ID \
    --rpc-url "$RPC_URL" \
    --env $ENV \
    --keypair $KEYPAIR
fi

if confirm "withdraw_funds"; then
  ## Will show a <token-mint-address>
  ts-node $FL_CLI withdraw_funds \
    -f $FAIR_LAUNCH_ID \
    --env $ENV \
    --keypair $KEYPAIR
fi

## Unsets variables from .env
unset $(grep -v '^#' .env | sed -E 's/(.*)=.*/\1/' | xargs -d '\n')