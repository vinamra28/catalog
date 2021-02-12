#!/usr/bin/env bash

set -x

# Configure the number of parallel tests running at the same time, start from 0
MAX_NUMBERS_OF_PARALLEL_TASKS=4 # => 5


set -ex
set -o pipefail

all_tests=$(echo task/*/*/tests)

function detect_new_changed_tasks() {
    # detect for changes in tests dir of the task
    # git --no-pager diff --name-only master..610-orka|grep 'task/[^\/]*/[^\/]*/tests/[^/]*'|xargs -I {} dirname {}| rev | cut -d'/' -f2- | rev
    git --no-pager diff --name-only|grep 'task/[^\/]*/[^\/]*/tests/[^/]*'|xargs -I {} dirname {}|sed 's/\(tests\).*/\1/g'
    # detect for changes in the task manifest
    git --no-pager diff --name-only|grep 'task/[^\/]*/[^\/]*/*[^/]*.yaml'|xargs -I {} dirname {}|awk '{print $1"/tests"}'
}

if [[ -z ${TEST_RUN_ALL_TESTS} ]];then
    all_tests=$(detect_new_changed_tasks|sort -u || true)
    [[ -z ${all_tests} ]] && {
        echo "No tests has been detected in this PR. exiting."
    }
fi

function test_tasks {
    local cnt=0
    local task_to_tests=""

    for runtest in $@;do
        task_to_tests="${task_to_tests} ${runtest}"
        if [[ ${cnt} == "${MAX_NUMBERS_OF_PARALLEL_TASKS}" ]];then
            echo "${task_to_tests}"
            cnt=0
            task_to_tests=""
            continue
        fi
        cnt=$((cnt+1))
    done

    # in case if there are some remaining tasks
    if [[ -n ${task_to_tests} ]];then
        echo "${task_to_tests}"
    fi
}

function test_yaml_can_install() {
    # Validate that all the Task CRDs in this repo are valid by creating them in a NS.
    readonly ns="task-ns"
    all_tasks="$*"
    kubectl create ns "${ns}" || true
    local runtest
    for runtest in ${all_tasks}; do
        # remove task/ from beginning
        local runtestdir=${runtest#*/}
        # remove /0.1/tests from end
        local testname=${runtestdir%%/*}
        runtest=${runtest//tests}
        echo "---------------"
        [ ! -d "${runtest%%/*}/${testname}" ] && continue
        runtest="${runtest}${testname}.yaml"
        skipit=
        for ignore in ${TEST_YAML_IGNORES};do
            [[ ${ignore} == "${testname}" ]] && skipit=True
        done
        [[ -n ${skipit} ]] && break
        echo "Checking ${testname}"
        kubectl -n ${ns} apply -f <(sed "s/namespace:.*/namespace: task-ns/" "${runtest}")
    done
}

# test_tasks "${all_tests}"
test_yaml_can_install "${all_tests}"

# success
