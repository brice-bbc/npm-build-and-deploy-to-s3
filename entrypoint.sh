#!/bin/sh

set -e

if [ -z "$AWS_S3_BUCKET" ]; then
  echo "AWS_S3_BUCKET is not set. Quitting."
  exit 1
fi

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  echo "AWS_ACCESS_KEY_ID is not set. Quitting."
  exit 1
fi

if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "AWS_SECRET_ACCESS_KEY is not set. Quitting."
  exit 1
fi

if [ -z "$AWS_DEFAULT_REGION" ]; then
  echo "AWS_DEFAULT_REGION is not set. Quitting."
  exit 1
fi

if [ -z "$SOURCE_DIR" ]; then
  echo "SOURCE_DIR is not set. Quitting."
  exit 1
fi

if [ -z "$DIST_DIR" ]; then
  echo "DIST_DIR is not set. Quitting."
  exit 1
fi

if [ -z "$BUILD_CMD" ]; then
  echo "BUILD_CMD is not set. Defaulting to build."
  BUILD_CMD=build
fi


mkdir -p ~/.aws
touch ~/.aws/credentials

echo "[default]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}" > ~/.aws/credentials

if [ -z "$CI_CD_TOKEN" ] && [ -z "$ORG_NAME" ]; then
  echo "Setting .npmrc file"
  echo "//npm.pkg.github.com/:_authToken=${CI_CD_TOKEN}
  @${ORG_NAME}:registry=https://npm.pkg.github.com
  registry=https://registry.npmjs.org/" > ~/.npmrc
fi

echo "Change directory to Source"
cd $SOURCE_DIR

echo "Install dev dependencies and deps"
npm ci --include=dev

echo "setup PATH"
export PATH=$PATH:$SOURCE_DIR/node_modules/.bin

echo "Build application"
npm run $BUILD_CMD

if [ -d "$DIST_DIR" ]; then
    echo "Copying app to S3"
    aws s3 sync ${DIST_DIR} s3://${AWS_S3_BUCKET}/${AWS_S3_BUCKET_DIR}/ --exact-timestamps --delete --region ${AWS_DEFAULT_REGION} $*
fi

echo "Cleaning up things"

rm -rf ~/.npmrc
rm -rf ~/.aws
