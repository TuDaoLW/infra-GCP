1. Fundamental Concepts
Global Single Anycast IP: Many Google Cloud load balancers offer a single anycast IP address that acts as the frontend for your applications across regions, simplifying DNS setup and enabling global traffic distribution.
No Pre-warming: Load balancers can scale from zero to full traffic instantaneously, absorbing massive traffic spikes without any manual intervention.
Health Checks: Essential for ensuring only healthy backend instances receive traffic. You configure parameters like protocol, port, interval, timeout, and healthy threshold.
Backend Services: Define how traffic is distributed and managed by load balancers. They connect the load balancer's frontend to your backend instances/services.
Backends: The target instances or services that receive traffic. These can be various constructs like:
Instance Groups (Managed Instance Groups, Unmanaged Instance Groups)
Zonal Network Endpoint Groups (NEGs)
Serverless NEGs (for Cloud Run, Cloud Functions, App Engine)
Internet NEGs (for endpoints outside Google Cloud)
Cloud Storage buckets
Seamless Autoscaling: Load balancers can scale automatically with user and traffic growth, including handling huge, unexpected spikes.
SSL Offload/Termination: Decrypts SSL/TLS traffic at the load balancer level, freeing backend instances from cryptographic overhead. You can also enable encryption between the load balancer and backends for end-to-end security.
Google Cloud Armor: Integration for DDoS protection and WAF (Web Application Firewall) security policies at the Google Cloud edge.
Cloud CDN: Integration with Application Load Balancers for caching content closer to users, optimizing application delivery.
Cloud Logging: Logs all load balancing requests for debugging, analysis, and traffic insights.
Extensibility and Programmability: Service Extensions provide programmability on load balancing data paths.
2. Main Categories of Load Balancers
Google Cloud Load Balancing is broadly categorized by its scope (External/Internal) and the traffic layer (Layer 7 / Layer 4) it operates on.

A. External Load Balancers (for Internet-facing traffic)
Distribute traffic coming from the internet to your Google Cloud resources.

External Application Load Balancers (HTTP(S) Load Balancing)
Layer: Layer 7 (Application Layer)
Traffic: HTTP, HTTPS
Scope:
Global (Classic or Premium Tier): Global single IP address. Distributes traffic across multiple regions and backends worldwide. Offers cross-region load balancing and automatic multi-region failover.
Regional (Standard Tier): Regional IP address. Distributes traffic within a single region. Allows for strong jurisdictional control.
Key Features:
SSL Termination: Manages SSL certificates and decryption.
Content-based routing: Routes traffic based on URL paths, hostnames, HTTP headers.
URL mapping: Advanced traffic steering.
IPv6 Load Balancing: Supports IPv6 clients.
Integration: Cloud CDN, Cloud Armor.
Use Cases: Web applications, APIs, global services.
External Proxy Network Load Balancers (TCP/SSL Proxy Load Balancing)
Layer: Layer 4 (Transport Layer)
Traffic: TCP (SSL Proxy also handles SSL traffic)
Scope:
Global: Global IP address. Distributes TCP traffic (or SSL with termination) across multiple regions. Ideal for non-HTTP(S) internet-facing services.
Regional: Regional IP address. Distributes TCP/SSL traffic within a single region.
Key Features:
SSL Offload: For SSL Proxy, terminates SSL traffic globally.
Source IP-based traffic steering: Can route based on client IP.
Use Cases: Non-HTTP(S) protocols like SMTP, IMAP, gaming, or when you need SSL termination closer to the user for TCP traffic.
External Passthrough Network Load Balancers (TCP/UDP Load Balancing)
Layer: Layer 4 (Transport Layer)
Traffic: TCP, UDP, and raw IP protocols.
Scope: Regional
Key Features:
Non-proxy: Traffic is directly routed to backend VMs. The original client IP address is preserved.
Direct Server Return (DSR): Responses from backend VMs go directly to clients, not back through the load balancer.
High Performance: Optimized for high-throughput, low-latency applications.
Use Cases: When you need to preserve client IP, for gaming, UDP-intensive workloads, or when you use your own SSL offload on backend VMs.
B. Internal Load Balancers (for Internal-facing traffic within your VPC)
Distribute traffic within your Virtual Private Cloud (VPC) network.

Internal Application Load Balancers (Internal HTTP(S) Load Balancing)
Layer: Layer 7 (Application Layer)
Traffic: HTTP, HTTPS
Scope:
Regional: Internal IP address. Distributes traffic among backends within a single region. Backends and proxies remain in the chosen region for jurisdictional control.
Cross-Region: Internal IP address. Distributes traffic among backends in multiple regions. Clients from any Google Cloud region can send traffic to the load balancer.
Key Features:
Internal IP: Accessible only to clients within the same VPC network or connected VPCs.
Proxy-based: Uses a proxy-only subnet for its operations.
Content-based routing: Similar to External Application Load Balancer.
Use Cases: Internal microservices communication, multi-tier web applications where the frontend talks to a backend via an internal load balancer.
Internal Proxy Network Load Balancers (Internal TCP/SSL Proxy Load Balancing)
Layer: Layer 4 (Transport Layer)
Traffic: TCP, SSL
Scope:
Regional: Internal IP address. Distributes TCP traffic within a single region.
Cross-Region: Internal IP address. Distributes TCP traffic across multiple regions.
Key Features: Proxy-based, uses a proxy-only subnet.
Use Cases: Internal TCP applications, internal services requiring SSL termination without going to the internet.
Internal Passthrough Network Load Balancers (Internal TCP/UDP Load Balancing)
Layer: Layer 4 (Transport Layer)
Traffic: TCP, UDP
Scope: Regional
Key Features:
Non-proxy: Traffic directly routed to backend VMs. Original client IP preserved.
Direct Server Return (DSR).
Session Affinity: Can be configured to direct traffic from a client to the same backend.
Use Cases: Legacy applications, high-performance internal TCP/UDP services where client IP preservation is critical.
3. Key Configuration Options Across Load Balancers
Health Checks: Define probes to monitor backend instance health.
Session Affinity: Options like Client IP, Generated Cookie, HTTP Header, None.
Timeout Settings: Service timeout, backend connection timeout.
Traffic Distribution Algorithms: Round-robin, least connections, custom policies.
Custom Request Headers: For HTTP(S) load balancers.
Service Extensions: For extensibility and programmability on the data path.
IPv6 Load Balancing: Support for IPv6 clients.
Weighted Load Balancing: Distribute traffic unevenly across backends.

# only proxy LB need this: External/in Application LB, External/in Proxy Network LB
      - name: lb-proxy # special subnet for GCP proxy
        region: asia-southeast1
        primaryIPv4Cidr: 10.0.255.0/28
        privateGoogleAccess: disable
        purpose: REGIONAL_MANAGED_PROXY #GLOBAL_MANAGED_PROXY
        role: ACTIVE
        labels:
        tags:

# the core idea is:
Load Balancer: The entry point for incoming traffic.
Backend Service: A configuration that defines how the Load Balancer distributes traffic. It includes settings like protocols, health checks, and balancing modes.
Backends (Instance Groups or NEGs): These are the actual compute resources (VMs, GKE Pods, Cloud Run services, etc.) that receive the traffic from the Backend Service. Instance Groups are used for VMs and MIGs, while NEGs are used for more dynamic or serverless workloads like GKE and Cloud Run.