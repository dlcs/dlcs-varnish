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

VSL_MASK_PARAM=()
if [ -n "$VARNISH_VSL_MASK" ]
then
  VSL_MASK_PARAM=(-p "vsl_mask=${VARNISH_VSL_MASK}")
fi

varnishd -a 0.0.0.0:${VARNISH_PORT} -T 127.0.0.1:6082 -f /etc/varnish/default.vcl "${VSL_MASK_PARAM[@]}" -s file,${VARNISH_CACHE_FOLDER}/${VARNISH_CACHE_FILE},${VARNISH_CACHE_SIZE}

VARNISHNCSA_ARGS=(-F '%h %l %u %t "%r" %s %b "%{Varnish:handling}x" %D')
if [ -n "$VARNISHLOG_QUERY" ]
then
  VARNISHNCSA_ARGS+=(-q "$VARNISHLOG_QUERY")
fi

if [ -z "$INCOMING_QUEUE" ]
then
  echo 'no queue monitoring'
  varnishncsa "${VARNISHNCSA_ARGS[@]}"
else
  # Start varnish cleanup
  varnishncsa "${VARNISHNCSA_ARGS[@]}" &
  python3 /usr/app/src/cleanup_handler.py
fi