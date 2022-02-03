compile () {
        REACH_VERSION=0.1.7 ./reach compile ${infile:-index}.rsh --install-pkgs
        REACH_VERSION=0.1.7 ./reach compile ${infile:-index}.rsh
}
connector () {
        local i=$( grep -n ${1} -e _ALGO | head -1 | cut '-d:' '-f1' ) 
        local n=$(( $( grep -n ${1} -e _ETH | head -1 | cut '-d:' '-f1' ) - 1 )) 
        sed -n "${i},${n}p" ${1}
        echo "console.log(JSON.stringify({ALGO:_ALGO}))"
}
eject () {
        _ () {
                node <(connector "${1}")
        }
        _ build/${infile:-index}.main.mjs
}
launch () {
        curl -X POST https://algoapiv1.herokuapp.com/api/v1/launch2 -H 'Content-Type: application/json' -d @<( eject ) 
}
np () {
        local infile="${1:-index}" 
        test -f "${infile:-index}.rsh" || return
        main () {
                test -f "reach" || {
                        curl https://docs.reach.sh/reach -o reach --silent
                        chmod +x reach
                }
                compile && launch
        }
        main
}
