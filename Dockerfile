# ============================================================
# Docker file to create a scratch image suitable for
# statically compiled binaryies (e.g. golang) but includes
# the required config files to support ssl (https, tls etc)
# and current tz data
#
# To use this instead of referencing scratch reference this
# image instead
# ============================================================

FROM alpine as base

RUN apk add --no-cache \
      curl \
      tzdata

RUN mkdir -p \
      /dest/etc \
      /dest/tmp &&\
    chmod 777 /dest/tmp &&\
    chmod +t /dest/tmp &&\
    cp -rp \
      /etc/ssl \
      /etc/TZ \
      /etc/localtime \
      /dest/etc/

# ============================================================
# This is the final image
FROM scratch
COPY --from=base /dest/ /
