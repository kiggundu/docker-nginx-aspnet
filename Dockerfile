# Base OS
FROM shaunol/centos-mono:centos6.4-mono.afa2f52
MAINTAINER shaunol

# Env setup
ENV HOME /root
WORKDIR /root

# Build deps
# required for xsp: pkgconfig
# required for nginx: pcre-devel, zlib-devel
RUN yum install -y pkgconfig pcre-devel zlib-devel

# Install xsp, requires to provide fastcgi-mono-server for nginx to serve asp.net requests
ENV PKG_CONFIG_PATH /usr/lib/pkgconfig
RUN git clone git://github.com/mono/xsp /root/xsp && \
        cd /root/xsp && \
        git reset --hard 8a31bc6 && \
        ./autogen.sh --prefix=/usr && \
        ./configure --prefix=/usr && \
        make && \
        make install && \
        cd /root && \
        rm -rf /root/xsp

# Required environment variable to run fastcgi-mono-server
ENV LD_LIBRARY_PATH /usr/lib

# nginx install
RUN cd /root && \
        wget http://nginx.org/download/nginx-1.7.2.tar.gz && \
        tar -zxf nginx-1.7.2.tar.gz && \
        cd /root/nginx-1.7.2/ && \
        ./configure --prefix=/usr && \
        make && \
        make install && \
        cd /root/ && \
        rm -rf ./nginx-1.7.2/ ./nginx-1.7.2.tar.gz

# Create a directory for our single application environment & load the sample MVC4 application
ADD ./HelloWorldMvc4-Deploy.tar.gz /root/
RUN mv /root/HelloWorldMvc4-Deploy /usr/aspnet

# Configure nginx
ADD ./nginx-fastcgi_params.conf /usr/conf/nginx-fastcgi_params.conf
ADD ./nginx.conf /usr/conf/nginx.conf

# TODO: Start fastcgi-mono-server and nginx automatically on startup and issue a CMD to allow easy running of the container in daemon mode
# CMD ["/usr/sbin/nginx"]
