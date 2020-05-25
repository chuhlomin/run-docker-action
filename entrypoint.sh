#/bin/sh

set -e

ENVS=""
for env in $(echo ${INPUT_ENVS} | jq -r '. | to_entries[] | "\(.key)=\"\(.value)\""')
do
    ENVS="${ENVS} --env ${env}"
done

SECRET_ENVS=""
for env in $(printenv | grep "SECRET_")
do
    if [[ ${env:0:7} == "SECRET_" ]] # len("SECRET_") = 7
    then
        pair=${env:7}
        SECRET_ENVS="${SECRET_ENVS} --env ${pair%%=*}=\"${pair#*=}\""
    fi
done

VOLUMES=""
for mount in $(echo ${INPUT_MOUNTS} | tr "," "\n")
do
    VOLUMES="${VOLUMES} --volume ${mount}"
done

LOG_DRIVER=""
if [ ! -z $INPUT_LOG_DRIVER ];
then
    LOG_DRIVER="--log-driver ${INPUT_LOG_DRIVER}"
fi

LOG_OPT=""
for opt in $(echo ${INPUT_LOG_OPT} | jq -r '. | to_entries[] | "\(.key)=\"\(.value)\""')
do
    LOG_OPT="${LOG_OPT} --log-opt ${opt}"
done

if [ -z "$INPUT_EXPOSE" ]; then EXPOSE=""; else EXPOSE="--expose ${INPUT_EXPOSE}"; fi
if [ -z "$INPUT_RESTART" ]; then RESTART=""; else RESTART="--restart ${RESTART}"; fi

echo "${SSH_KEY}" > /key
chmod 600 /key

if [ -z $INPUT_CONTAINER_NAME ] && [ ! -z $INPUT_DOCKER_NETWORK ];
then
    INPUT_CONTAINER_NAME="$INPUT_NETWORK_ALIAS"
fi

NETWORK_ALIAS=""
if [ ! -z $INPUT_NETWORK_ALIAS ];
then
    NETWORK_ALIAS="--network-alias ${INPUT_NETWORK_ALIAS}"
fi

NETWORK=""
if [ ! -z $INPUT_NETWORK ];
then
    NETWORK="--network ${INPUT_NETWORK}"
fi

SUDO=""
if [[ "$INPUT_SUDO" == "true" ]];
then
    SUDO="sudo"
fi

ssh -o "StrictHostKeyChecking=no" ${INPUT_USERNAME}@${INPUT_SERVER} -i /key "${SUDO} docker pull ${INPUT_IMAGE} && \
    ${SUDO} docker stop $INPUT_CONTAINER_NAME || true && \
    ${SUDO} docker wait $INPUT_CONTAINER_NAME || true && \
    ${SUDO} docker rm $INPUT_CONTAINER_NAME || true && \
    ${SUDO} docker run --rm --detach --name $INPUT_CONTAINER_NAME \
        $RESTART $EXPOSE $ENVS $SECRET_ENVS $VOLUMES \
        $NETWORK $NETWORK_ALIAS \
        $LOG_DRIVER $LOG_OPT \
        $INPUT_IMAGE"
