if [ "${1}" == "install" ]; then
    python3 -m pip install \
        jupyter jupyterlab ipython \
        plyvel psycopg2 datapackage-pipelines-elasticsearch \
        'https://github.com/OriHoch/dataflows/archive/specify-encoding-for-load.zip#egg=dataflows[speedup]' \
        'https://github.com/frictionlessdata/datapackage-pipelines/archive/2.0.0.zip#egg=datapackage-pipelines[speedup]' &&\
    python3 -m pip install -e .

elif [ "${1}" == "script" ]; then
    docker build -t ${DOCKER_IMAGE}:latest -t ${DOCKER_IMAGE}:${TRAVIS_COMMIT} .

    # ./render_notebook.sh QUICKSTART

elif [ "${1}" == "deploy" ]; then
    if [ "${TRAVIS_BRANCH}" == "master" ] &&\
       [ "${TRAVIS_TAG}" == "" ] &&\
       [ "${TRAVIS_PULL_REQUEST}" == "false" ]
    then
        docker push ${DOCKER_IMAGE}:latest &&\
        docker push ${DOCKER_IMAGE}:${TRAVIS_COMMIT} &&\
        travis_ci_operator.sh github-yaml-update \
            migdar-k8s master values.auto-updated.yaml '{"pipelines":{"image": "'${DOCKER_IMAGE}:${TRAVIS_COMMIT}'"}}' \
            "automatic update of migdar-data-pipelines" OriHoch/migdar-k8s &&\
        echo &&\
        echo Great Success &&\
        echo &&\
        echo ${DOCKER_IMAGE}:latest &&\
        echo ${DOCKER_IMAGE}:${TRAVIS_COMMIT}
    else
        echo Skipping deployment
    fi

    # travis_ci_operator.sh github-update self master "
    #     cp -f $PWD/QUICKSTART.md $PWD/QUICKSTART.ipynb ./ &&\
    #     git add QUICKSTART.md QUICKSTART.ipynb
    # " "update QUICKSTART notebook"

fi
