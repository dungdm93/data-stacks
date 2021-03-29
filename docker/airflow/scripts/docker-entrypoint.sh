#!/bin/bash
set -eo pipefail

run_aio() {
    airflow-tools wait database
    AIRFLOW__CORE__LOAD_EXAMPLES=False airflow db upgrade

    ln -sfn /etc/airflow/runit/webserver /etc/service/webserver
    ln -sfn /etc/airflow/runit/scheduler /etc/service/scheduler

    local EXECUTOR=$(airflow-tools get-config core executor)
    EXECUTOR="${EXECUTOR^^}"        # uppercase
    EXECUTOR="${EXECUTOR%EXECUTOR}" # remove EXECUTOR suffix

    if [ "$EXECUTOR" = "CELERY" ]; then
        ln -sfn /etc/airflow/runit/worker /etc/service/worker
        ln -sfn /etc/airflow/runit/flower /etc/service/flower

        airflow-tools wait broker
    fi

    local LOGGING_DIR="$(airflow-tools get-config logging base_log_folder)"
    local LOGGING_REMOTE="$(airflow-tools get-config logging remote_logging)"
    LOGGING_REMOTE="${LOGGING_REMOTE^^}"

    if [ "${LOGGING_REMOTE}" = "FALSE" ] && [ -d "${LOGGING_DIR}" ]; then
        chown -R airflow: "${LOGGING_DIR}"
    fi

    exec runsvdir -P /etc/service/
}

case "$1" in
    ""|aio)
        run_aio
        ;;
    scheduler)
        airflow-tools wait database
        AIRFLOW__CORE__LOAD_EXAMPLES=False airflow db upgrade
        exec airflow scheduler
        ;;
    webserver)
        airflow-tools wait database
        exec airflow webserver
        ;;
    celery)
        airflow-tools wait broker
        exec airflow "$@"
        ;;
    version)
        exec airflow version
        ;;
    *)
        exec "$@"
        ;;
esac
