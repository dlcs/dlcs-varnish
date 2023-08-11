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
* `INCOMING_QUEUE` - the name of the queue that the cleanup handler listens to

The following configuration is optional:

* `VARNISH_ADDRESS` - The location of varnish used by the cleanup handler. Defaults to localhost
* `AWS_REGION` - The AWS region. Defaults to eu-west-1
* `USE_LOCAL_CONFIG` - Whether to use a local config file over S3. 

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
	{OPTIONAL}--mount type=bind,source=.\etc\default.vcl,target=/mnt/varnish/default.vcl \
	dlcs-varnish:local
```
# varnish-cleanup

Additionally, there is a standalone docker container for the cleanup handler. 

## Configuration

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