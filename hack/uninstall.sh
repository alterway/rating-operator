#!/bin/bash

#set -eu

DELETE_CRDS=${DELETE_CRDS:-false}
DELETE_CLUSTER_WIDE=${DELETE_CLUSTER_WIDE:-false}
LOCAL_GRAFANA=${LOCAL_GRAFANA:-false}


[ -z "${RATING_NAMESPACE:-}" ] && echo "RATING_NAMESPACE not set. It is required to install the operator." && exit 1

# Clears the rating CRD 
# DISCLAIMER: Removing this CRD **WILL** crash your other instances of rating-operator
if [ "$DELETE_CRDS" == "true" ]; then
    kubectl -n ${RATING_NAMESPACE} delete -f deploy/crds/charts.helm.k8s.io_ratings_crd.yaml
fi

# Clears the cluster wide resources
# DISCLAIMER: Removing this **WILL** crash your other instances of rating-operator
if [ "$DELETE_CLUSTER_WIDE" == "true" ]; then
    kubectl delete -f deploy/role_binding.yaml
    kubectl delete -f deploy/role.yaml
fi

# Deleting the RatingRules and RatedMetrics used or generated by the operator
kubectl -n ${RATING_NAMESPACE} delete ratingrules.rating.alterway.fr --all
kubectl -n ${RATING_NAMESPACE} delete reactiverules.rating.alterway.fr --all
kubectl -n ${RATING_NAMESPACE} delete ratedmetrics.rating.alterway.fr --all

# Deleting the object used by the operator
kubectl -n ${RATING_NAMESPACE} delete -f deploy/crds/charts.helm.k8s.io_v1alpha1_rating_cr.yaml
kubectl -n ${RATING_NAMESPACE} delete -f deploy/service_account.yaml
kubectl -n ${RATING_NAMESPACE} delete -f deploy/operator.yaml

kubectl -n ${RATING_NAMESPACE} delete pvc --all

if [ "$LOCAL_GRAFANA" == "true" ]; then
    GRAFANA_NAMESPACE=${RATING_NAMESPACE}  ./quickstart/grafana/uninstall.sh
fi
