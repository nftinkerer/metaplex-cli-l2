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
## Run with: bash ./end-launch.sh

## Sets variables from .env
set -a
source <(cat .env | sed -e '/^#/d;/^\s*$/d' -e "s/'/'\\\''/g" -e "s/=\(.*\)/='\1'/g")
set +a

## Makes ASSETS and WHITELIST_JSON non relatative
ASSETS="$(pwd)/${ASSETS}"
WHITELIST_JSON="$(pwd)/${WHITELIST_JSON}"
PARTICIPATION_NFT_JSON="$(pwd)/${PARTICIPATION_NFT_JSON}"
PARTICIPATION_NFT_IMAGE="$(pwd)/${PARTICIPATION_NFT_IMAGE}"

FL_CLI="$CLI_PATH/src/fair-launch-cli.ts"

echo ""
read -r -p "<fair-launch-id>: " FAIR_LAUNCH_ID

if confirm "whoami"; then
  solana address --keypair $KEYPAIR --url $ENV
  solana balance --keypair $KEYPAIR --url $ENV
fi

if confirm "create_missing_sequences"; then
  ## Will show a <token-mint-address>
  ts-node $FL_CLI create_missing_sequences \
    -f $FAIR_LAUNCH_ID \
    --rpc-url "$RPC_URL" \
    --env $ENV \
    --keypair $KEYPAIR
fi

if confirm "create_fair_launch_lottery"; then
  ## Will show a <token-mint-address>
  ts-node $FL_CLI create_fair_launch_lottery \
    -f $FAIR_LAUNCH_ID \
    --whitelist-json $WHITELIST_JSON \
    --rpc-url "$RPC_URL" \
    --env $ENV \
    --keypair $KEYPAIR
fi

if confirm "show_lottery"; then
  ## Will show a <token-mint-address>
  ts-node $FL_CLI show_lottery \
    -f $FAIR_LAUNCH_ID \
    --rpc-url "$RPC_URL" \
    --env $ENV \
    --keypair $KEYPAIR
fi

if confirm "start_phase_three"; then
  ## Will show a <token-mint-address>
  ts-node $FL_CLI start_phase_three \
    -f $FAIR_LAUNCH_ID \
    --env $ENV \
    --keypair $KEYPAIR
fi

## Unsets variables from .env
unset $(grep -v '^#' .env | sed -E 's/(.*)=.*/\1/' | xargs -d '\n')