FROM alpine:3.15 AS build

# The Hugo version
ARG VERSION=0.91.0

ADD https://github.com/gohugoio/hugo/releases/download/v${VERSION}/hugo_${VERSION}_Linux-AMD64.tar.gz /hugo.tar.gz
RUN tar -zxvf hugo.tar.gz
RUN /hugo version

# We add git to the build stage, because Hugo needs it with --enableGitInfo
RUN apk add --no-cache git

# The source files are copied to /site
COPY . /site
WORKDIR /site

# And then we just run Hugo
RUN /hugo --minify --enableGitInfo

# stage 2
FROM nginx:1.21.5-alpine as site

WORKDIR /usr/share/nginx/html

# Clean the default public folder
RUN rm -fr * .??*

# Finally, the "public" folder generated by Hugo in the previous stage
# is copied into the public fold of nginx
COPY --from=build /site/public /usr/share/nginx/html