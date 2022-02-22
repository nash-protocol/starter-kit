API_ENDPOINT_TESTNET="https://algoapiv1.herokuapp.com"
TEMPLATE_NAME="lite"
reset() {
	test ! -d ".reach" || rm -rvf "${_}"
	test ! -f "np.sh" || source "${_}"
  compile
}
connector () {
        local i=$( grep -n ${1} -e _ALGO | head -1 | cut '-d:' '-f1' ) 
        local n=$(( $( grep -n ${1} -e _ETH | head -1 | cut '-d:' '-f1' ) - 1 )) 
        sed -n "${i},${n}p" ${1}
        echo "console.log(JSON.stringify({ALGO:_ALGO, template: '${TEMPLATE_NAME}'}))"
}
compile () {
        REACH_VERSION=0.1.7 ./reach compile ${infile:-index}.rsh --install-pkgs
        REACH_VERSION=0.1.7 ./reach compile ${infile:-index}.rsh "${@}"
}
eject () {
        _ () {
                node <(connector "${1}")
        }
        _ build/${infile:-index}.main.mjs
}
plan() {
  cat << EOF
{
  "id": "${plan_id}"
}
EOF
}
v2-register() {
  curl -X POST "${API_ENDPOINT_TESTNET}/api/v2/register" -H 'Content-Type: application/json' -d @<( eject ) 
}
v2-launch() {
  local plan_id="${1}"
  curl -X POST "${API_ENDPOINT_TESTNET}/api/v2/launch" -H 'Content-Type: application/json' -d @<( plan ) 
}
v2-apps() {
  local plan_id="${1}"
  curl -X POST "${API_ENDPOINT_TESTNET}/api/v2/apps" -H 'Content-Type: application/json' -d @<( plan )
}
v2-verify() {
  local plan_id="${1}"
  curl -X POST "${API_ENDPOINT_TESTNET}/api/v2/verify" -H 'Content-Type: application/json' -d @<( plan )
}
v1-launch () {
        curl -X POST "${API_ENDPOINT_TESTNET}/api/v1/launch" -H 'Content-Type: application/json' -d @<( eject ) 
}
devnet() {
        local -x REACH_CONNECTOR_MODE=ALGO-devnet
        ./reach devnet
}
run() {
        local -x REACH_CONNECTOR_MODE=ALGO-devnet
        node index.mjs index
}
get-reach() {
  test -f "reach" || {
    curl https://docs.reach.sh/reach -o reach --silent
    chmod +x reach
  }
}
np () {
        local infile="${1:-index}" 
        test -f "${infile:-index}.rsh" || return
        main () {
          get-reach
          compile && launch
        }
        main
}
