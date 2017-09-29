# dlcs-varnish

## Running

```
sudo docker run -t -i --rm \
	--env AWS_ACCESS_KEY_ID='' \
	--env AWS_SECRET_ACCESS_KEY='' \
	--env S3_VCL_FILE='' \
	--env VARNISH_CACHE_FOLDER='' \
	digirati/dlcs-varnish:latest
```

