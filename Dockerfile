FROM rust:latest AS builder
RUN apt-get update && apt-get install -y \
    musl-tools \
    libssl-dev \
    pkg-config \
    build-essential \
    clang \
    && rustup target add x86_64-unknown-linux-musl

WORKDIR /usr/src/app
COPY . .
RUN cargo build --release --target=x86_64-unknown-linux-musl

FROM alpine:latest
RUN apk add --no-cache ca-certificates openssl
WORKDIR /app
COPY --from=builder /usr/src/app/target/x86_64-unknown-linux-musl/release/mammothon_meme_be-cli .
COPY --from=builder /usr/src/app/config/ /app/config/
COPY --from=builder /usr/src/app/.env.dev .
RUN mv .env.dev .env.local
RUN chmod +x /app/mammothon_meme_be-cli
EXPOSE 5150

CMD ["./mammothon_meme_be-cli", "start", "-b", "0.0.0.0"]
