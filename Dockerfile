FROM openshift/origin-release:golang-1.10 AS builder

ADD election /go/src/k8s.io/contrib/election
RUN cd /go/src/k8s.io/contrib/election \
 && CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags '-w' -o leader-elector example/main.go

# Regular image
FROM openshift/origin-base:v4.0

COPY --from=builder /go/src/k8s.io/contrib/election/leader-elector /usr/bin/

USER 1001

ENTRYPOINT [ "leader-elector", "--id=$(hostname)" ]

LABEL \
        io.k8s.description="This is a component of OpenShift Container Platform and provides a leader-elector sidecar container." \
        com.redhat.component="leader-elector-container" \
        maintainer="Michal Dulko <mdulko@redhat.com>" \
        name="openshift/ose-leader-elector" \
        summary="This image provides leader election functionality and can be used as a sidecar container." \
        io.k8s.display-name="leader-elector" \
        version="v4.0.0" \
        io.openshift.tags="openshift"
