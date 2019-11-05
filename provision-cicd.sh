#!/bin/bash

echo "###############################################################################"
echo "#  MAKE SURE YOU ARE LOGGED IN:                                               #"
echo "#  kubectl cluster-info                                                             #"
echo "###############################################################################"

function usage() {
    echo
    echo "Usage:"
    echo " $0 [command] [options]"
    echo " $0 --help"
    echo
    echo "Example:"
    echo " $0 deploy --suffix mydemo"
    echo
    echo "COMMANDS:"
    echo "   deploy                   Set up the demo projects and deploy demo apps"
    echo "   delete                   Clean up and remove demo projects and objects"
    echo 
    echo "OPTIONS:"
    echo "   --suffix [suffix]  Required    Suffix to be added to demo project names e.g. ci-SUFFIX."
    echo
}

ARG_PROJECT_SUFFIX=
ARG_COMMAND=

while :; do
    case $1 in
        deploy)
            ARG_COMMAND=deploy
            ;;
        delete)
            ARG_COMMAND=delete
            ;;
        --suffix)
            if [ -n "$2" ]; then
                ARG_PROJECT_SUFFIX=$2
                shift
            else
                printf 'ERROR: "--suffix" requires a non-empty value.\n' >&2
                usage
                exit 255
            fi
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --)
            shift
            break
            ;;
        -?*)
            printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
            shift
            ;;
        *) # Default case: If no more options then break out of the loop.
            break
    esac

    shift
done


################################################################################
# CONFIGURATION                                                                #
################################################################################

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

#   jenkins: 0.5G 2G
#   gogs: 0.5G 1G
#   sonarqube: 1.25G 2.5G
#   nexus: 0.5G 2Gi
function deploy() {
    create_ns dev-$ARG_PROJECT_SUFFIX
    create_ns stage-$ARG_PROJECT_SUFFIX
    create_ns prod-$ARG_PROJECT_SUFFIX
    create_ns cicd-$ARG_PROJECT_SUFFIX

  sleep 2

  echo 'Provisioning applications...'
  kcd cicd-$ARG_PROJECT_SUFFIX
  
  local _SED_EXPR="s/deploy_suffix=.*/deploy_suffix=$ARG_PROJECT_SUFFIX/g"
  if [ "$(uname)" == "Darwin" ]; then
    sed -i '' $_SED_EXPR ./cicd-infra/vars
  else
    sed -i $_SED_EXPR ./cicd-infra/vars
  fi
  
  ./tmpl.sh ./cicd-infra/jenkins.yaml ./cicd-infra/vars | kubectl apply -f -
  sleep 3

  ./tmpl.sh ./cicd-infra/sonarqube.yaml ./cicd-infra/vars | kubectl apply -f -
  sleep 3

  ./tmpl.sh ./cicd-infra/nexus.yaml ./cicd-infra/vars | kubectl apply -f -
  sleep 3

  ./tmpl.sh ./cicd-infra/gogs.yaml ./cicd-infra/vars | kubectl apply -f -
  sleep 3

  echo "Provisioning installer"
  ./tmpl.sh ./cicd-infra/cicd-installer.yaml ./cicd-infra/vars | kubectl apply -f -

  echo "Wait for installing..."
  sleep 3
  kubectl wait --for=condition=complete --timeout=900s job/cicd-installer

  kubectl logs pods/$(kubectl get pods -o=jsonpath='{.items[0].metadata.name}' -l job-name=cicd-installer)
}

function kcd() {
  kubectl config set-context $(kubectl config current-context) --namespace $1
}

function echo_header() {
  echo
  echo "########################################################################"
  echo $1
  echo "########################################################################"
}

################################################################################
# MAIN: DEPLOY Workshop                                                   #
################################################################################


START=`date +%s`

echo_header ".NET Core Workshop on Kubernetes ($(date))"

case "$ARG_COMMAND" in
    delete)
        echo "Delete demo..."
        kubectl delete namespace dev-$ARG_PROJECT_SUFFIX stage-$ARG_PROJECT_SUFFIX prod-$ARG_PROJECT_SUFFIX cicd-$ARG_PROJECT_SUFFIX
        echo
        echo "Delete completed successfully!"
        kcd default
        ;;
      
    deploy)
        echo "Deploying..."
        deploy
        echo
        echo "Provisioning completed successfully!"
        kcd cicd-$ARG_PROJECT_SUFFIX
        ;;
        
    *)
        echo "Invalid command specified: '$ARG_COMMAND'"
        usage
        ;;
esac


END=`date +%s`
echo "(Completed in $(( ($END - $START)/60 )) min $(( ($END - $START)%60 )) sec)"
echo 

