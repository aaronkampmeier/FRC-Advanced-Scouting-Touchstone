## Command to upload the website to S3
```
aws s3 sync ./Webstorm/ s3://frcfastapp.com/ --exclude "doc/*" --exclude ".DS_Store" --exclude ".editorconfig" --exclude ".idea/*" --exclude ".git*"
```
