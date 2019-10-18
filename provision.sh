#!/bin/bash

echo "###############################################################################"
echo "#  MAKE SURE YOU ARE LOGGED IN:                                               #"
echo "#  $ oc login http://console.your.openshift.com                               #"
echo "###############################################################################"

function usage() {
    echo
    echo "Usage:"
    echo " $0 [command] [options]"
    echo " $0 --help"
    echo
    echo "Example:"
    echo " $0 deploy --project-suffix mydemo"
    echo
    echo "COMMANDS:"
    echo "   deploy                   Set up the demo projects and deploy demo apps"
    echo "   delete                   Clean up and remove demo projects and objects"
    echo 
    echo "OPTIONS:"
    echo "   --user [username]          Optional    The admin user for the demo projects. Required if logged in as system:admin"
    echo "   --project-suffix [suffix]  Optional    Suffix to be added to demo project names e.g. ci-SUFFIX. If empty, user will be used as suffix"
    echo "   --ephemeral                Optional    Deploy demo without persistent storage. Default false"
    echo
}

ARG_USERNAME=
ARG_PROJECT_SUFFIX=
ARG_COMMAND=
# ARG_EPHEMERAL=false

while :; do
    case $1 in
        deploy)
            ARG_COMMAND=deploy
            ;;
        delete)
            ARG_COMMAND=delete
            ;;
        --user)
            if [ -n "$2" ]; then
                ARG_USERNAME=$2
                shift
            else
                printf 'ERROR: "--user" requires a non-empty value.\n' >&2
                usage
                exit 255
            fi
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
        # --ephemeral)
        #     ARG_EPHEMERAL=true
        #     ;;
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

LOGGEDIN_USER=$(id -un)
PRJ_SUFFIX=${ARG_PROJECT_SUFFIX:-`echo $LOGGEDIN_USER | sed -e 's/[-@].*//g'`}

function deploy() {
  kubectl create namespace dev-$PRJ_SUFFIX
  kubectl create namespace stage-$PRJ_SUFFIX
  kubectl create namespace cicd-$PRJ_SUFFIX

  sleep 2

  echo 'Provisioning Jenkins...'
  kcd cicd-$PRJ_SUFFIX
  # todo: replace vars
  ./templates/tmpl.sh ./templates/jenkins.yaml ./templates/vars | k apply -f -
  sleep 5

  ./templates/tmpl.sh ./templates/gogs.yaml ./templates/vars | k apply -f -
  sleep 5
  
  ./templates/tmpl.sh ./templates/sonarqube.yaml ./templates/vars | k apply -f -
  sleep 5

  echo "Provisioning installer"
  oc new-app -f ./cicd-template.yaml -p DEV_PROJECT=dev-$PRJ_SUFFIX -p STAGE_PROJECT=stage-$PRJ_SUFFIX  -n cicd-$PRJ_SUFFIX 
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