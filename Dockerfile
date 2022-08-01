# Build the manager binary
FROM --platform=$BUILDPLATFORM golang:1.18.5 as builder

ARG GOARCH=''
ARG GITHUB_PAT=''

WORKDIR /workspace
# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum

COPY hack hack

# cache deps before building and copying source so that we don't need to re-download as much
# and so that source changes don't invalidate our downloaded layer
RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg \
    go mod download

# Copy the go source
COPY api/ api/
COPY broker broker/
COPY client/ client/
COPY controllers/ controllers/
COPY handler/ handler/
COPY hash/ hash/
COPY index/ index/
COPY machinebrokerlet/ machinebrokerlet/
COPY partitionlet/ partitionlet/
COPY predicate/ predicate/
COPY proxyvolumebrokerlet/ proxyvolumebrokerlet/
COPY volumebrokerlet/ volumebrokerlet

ARG TARGETOS TARGETARCH

RUN mkdir bin

# Build
RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg \
    CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH GO111MODULE=on go build -ldflags="-s -w" -a -o bin/machinebrokerlet ./machinebrokerlet && \
    CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH GO111MODULE=on go build -ldflags="-s -w" -a -o bin/partitionlet ./partitionlet && \
    CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH GO111MODULE=on go build -ldflags="-s -w" -a -o bin/proxyvolumebrokerlet ./proxyvolumebrokerlet && \
    CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH GO111MODULE=on go build -ldflags="-s -w" -a -o bin/volumebrokerlet ./volumebrokerlet

# Use distroless as minimal base image to package any controller binary
# Refer to https://github.com/GoogleContainerTools/distroless for more details
FROM gcr.io/distroless/static:nonroot as machinebrokerlet
WORKDIR /
COPY --from=builder /workspace/bin/machinebrokerlet /manager
USER 65532:65532

ENTRYPOINT ["/manager"]

FROM gcr.io/distroless/static:nonroot as partitionlet
WORKDIR /
COPY --from=builder /workspace/bin/partitionlet /manager
USER 65532:65532

ENTRYPOINT ["/manager"]

FROM gcr.io/distroless/static:nonroot as proxyvolumebrokerlet
WORKDIR /
COPY --from=builder /workspace/bin/proxyvolumebrokerlet /manager
USER 65532:65532

ENTRYPOINT ["/manager"]

FROM gcr.io/distroless/static:nonroot as volumebrokerlet
WORKDIR /
COPY --from=builder /workspace/bin/volumebrokerlet /manager
USER 65532:65532

ENTRYPOINT ["/manager"]
