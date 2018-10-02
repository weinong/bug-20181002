#!/bin/bash

targets=("svc1" "svc2" "svc3" "svc4" "svc5")
cleanup=no
offset=0
kubeconfig=$1

while true; do

    for i in ${!targets[@]}; do
        svc=${targets[$i]}
        j=$((i-4))
        prev=${targets[$j]}

        if [[ $offset -eq 3 ]]; then
            cleanup=yes
        fi
        offset=$((offset+1))
        
        if [[ $cleanup == "yes" ]]; then
            echo deleting $prev
            kubectl --kubeconfig=${kubeconfig} delete svc "$prev-svc"
        fi

        t1=`date +%s`
        echo creating $svc
        kubectl --kubeconfig=${kubeconfig} apply -f "$svc.yaml"
        sleep 1

        while true; do
            ret=$(kubectl --kubeconfig=${kubeconfig} get svc "$svc-svc" --no-headers)
            echo "${ret}" | grep pending
            ret=$?
            if [ $ret -eq 1 ]
            then
                t2=`date +%s`
                elapsed=$((t2-t1))
                echo "Elapsed ${elapsed} seconds"
                break
            else
                echo sleep 5 seconds
                sleep 5
            fi
        done
        sleep 5
    done

done
