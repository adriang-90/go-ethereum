# Support setting various labels on the final image
ARG COMMIT=""
ARG VERSION=""
ARG BUILDNUM=""

# Build Geth in a stock Go builder container
FROM golang:1.17-alpine as builder

RUN apk add --no-cache gcc musl-dev linux-headers git

COPY . /go-ethereum
WORKDIR /go-ethereum

RUN  go run build/ci.go install ./cmd/geth

# Pull Geth into a second stage deploy alpine container
FROM gcr.io/distroless/static
USER nonroot:nonroot
COPY --from=builder --chown=nonroot:nonroot /go-ethereum/build/bin/geth /usr/local/bin/

EXPOSE 8545 8546 30303 30303/udp
ENTRYPOINT ["geth"]

# Add some metadata labels to help programatic image consumption
ARG COMMIT=""
ARG VERSION=""
ARG BUILDNUM=""

LABEL commit="$COMMIT" version="$VERSION" buildnum="$BUILDNUM"
