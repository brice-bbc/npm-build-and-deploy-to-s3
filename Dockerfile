FROM python:3.6-alpine

ENV AWSCLI_VERSION='1.20.51'
RUN pip install --quiet --no-cache-dir awscli==${AWSCLI_VERSION}

RUN apk add --update nodejs npm
RUN apk add --update npm

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
