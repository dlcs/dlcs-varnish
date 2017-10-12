# dlcs-varnish

## Running

```
sudo docker run -t -i --rm \
	--env VARNISH_CACHE_FOLDER='/mnt/varnish/cache' \
	-v <cache-folder>:/mnt/varnish \
	-v <absolute-path-to-vcl-file>:/etc/varnish/default.vcl \
	digirati/dlcs-varnish:latest
```

