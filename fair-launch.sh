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
## Run with: bash ./fair-launch.sh

## Sets variables from .env
export $(grep -v '^#' .env | xargs -d '\n')

## Makes ASSETS non relatative
ASSETS="$(pwd)/${ASSETS}"

## Makes sure dependencies are installed for cli
## npm install --loglevel=error

FL_CLI="$CLI_PATH/src/fair-launch-cli.ts"
CM_CLI="$CLI_PATH/src/candy-machine-cli.ts"

if confirm "new_fair_launch"; then
  ## Will show a <fair-launch-id>
  ts-node $FL_CLI new_fair_launch \
    --uuid test03 \
    --fee 0.1 \
    --price-range-start 0.1 \
    --price-range-end 2 \
    --anti-rug-reserve-bp 5000 \
    --anti-rug-token-requirement 1 \
    --self-destruct-date "11 Oct 2021 09:00:00 GMT" \
    -pos "2021 Oct 10 17:10:00 CDT" \
    -poe "2021 Oct 10 17:25:00 CDT" \
    -pte "2021 Oct 10 17:40:00 CDT" \
    --tick-size 0.1 \
    --number-of-tokens 2 \
    --env $ENV \
    --keypair $KEYPAIR
fi

echo ""
read -r -p "<fair-launch-id>: " FAIR_LAUNCH_ID

if confirm "show"; then
  ## Will show a <token-mint-address>
  ts-node $FL_CLI show \
    -f $FAIR_LAUNCH_ID \
    --env $ENV \
    --keypair $KEYPAIR
fi

echo ""
read -r -p "<token-mint-address>: " TOKEN_MINT_ADDRESS

if confirm "upload"; then
  ts-node $CM_CLI upload $ASSETS \
    --env $ENV \
    --keypair $KEYPAIR
fi

if confirm "verify"; then
  ts-node $CM_CLI verify \
    --env $ENV \
    --keypair $KEYPAIR
fi

if confirm "create_token_account"; then
  spl-token create-account $TOKEN_MINT_ADDRESS
fi

echo ""
read -r -p "<token-account>: " TOKEN_ACCOUNT

if confirm "create_candy_machine"; then
  ts-node $CM_CLI create_candy_machine \
    --price 1 \
    --spl-token $TOKEN_MINT_ADDRESS \
    --spl-token-account $TOKEN_ACCOUNT \
    --env $ENV \
    --keypair $KEYPAIR
fi

if confirm "update_candy_machine"; then
  ts-node $CM_CLI update_candy_machine \
    --date "9 Oct 2021 00:45:00 CDT" \
    --env $ENV \
    --keypair $KEYPAIR
fi

echo ""
echo "Now, go use the candy machine id and fair launch id to setup your web app:"
echo "  FAIR_LAUNCH_ID: $FAIR_LAUNCH_ID"
echo ""
echo "Make sure to finish other administrative commands after phase two ends!"

## Unsets variables from .env
unset $(grep -v '^#' .env | sed -E 's/(.*)=.*/\1/' | xargs -d '\n')