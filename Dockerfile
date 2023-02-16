# Build the manager binary
FROM docker.io/library/golang:1.19 as builder
ARG BUILD_VERSION="unknown"

WORKDIR /opt/app-root

# Copy the go manifests and source
COPY go.mod go.mod
COPY go.sum go.sum
COPY vendor/ vendor/
COPY main.go main.go
COPY api/ api/
COPY controllers/ controllers/
COPY pkg/ pkg/

# Build
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 GO111MODULE=on go build -ldflags "-X 'main.buildVersion=$BUILD_VERSION' -X 'main.buildDate=`date +%Y-%m-%d\ %H:%M`'" -mod vendor -a -o manager main.go

# Create final image from minimal + built binary
FROM registry.access.redhat.com/ubi9/ubi-minimal:9.1
WORKDIR /
COPY --from=builder /opt/app-root/manager .
USER 65532:65532

ENTRYPOINT ["/manager"]
