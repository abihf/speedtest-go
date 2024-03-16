FROM --platform=$BUILDPLATFORM golang:1.22-alpine3.18 AS build
# RUN apk add --no-cache git gcc ca-certificates libc-dev
WORKDIR /build
COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg go mod download
COPY ./ ./
ARG TARGETOS TARGETARCH
RUN --mount=type=cache,target=/root/.cache/go-build \
  --mount=type=cache,target=/go/pkg \
  GOOS=$TARGETOS GOARCH=$TARGETARCH CGO_ENABLED=0 go build -ldflags "-w -s" -trimpath -o speedtest .

FROM scratch
COPY --from=build /etc/ssl/cert.pem /etc/ssl/cert.pem
WORKDIR /app
COPY --from=build /build/speedtest ./
COPY settings.toml ./

EXPOSE 8989

CMD ["/app/speedtest"]
