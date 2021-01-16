ARG VER="v3.4.0"

# alpine:3.3 with gcc-5.3.0 
FROM alpine:3.3
ARG VER
LABEL APP="PIKA${VER}"
ENV PIKAURL="https://github.com/Qihoo360/pika/archive/${VER}.tar.gz"
ENV PIKAVER=${VER}
RUN echo 'ls -la "$@"' > /usr/bin/ll && chmod 755 /usr/bin/ll \
	&& sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
	&& apk --no-cache add curl g++ snappy-dev protobuf-dev bzip2-dev lz4-dev make git bash linux-headers perl cmake git tcl rsync\
	&& cd /tmp/ && git clone https://github.com/gflags/gflags.git \
	&& cd gflags && mkdir build && cd build && cmake -DBUILD_SHARED_LIBS=1 -DGFLAGS_INSTALL_SHARED_LIBS=1 .. && make install \
	&& ln -sf /usr/local/include/gflags/ /usr/include/ \
	&& cd /tmp/ && git clone https://github.com/Qihoo360/pika.git \
# Fix pika build
	&& cd pika && sed -i "s/pthread_rwlockattr_setkind_np/\/\/pthread_rwlockattr_setkind_np/g"  `grep pthread_rwlockattr_setkind_np -rl src/` \
	&& sed -i "s/PTHREAD_RWLOCK_PREFER_WRITER_NONRECURSIVE_NP/\/\/PTHREAD_RWLOCK_PREFER_WRITER_NONRECURSIVE_NP/g"  `grep PTHREAD_RWLOCK_PREFER_WRITER_NONRECURSIVE_NP -rl src/` \
	&& git submodule init && git submodule update \
# Fix slash build
	&& sed -i "s/#include <unistd.h>/#include <unistd.h>\n#include <sys\/types.h>\n#include <sys\/stat.h>\n/g" third/slash/slash/include/env.h \
# Fix blackwidow build
	&& sed -i "s/BLACKWIDOW_PLATFORM_IS_LITTLE_ENDIAN (__BYTE_ORDER == __LITTLE_ENDIAN)/BLACKWIDOW_PLATFORM_IS_LITTLE_ENDIAN (true)/g" third/blackwidow/src/coding.h \
	&& cd third/glog/ && ./configure --disable-shared && make && make install \
	&& ln -sf /usr/local/include/glog/ /usr/include/ \
	&& echo 'Prepare complete! cd /tmp/pika/ && make to compile !'


	# RUN apk --update add bash rsync libc6-compat libbz2 libgcc \
	# && echo 'ls -la "$@"' > /usr/bin/ll && chmod 755 /usr/bin/ll

# ENTRYPOINT ["/pika/entrypoint.sh"]
# CMD ["/pika/bin/pika", "-c", "/pika/conf/pika.conf"]
CMD ["/bin/sh"]
# docker build ./ -f builder.Dockerfile -t pikabuilder:1
# docker run -it -d -v /code/:/code --name pika0 pikabuilder sh

# Unit tests
# ./pikatests.sh basic 
# ./pikatests.sh bitops
# ./pikatests.sh expire
# ./pikatests.sh keys
# ./pikatests.sh type/hash
# ./pikatests.sh type/set
# ./pikatests.sh type/zset
# ./pikatests.sh type/list
# cp /tmp/pika/output/pika /code/pika/output/
# cp /tmp/pika/conf/* /code/pika/output/
# cp /tmp/gflags/build/lib/libgflags.so.2.2.2 /code/pika/output/libgflags.so.2.2
# cp /tmp/gflags/build/lib/libgflags_nothreads.so.2.2.2 /code/pika/output/libgflags_nothreads.so.2.2


