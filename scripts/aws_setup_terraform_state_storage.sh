#! /usr/bin/bash

if [ -z $S3_TF_STATE_BUCKET ]; then
    echo [*] env variable S3_TF_STATE_BUCKET is empty
    exit 1
fi

BUCKET_NAME=$S3_TF_STATE_BUCKET

echo "[*] Checking whether the bucket '$BUCKET_NAME' exists..."
aws s3 ls s3://$BUCKET_NAME 2> /dev/null

if [ "$?" -ne 0 ]; then
    echo "[*] Creating the '$BUCKET_NAME' bucket..."

    aws s3 mb s3://$BUCKET_NAME
    if [ "$?" -eq 0 ]; then
        echo "[*] The bucket '$BUCKET_NAME' has been created successfully."
    else
        echo "[*] Bucket creation failed..."
        exit 1
    fi
else
    echo "[*] The bucket '$BUCKET_NAME' exists."
fi

POLICY_FILE=$PWD/terraform/aws/policies/s3/$BUCKET_NAME.json

if [ ! -f $POLICY_FILE ]; then
    echo "Policy '$POLICY_FILE' is not exists. Please create the policy file first."
    exit 1
fi

# TODO: receive policy file from the repo
echo "[*] Applying '$POLICY_FILE' policy to the '$BUCKET_NAME' bucket..."
aws s3api put-bucket-policy \
    --bucket $BUCKET_NAME \
    --policy file://$POLICY_FILE

echo "[*] Done"
