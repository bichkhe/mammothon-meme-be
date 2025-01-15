FROM rust:latest AS builder
RUN apt-get update && apt-get install -y \
    musl-tools \
    libssl-dev \
    pkg-config \
    build-essential \
    clang
WORKDIR /usr/src/app
COPY . .
RUN cargo build --release

FROM alpine:latest
RUN apk add --no-cache ca-certificates openssl
WORKDIR /app
COPY --from=builder /usr/src/app/target/release/mammothon_meme_be-cli .
COPY --from=builder /usr/src/app/config/ ./app/config/
RUN chmod +x /app/mammothon_meme_be-cli

CMD ["./mammothon_meme_be-cli", "start", "-p 5150"]
