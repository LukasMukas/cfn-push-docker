FROM alpine:3.5

# Install all the system prerequisites
RUN apk update && apk add bash && rm -rf /var/cache/apk/* \
  && /bin/bash \
  && apk update \
  && apk add alpine-sdk gcc gnupg curl ruby ruby-dev ruby-json procps musl-dev make linux-headers \
        zlib zlib-dev openssl openssl-dev libssl1.0 shadow \
  && curl -sSL https://github.com/rvm/rvm/tarball/stable -o rvm-stable.tar.gz \
  && echo 'export rvm_prefix="$HOME"' > /root/.rvmrc \
  && echo 'export rvm_path="$HOME/.rvm"' >> /root/.rvmrc \
  && mkdir rvm && cd rvm \
  && tar --strip-components=1 -xzf ../rvm-stable.tar.gz \
  && ./install --auto-dotfiles --autolibs=0 \
  && cd ../ && rm -rf rvm-stable stable.tar.gz rvm  

# Install rvm, python, pip and ruby
ENV PATH="$PATH:/root/.rvm/scripts/"
RUN rvm install 2.6.4 \
  && apk --no-cache add python \
  && apk --no-cache add py-pip \
  && mkdir /cfn-push

# Set the working environment
WORKDIR /cfn-push
ENV PATH="$PATH:/root/.local/bin" 

# Install cfn-lint and cfn-nag, make cfn-push executable
COPY . .
RUN pip install cfn-lint --user \
  && gem install cfn-nag --no-rdoc --no-ri \
  && mkdir -p ~/.local/bin/ \
  && cp cfn-push ~/.local/bin/cfn-push \
  && chmod +x ~/.local/bin/cfn-push \
  && apk del alpine-sdk gcc gnupg musl-dev make linux-headers zlib-dev openssl-dev musl-dev \
  && rm -rf /var/cache/apk/*

LABEL maintainer="Luke Evans" \
      version="0.1"

# Run cfn-push on the given template and the given bucket
CMD cfn-push template.yml $bucket  
