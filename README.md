# tkn

[tektoncd/cli](https://github.com/tektoncd/cli) `docker` image build.

## Development

Build the image using `docker`: `docker build --rm -t tkn .`

Run the image using `docker`:

    docker run --rm -it \  
    -v "${HOME}/.kube:/home/tekton/.kube" \  
    -v "${HOME}/.config/gcloud:/home/tekton/.config/gcloud" \  
    --network host \  
    tkn --help
