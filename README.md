# scratch-base

A base docker image like scratch which contains the essential files/directories
from alpine:latest needed by statically built binaries (e.g. golang) that need
to make https/tls connections or current timezone data.

## Files/Directories included
* /etc/ssl
* /etc/TZ
* /etc/localtime

/tmp is also created with modes 777 & +t so temporary files will also work.

## Usage

In your multipart Dockerfile first compile your binaries then create the final
image with
```
FROM area51/scratch-base
COPY --from=build /src/dir/ /dest/dir/
```

where:
* --from=build defines the alias of your build step image
* /src/dir/ is the source directory in that image to copy
* /dest/dir/ is the destination directory in this image

For example: I build static golang images so in docker I'd use:

```
FROM golang:alpine AS build
RUN mkdir -p /dest/bin
... build steps here, writing the built binaries into /dest/bin
```

Then the final image would be:
```
FROM area51/scratch-base
COPY --from=build /dest/ /
```

The final image would then contain 2 layers, the first from this project and the
second containing just your built binaries.
