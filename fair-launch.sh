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

echo ""
echo "Make sure to wait between some of these commands!"
echo "  (If they fail, it's fine, just restart cli and skip commands before the fail)"
echo "Gl ser :D"
echo ""

if confirm "new_fair_launch"; then
  ## Will show a <fair-launch-id>
  ts-node $FL_CLI new_fair_launch \
    --uuid $LAUNCH_UUID \
    --fee $BIDFEE \
    --price-range-start $PRICE_RANGE_START \
    --price-range-end $PRICE_RANGE_END \
    --anti-rug-reserve-bp $ANTI_RUG_RESERVE_BP \
    --anti-rug-token-requirement $ANTI_RUG_TOKEN_REQUIREMENT \
    --self-destruct-date $DATE_SELFDESTRUCT \
    -pos $DATE_PHASEONE_START \
    -poe $DATE_PHASEONE_END \
    -pte $DATE_PHASETWO_END \
    --tick-size $PRICE_RANGE_TICK_SIZE \
    --number-of-tokens $NUM_TOKENS \
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
    --date $DATE_CANDYMACHINE_START \
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