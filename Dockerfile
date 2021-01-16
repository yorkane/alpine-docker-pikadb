FROM alpine:3.3
COPY output/ /pika
RUN apk --no-cache add bash rsync libbz2 snappy protobuf lz4 \
    && ln -sf /pika/libgflags_nothreads.so.2.2 /usr/lib/ \
    && ln -sf /pika/libgflags.so.2.2 /usr/lib/

# ENTRYPOINT ["/pika/entrypoint.sh"]
CMD ["/pika/pika", "-c", "/pika/pika.conf"]
