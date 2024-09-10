# Build backend
FROM golang:1.23.0 as build-stage
ARG VERSION=${VERSION}
WORKDIR /app
#  download Go modules
COPY ./ ./
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux go build -o backend-momo-${VERSION} ./cmd/api

# Run the tests in the container
FROM build-stage AS test-stage
RUN go test -v ./...

# Create image backend
FROM alpine:3.20.2
ARG VERSION=${VERSION}
WORKDIR /app
RUN addgroup --system gouser && adduser -S -D -H -s /bin/false -G gouser gouser
COPY --chown=gouser:gouser --from=build-stage /app/backend-momo-${VERSION} ./backend-momo
EXPOSE 8081
USER gouser
ENTRYPOINT ["/app/backend-momo"]
