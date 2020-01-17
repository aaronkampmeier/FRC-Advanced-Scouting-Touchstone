This AWS AppSync Stack can be deployed using clouformation through the [AWS CLI](https://docs.aws.amazon.com/cli/latest/reference/cloudformation/deploy/index.html)

## Package Command:
Replace with your own S3 bucket
```
aws cloudformation package --template-file FAST-API-2-Stack.yaml --s3-bucket cf-templates-4eazvtfbn788-us-east-1 --s3-prefix "FAST API Stack Resources" --output-template-file FAST-Stack-Packaged.yaml
```

## Deploy Command:
```
aws cloudformation deploy --template-file FAST-Stack-Packaged.yaml --s3-bucket cf-templates-4eazvtfbn788-us-east-1 --stack-name FAST-DevAPI2 --capabilities CAPABILITY_NAMED_IAM
```
