1. Let Flux pick up the version bump and confirm teleport-cluster is healthy
  flux get hr teleport-cluster -n teleport-cluster --watch
  kubectl get pods -n teleport-cluster -w
  # Expect: teleport-cluster-auth-0 and teleport-cluster-proxy-* Running
  (Flux polls the starlight-addons HelmRelease every 1m, so it should reconcile automatically now that main has the bump — no manual action needed unless it's stuck.)

  2. Add the Cloudflare public hostname (one-time, manual, dashboard step — skip if already done)
  Zero Trust → Networks → Tunnels → your tunnel → Public Hostnames → Add:

  ┌───────────────┬─────────────────────────────────────────────────────────┐
  │     Field     │                          Value                          │
  ├───────────────┼─────────────────────────────────────────────────────────┤
  │ Subdomain     │ teleport                                                │
  ├───────────────┼─────────────────────────────────────────────────────────┤
  │ Domain        │ starlight-dogfood.me                                    │
  ├───────────────┼─────────────────────────────────────────────────────────┤
  │ Service type  │ HTTPS                                                   │
  ├───────────────┼─────────────────────────────────────────────────────────┤
  │ URL           │ teleport-cluster.teleport-cluster.svc.cluster.local:443 │
  ├───────────────┼─────────────────────────────────────────────────────────┤
  │ No TLS Verify │ true                                                    │
  └───────────────┴─────────────────────────────────────────────────────────┘

  Verify: curl -k https://teleport.starlight-dogfood.me/web/ returns HTML, not a Cloudflare error.

  3. Create the admin user + kube-agent join token (run on the server, where kubectl is configured against the cluster)
  bash kube-deploy/bootstrap/07-teleport-post-deploy.sh
  It prints an invite URL (valid 1 hour) and the token name (starlight-kube-token).

  4. Complete the browser invite
  Open the printed URL (or port-forward kubectl port-forward -n teleport-cluster svc/teleport-cluster 8443:443 and hit https://localhost:8443/web/invite/<token> if Cloudflare isn't wired up yet). Set a password, scan the QR code, enter the OTP, save backup codes.

  5. Enable the kube-agent
  Edit kube-deploy/clusters/local/addons/values.yaml:
  teleport:
    enabled: true
    joinParams:
      tokenName: "starlight-kube-token"
  Commit and push — Flux deploys it automatically:
  kubectl get pods -n teleport -w
  # Expect: teleport-kube-agent-* Running
  kubectl logs -n teleport -l app.kubernetes.io/name=teleport-kube-agent --tail=20
  # Expect: "Successfully registered kubernetes cluster"

  6. Log in from your workstation (this is the actual "connect" step — make sure your local tsh is the v18.9.2 build you just installed)
  tsh login --proxy=teleport.starlight-dogfood.me --user=admin
  tsh kube ls
  tsh kube login starlight-local
  kubectl get nodes   # now proxied through Teleport, fully audited

  Where are you stuck right now — is teleport-cluster already Running in the cluster, or do you need to check that first?
