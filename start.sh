#!/bin/bash

aws s3 cp ${S3_VCL_FILE} /etc/varnish/default.vcl

RELOAD_VCL=1

# Start varnish and log

mkdir -p ${VARNISH_CACHE_FOLDER}

varnishd -a 0.0.0.0:${VARNISH_PORT} -T 127.0.0.1:6082 -f /etc/varnish/default.vcl -s file,${VARNISH_CACHE_FOLDER}/varnish_cache.bin,${VARNISH_CACHE_SIZE}

varnishlog
