FROM alpine:3.14 as cacerts
RUN apk --no-cache add ca-certificates

FROM scratch
COPY --from=cacerts /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY myapp /
ENTRYPOINT ["/myapp"]