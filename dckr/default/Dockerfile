FROM node:alpine

RUN apk add curl \
  build-base\
  python3

RUN mkdir -p /opt/haraka
RUN curl -sL https://github.com/haraka/Haraka/archive/refs/tags/${PATCH}.tar.gz -o /opt/haraka.tar.gz
RUN tar xzvf /opt/haraka.tar.gz -C /opt/haraka --strip-components 1
RUN cd /opt/haraka && npm install

ADD entrypoint.sh /opt/haraka/entrypoint.sh

EXPOSE 25

CMD ["/opt/haraka/entrypoint.sh"]
