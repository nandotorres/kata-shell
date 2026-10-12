cat > services.json <<'EOF'
{
  "generated": "2026-10-16T10:00:00Z",
  "services": [
    { "name": "auth",    "region": "eu-west",  "status": "up",       "latency_ms": 42 },
    { "name": "billing", "region": "us-east",  "status": "down",     "latency_ms": null },
    { "name": "search",  "region": "eu-west",  "status": "degraded", "latency_ms": 900 },
    { "name": "cart",    "region": "us-east",  "status": "up",       "latency_ms": 51 },
    { "name": "email",   "region": "ap-south", "status": "down",     "latency_ms": null },
    { "name": "catalog", "region": "eu-west",  "status": "up",       "latency_ms": 38 },
    { "name": "reports", "region": "ap-south", "status": "up",       "latency_ms": 120 }
  ]
}
EOF
