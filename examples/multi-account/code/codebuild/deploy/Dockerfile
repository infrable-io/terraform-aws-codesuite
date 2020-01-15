FROM python:3.7-alpine as base

RUN apk update && apk upgrade

RUN apk add --no-cache \
			bash \
      curl \
      jq \
      unzip

# install the AWS CLI using the bundled installer
RUN curl 'https://s3.amazonaws.com/aws-cli/awscli-bundle.zip' \
      -o 'awscli-bundle.zip' && \
      unzip awscli-bundle.zip && \
      python3 ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

# copy assume-role to /bin
COPY ./assume-role /bin

ENTRYPOINT ["/bin/bash"]
