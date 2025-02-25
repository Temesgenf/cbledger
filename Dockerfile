FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends gnucobol make \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .
RUN make

ENTRYPOINT ["bin/ledger"]
