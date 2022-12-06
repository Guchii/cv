FROM danteev/texlive:2022-02-15 as pdf-builder
WORKDIR /build
COPY ./ ./
RUN apt-get install -y wget
WORKDIR /usr/share/fonts/truetype
RUN wget https://github.com/misuchiru03/font-times-new-roman/archive/refs/tags/v1.0.zip 
RUN unzip v1.0.zip
WORKDIR /build
RUN lualatex cv.tex

FROM alpine:3.16 as deps
RUN apk add wget
RUN wget https://github.com/mufeedvh/binserve/releases/download/v0.2.0/binserve-v0.2.0-i686-unknown-linux-musl.tar.gz
RUN tar -xzf binserve-v0.2.0-i686-unknown-linux-musl.tar.gz
RUN mv binserve-v0.2.0-i686-unknown-linux-musl/binserve /usr/bin

FROM alpine:3.16
COPY --from=deps /usr/bin/binserve /usr/bin/binserve
WORKDIR /srv
RUN mkdir -p public
COPY --from=pdf-builder /build/cv.pdf ./public
COPY ./binserve.json ./
# COPY apps/cv/src/status.json ./public
CMD binserve