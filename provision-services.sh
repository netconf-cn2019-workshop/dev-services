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

 _SED_EXPR="s/DEPLOY_SUFFIX=.*/DEPLOY_SUFFIX=$ARG_ENV-$ARG_PROJECT_SUFFIX/g"
  if [ "$(uname)" == "Darwin" ]; then
    sed -i '' $_SED_EXPR ./services/vars
  else
    sed -i $_SED_EXPR ./services/vars
  fi


ENV_NAME='Production'
if [ "$ARG_ENV" == "dev" ] ; then
    ENV_NAME='Development'
fi
if [ "$ARG_ENV" == "stage" ]; then
    ENV_NAME='Stage'
fi

 _SED_EXPR="s/ENVIRONMENT_NAME=.*/ENVIRONMENT_NAME=$ENV_NAME/g"
  if [ "$(uname)" == "Darwin" ]; then
    sed -i '' $_SED_EXPR ./services/vars
  else
    sed -i $_SED_EXPR ./services/vars
  fi

kubectl config set-context $(kubectl config current-context) --namespace "$ARG_ENV-$ARG_PROJECT_SUFFIX"
SERVICES=`cat ./services/service-list`

for SVC in $SERVICES; do
    PROJ=$(echo $SVC | cut -d ':' -f 1)
    IAMGE_VERSION=$(echo $SVC | cut -d ':' -f 3)

    _SED_EXPR="s/IMAGE_VERSION=.*/IMAGE_VERSION=$IAMGE_VERSION/g"
    if [ "$(uname)" == "Darwin" ]; then
        sed -i '' $_SED_EXPR ./services/vars
    else
        sed -i $_SED_EXPR ./services/vars
    fi

    echo "Deploying $PROJ version $IAMGE_VERSION..."
    ./tmpl.sh ../$PROJ/k8s.yaml ./services/vars | kubectl apply -f -
    sleep 3
done

