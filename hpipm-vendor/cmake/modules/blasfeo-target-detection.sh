#!/bin/bash

CPU_INFO="$(cat /proc/cpuinfo)"

if [ ! -z "$(echo ${CPU_INFO} | grep Intel)" ]; then
    if [ ! -z "$(echo ${CPU_INFO} | grep avx2)" ]; then
        TARGET=X64_INTEL_HASWELL
    elif [ ! -z "$(echo ${CPU_INFO} | grep avx)" ]; then
        TARGET=X64_INTEL_SANDY_BRIDGE
    elif [ ! -z "$(echo ${CPU_INFO} | grep ssse3)" ]; then
        TARGET=X64_INTEL_CORE
    else
        TARGET=GENERIC
    fi
elif [ ! -z "$(echo ${CPU_INFO} | grep AMD)" ]; then
    if [ ! -z "$(echo ${CPU_INFO} | grep avx | grep fma)" ]; then
        TARGET=X64_AMD_BULLDOZER
    else
        TARGET=GENERIC
    fi
else
    TARGET=GENERIC
fi

printf "${TARGET}"