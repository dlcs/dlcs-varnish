# dlcs-varnish

Docker image using disk-backed Varnish instance for caching.

On startup it uses the AWS CLI to copy vcl file from location specified by `S3_VCL_FILE` environment variable.

## Configuration

The following environment files are expected:

* `S3_VCL_FILE` - The location of a vcl file to use. Expected S3Uri as it is used by [aws s3 cp](https://docs.aws.amazon.com/cli/latest/reference/s3/cp.html) command.
* `VARNISH_CACHE_FOLDER` - Folder where disk backed cache is stored.
* `VARNISH_CACHE_SIZE` - Size of cache.

## Running

```bash
# build
docker build -t dlcs-varnish:local .

# run
sudo docker run -t -i --rm \
	--env AWS_ACCESS_KEY_ID='xxx' \
	--env AWS_SECRET_ACCESS_KEY='xxx' \
	--env S3_VCL_FILE='s3://my-bucket/varnish-config.vcl' \
	--env VARNISH_CACHE_FOLDER='/path/to/folder' \
	--env VARNISH_CACHE_SIZE='100M'
	dlcs-varnish:local
```