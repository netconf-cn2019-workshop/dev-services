#!/bin/bash

ARG_PROJECT_SUFFIX=
ARG_ENV=

while :; do
    case $1 in
        --env)
            if [ -n "$2" ]; then
                ARG_ENV=$2
                shift
            else
                printf 'ERROR: "--env" requires a non-empty value.\n' >&2
                exit 255
            fi
            ;;
        --suffix)
            if [ -n "$2" ]; then
                ARG_PROJECT_SUFFIX=$2
                shift
            else
                printf 'ERROR: "--suffix" requires a non-empty value.\n' >&2
                exit 255
            fi
            ;;
        *) # Default case: If no more options then break out of the loop.
            break
    esac

    shift
done

if [ -z "$ARG_ENV" ]; then
    echo "Please use '--env' parameter to sepecify a environment."
    exit 1
fi

if [ -z "$ARG_PROJECT_SUFFIX" ]; then
    echo "Please use '--suffix' parameter to sepecify a project suffix."
    exit 1
fi


NAMESPACES=$(kubectl get namespaces)

create_ns(){
    local NAME
    NAME=$1
    EXISTS=$(echo $NAMESPACES | grep $NAME)
    if [ -z "$EXISTS" ]; then
        kubectl create namespace $NAME || true
    fi
}

create_ns dev-$ARG_PROJECT_SUFFIX
create_ns stage-$ARG_PROJECT_SUFFIX
create_ns prod-$ARG_PROJECT_SUFFIX
create_ns cicd-$ARG_PROJECT_SUFFIX

kubectl config set-context $(kubectl config current-context) --namespace "$ARG_ENV-$ARG_PROJECT_SUFFIX"
kubectl apply -f ./service-infra/infra.yaml

kubectl rollout status deployment/sqlserver
sleep 5

__SQLSERVER_POD=$(kubectl get pods -l app=sqlserver -o=jsonpath='{.items[*].metadata.name}')
kubectl exec $__SQLSERVER_POD -- /bin/bash -c '/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -d master -i /var/init-script/init-schema.sql'