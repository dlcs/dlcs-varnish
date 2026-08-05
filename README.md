# dlcs-varnish

Docker image using disk-backed Varnish instance for caching.

On startup it uses the AWS CLI to copy vcl file from location specified by `S3_VCL_FILE` environment variable. 
Optionally, a local file can also be configured for development purposes

## Configuration

The following environment settings are expected:
* `S3_VCL_FILE` - The location of a vcl file to use. Expected S3Uri as it is used by [aws s3 cp](https://docs.aws.amazon.com/cli/latest/reference/s3/cp.html) command.
* `VARNISH_CACHE_FOLDER` - Folder where disk backed cache is stored.
* `VARNISH_CACHE_SIZE` - Size of cache.
* `AWS_PROFILE` - Required to run locally

The following configuration is optional:

* `VARNISH_CACHE_FILE` - The name of varnish [storage file](https://varnish-cache.org/docs/trunk/users-guide/storage-backends.html#file) (e.g. `varnish_cache.bin`). If specified it is appended to `VARNISH_CACHE_FOLDER` to create file (if unspecified folder only is used)
* `INCOMING_QUEUE` - the name of the queue that the cleanup handler listens to
* `VARNISH_ADDRESS` - The location of varnish used by the cleanup handler. Defaults to localhost
* `AWS_REGION` - The AWS region. Defaults to eu-west-1
* `USE_LOCAL_CONFIG` - Whether to use a local config file over S3. 
* `VARNISH_VSL_MASK` - Controls which [VSL tags](https://varnish-cache.org/docs/trunk/reference/vsl.html) varnish records, passed to `varnishd` as `-p vsl_mask=`. Prefix a tag with `-` to suppress it, `+` to enable. If unspecified varnish defaults are used. e.g. `-ReqHeader,-RespHeader,-BereqHeader,-BerespHeader,-VCL_call,-VCL_return`
* `VARNISHLOG_QUERY` - A [VSL query](https://varnish-cache.org/docs/trunk/reference/vsl-query.html) limiting which transactions `varnishncsa` writes to stdout, passed as `-q`. If unspecified all transactions are logged. e.g. `RespStatus >= 400`

*NOTE:* using `USE_LOCAL_CONFIG` requires a `mount`to be added to the `docker run` containing the VCL
## Running

```bash
# build
docker build -t dlcs-varnish:local .

# run
docker run -it --rm \
	--env S3_VCL_FILE='s3://my-bucket/varnish-config.vcl' \
	--env VARNISH_CACHE_FOLDER='/path/to/folder' \
	--env VARNISH_CACHE_SIZE='100M' \
	--env-file='/path/to/env' \
	{REQUIRED FOR LOCAL RUNNING}--volume $HOME\.aws\credentials:/root/.aws/credentials:ro \
	{OPTIONAL}--volume ./etc/:/mnt/varnish/ \
	dlcs-varnish:local
```
## Local development

A `docker-compose.yml` is provided that runs Varnish in front of [go-httpbin](https://github.com/mccutchen/go-httpbin) as a test backend.

```bash
docker compose up --build
```

Varnish is available at `http://localhost:8080` and the backend directly at `http://localhost:8081`. The `X-Cache` response header shows `HIT` or `MISS`.

```bash
# First request is a MISS, repeating it is a HIT
curl -i http://localhost:8080/get
curl -i http://localhost:8080/headers

# Test specific status codes
curl -i http://localhost:8080/status/404
curl -i http://localhost:8080/status/200

# Simulate a slow backend response
curl -i http://localhost:8080/delay/2

# Hit the backend directly to compare what Varnish adds/strips
curl -i http://localhost:8081/get
```

To force a cache miss for a specific path, send a BAN request:

```bash
curl -X BAN http://localhost:8080/get
```

## varnish-cleanup

Additionally, there is a standalone docker container for the cleanup handler. 

### Configuration

Required:
* `AWS_PROFILE` - Required to run locally

Optional:
* `VARNISH_ADDRESS` - The location of varnish used by the cleanup handler. Defaults to localhost
* `AWS_REGION` - The region used by the cleanup handler. Defaults to eu-west-1

```bash
# build
docker build -t dlcs-varnish-cleanup:local ./varnish-cleanup

# run
docker run -it --rm \
	--env-file='/path/to/env'
	{REQUIRED FOR LOCAL RUNNING}--volume=$HOME\.aws\credentials:/root/.aws/credentials:ro
	dlcs-varnish:local
```