# Getting Started React

If you need to know how to get started, you're _unforunately_ in the wrong project. Please visit [Create React App](https://github.com/facebook/create-react-app) for more information!

## Build a Docker image

Enter the client directory of the project and build a docker file.

```
Docker build -t cloud-run-demo .
```

## Tag your image
Once you have a built Dockerfile, create a tag for the build:

```
docker tag cloud-run-demo gcr.io/{your GCP_PROJECT_ID}/cloud-run-demo:latest
```

## Enable GCR and push to container registry
Make sure your `gcloud` tool is pointed towards the GCP project you want to push this image to. 

Make sure to enable the Google Container Registry API in your project:

```
gcloud services enable containerregistry.googleapis.com
```

Then, push your tag:

```
docker push gcr.io/{GCP_PROJECT_ID}/cloud-run-demo:latest
```