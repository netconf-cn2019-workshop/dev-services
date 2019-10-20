#!/bin/bash

echo "###############################################################################"
echo "#  MAKE SURE YOU ARE LOGGED IN:                                               #"
echo "#  k cluster-info                                                             #"
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
        --project-suffix)
            if [ -n "$2" ]; then
                ARG_PROJECT_SUFFIX=$2
                shift
            else
                printf 'ERROR: "--project-suffix" requires a non-empty value.\n' >&2
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

PRJ_SUFFIX="$ARG_PROJECT_SUFFIX"
if [-z "$PRJ_SUFFIX"]; then
    echo "Please use '--project-suffix' parameter to sepecify a project suffix."
    exit 1
fi


#   jenkins: 0.5G 2G
#   gogs: 0.5G 1G
#   sonarqube: 1.25G 2.5G
#   nexus: 0.5G 2Gi
function deploy() {
  kubectl create namespace dev-$PRJ_SUFFIX
  kubectl create namespace stage-$PRJ_SUFFIX
  kubectl create namespace cicd-$PRJ_SUFFIX

  sleep 2

  echo 'Provisioning applications...'
  kcd cicd-$PRJ_SUFFIX


  ./templates/tmpl.sh ./templates/jenkins.yaml ./templates/vars | k apply -f -
  sleep 3

  ./templates/tmpl.sh ./templates/gogs.yaml ./templates/vars | k apply -f -
  sleep 3

  ./templates/tmpl.sh ./templates/sonarqube.yaml ./templates/vars | k apply -f -
  sleep 3

  ./templates/tmpl.sh ./templates/nexus.yaml ./templates/vars | k apply -f -
  sleep 3

  echo "Provisioning installer"
  ./templates/tmpl.sh ./template/cicd-installer.yaml ./templates/vars | kubectl create -f
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
# MAIN: DEPLOY CICD Workshop                                                   #
################################################################################

pushd ~ >/dev/null
START=`date +%s`

echo_header ".NET Core CI/CD Workshop on Kubernetes ($(date))"

case "$ARG_COMMAND" in
    delete)
        echo "Delete demo..."
        kubectl delete namespace dev-$PRJ_SUFFIX stage-$PRJ_SUFFIX cicd-$PRJ_SUFFIX
        echo
        echo "Delete completed successfully!"
        kcd default
        ;;
      
    deploy)
        echo "Deploying..."
        deploy
        echo
        echo "Provisioning completed successfully!"
        kcd cicd-$PRJ_SUFFIX
        ;;
        
    *)
        echo "Invalid command specified: '$ARG_COMMAND'"
        usage
        ;;
esac

popd >/dev/null

END=`date +%s`
echo "(Completed in $(( ($END - $START)/60 )) min $(( ($END - $START)%60 )) sec)"
echo 

