## Set Up GKE Workload Identity for OCI Repositories

Frequently people will want to use their own OCI repositories in artifact registry instead of the ones provided by third parties.  Flux supports this natively, in to enable it you'll want to set up an IAM identity binding for the `source-controller` kubernetes service account (living in the `flux-source-controller` namespace), then add the following secret to your deployment:

```yaml
gcpServiceAccount: <service-account-email>
```
