#!/bin/bash

if [ "$USE_LOCAL_CONFIG" = true ]
then
  echo 'Using local config!'
  cp /mnt/varnish/default.vcl /etc/varnish/default.vcl
else
  echo 'Using s3 config!'
  aws s3 cp ${S3_VCL_FILE} /etc/varnish/default.vcl
fi

RELOAD_VCL=1

# Start varnish and log

mkdir -p ${VARNISH_CACHE_FOLDER}

varnishd -a 0.0.0.0:${VARNISH_PORT} -T 127.0.0.1:6082 -f /etc/varnish/default.vcl -s file,${VARNISH_CACHE_FOLDER}/varnish_cache.bin,${VARNISH_CACHE_SIZE}

varnishlog &

# Start varnish cleanup

python3 /usr/app/src/cleanup_handler.py
