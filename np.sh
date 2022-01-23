np () {
        local infile="${1:-template}" 
        test -f "${infile}.rsh" || return
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
                _ build/${infile}.main.mjs
        }
        launch () {
                curl -X POST http://algoapiv1.herokuapp.com/api/v1/launch2 -H 'Content-Type: application/json' -d @<( eject )
        }
        compile () {
                REACH_VERSION=0.1.7 ./reach compile ${infile}.rsh
        }
        main () {
                test -f "reach" || {
                        curl https://docs.reach.sh/reach -o reach --silent
                        chmod +x reach
                }
                compile && launch
        }
        main
}