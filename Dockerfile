FROM python:3.6-alpine

ENV AWSCLI_VERSION='1.20.51'
RUN pip install --quiet --no-cache-dir awscli==${AWSCLI_VERSION}

RUN apk add --update nodejs npm
RUN apk add --update npm

RUN apk --no-cache add --virtual native-deps \
  g++ gcc libgcc libstdc++ linux-headers make python && \
  npm install --quiet node-gyp -g

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
