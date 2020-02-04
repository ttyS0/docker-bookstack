# docker-bookstack

This build is _heavily_ influenced by the [solidnerd build](https://github.com/solidnerd/docker-bookstack). Initially I just forked the repo, but I'm starting to divert a lot from `solidnerd's` approach so I've switched to a separate repository that references the original inspiration.

I use [Bookstack](https://github.com/BookStackApp/BookStack) primarily for a [personal wiki](https://skj.wiki), and run it as a [Kubernetes Pod](https://github.com/ttyS0/kubernetes/tree/master/bookstack) in my [Home Lab](https://skj.wiki/books/home-lab).

To try and reduce the footprint of the container, I've broken up the build a little. Also I use [buildx](https://docs.docker.com/buildx/working-with-buildx/) to make a multi-arch image that I push to a private Docker registry. This is because I have a number of RasperryPis running in my Home Lab, and they are fine for handling my relatively light Bookstack usage.


