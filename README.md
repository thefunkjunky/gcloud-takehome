# GCloud/Terraform "Hello World"
Take-home Gcloud devops assignment.

## Requirements

The provided instructions were short on explicit instructions, leaving much to interpretation.  The basic stated requirements are as follows:

* Create web app that returns the message "Hello World" from a database.
* App should be publicly accessible and highly scalable.
* Application and associated infrastructure must be deployed using IaC (Terraform).
* Include monitoring for observability.
* Additional services may be added as needed.

## Options

The following were options I considered for the implementation details:

### Language(s)

Just about any language with a web framework will work here. There aren't any usage requirements that demand special features of any language in particular, so I opted for Python3, the language I'm most familiar with.  It also has a long history of support on Google Cloud runtimes and client libraries, so it is reasonable to assume it has wide product and feature coverage.

The downside to Python is that it is slower than other languages, and requires larger container runtime sizes due to its requirements for an OS.  Golang would be a good choice, as it is not only fast and lightweight, but provides a good web framework and other libraries natively. But, I don't know it, and the benefits aren't worth the time spent trying to learn it here. 

### App Infrastructure

I had the following potential strategies in mind:

* Static website hosted on multi-region GCS bucket. Use cloud load balancer to route https traffic to the static content, cloud CDN to cache the content globally, and cloud monitoring to observe traffic and errors.  The "Hello World" message doesn't change according to the description, so hosting it statically would be the simplest option, and you get some nice features with the LB and CDN.  However, categorizing object store as a "database", while technically true, doesn't seem to be in the spirit of this exercise.  It also doesn't offer any future dynamism.  Pass.

* Flask/NGINX web application run on GCE instances, autoscaled in instance groups, using cloud load balancing.  This requires more setup as there's a whole OS and VM to deal with, which have to be configured via configuration management, or I have to build and deploy an image. Scaling is slow and based on simpler metrics like CPU and Memory. Networking is something I have to manage. Not as many metrics or logs available, unless I roll my own solutions.  Upside is that I have more control over my infrastructure, although nothing in the requirements demands this level of customization.  A lot of work for less performance and features, I'll pass.

* Google App Engine (standard/flex). Google Cloud's oldest product, this is their flagship web application platform.  Standard is designed to use extremeley light runtime environments for your code on automatically scaled workers.  It is extremeley fast and designed for large and unpredictable scaling needs.  It can also scale down to 0 workers, making it affordable for me.  It comes pre-baked with log aggregation (cloud logging), lots of useful metrics (cloud monitoring), cloud trace, cloud debugger, a NoSQL document store, caching, and a lot of other features.  Flex engine allows one to easily deploy their own images and runtimes, but is designed for more steady usage patterns.  I don't need anything that isn't already offered in the standard runtime, so I'm leaning toward that.  It seems like the most features offered, and the most production ready, with the smallest amount of effort required.  The downside is that it is a heavily managed service, offering less control over the backend.  It is also very unique, requiring more learning investment, and is less portable.

* Flask app on GKE - The heaviest weight option here. Great for managing a complex array of services on scaled infrastructure.  Offers all kinds of abilities and services, but a complex endeavor to manage. I believe GCloud offers a package that helps it integrate into cloud monitoring and logging, although one can also run Prometheus, Grafana, etc.  Requires container images to be built and deployed via cloud build/container registry. There's only really one simple service that I'm running, and getting this to production readiness requires a lot more time and moving parts.  I believe that this is overkill for such a simple app, and the extra moving parts just means more things that can go wrong. Also, it's easy to accidentally incur costs using it, since it requires running nodes.  However, I have a nagging suspicion that this may be the better option, since it is more portable, better supported in the community, and offers more control.

Believing that the pre-baked monitoring features of GAE, along with the excellent scaling abilities, request tracing, and simple app requirements, to be the best value/time ratio, I decide on App Engine Standard (python39).  In hindsight, this may have been a mistake.  The "auto-magic" nature of its execution, along with the weird rules it enforces, makes it extremely unkind to Terraform. More details are provided below.


### Database

The DB only really needs to be written to once, and must be production hardened for a demanding read load.  The following db solutions were considered:

* Object storage (GCS) - blob file store for static web content.  Offers multi-region storage, object versioning, and global CDN caching abilities.  Since there is only one static message to be read, this could be a good option, but it limits the ability to create dynamic content down the line.

* SQL Cluster - one write and multiple read heads.  SQL dbs, like postgres, offer strong consistency and complex relational relationships between entities.  They are not designed for the scaling and HA needs of modern distributed web architecture, and should be avoided unless strong consistency, relational data, or complex queries are needed.  In this case I only have one point of data to write once and read a million more, so this doesn't seem like an ideal option.

* NoSQL - NoSQL dbs leverage non-relational data and eventual consistency so that they can be automatically distributed and scaled for high read/write demands and high availability. There are different kinds of NoSQL dbs available for different types of data and usage patterns.  The simplest kind would be a key/value store, which is all that is needed for this example.  Bigtable, Redis, and Consul are examples that could function here.  However, I decided to use the google-managed Firestore db, which is an advanced, strongly consistent NoSQL document store. It offers more flexibility in the data it can handle (although it does key:value just fine), has a serverless design, is highly scalable, and is less prone to creating hot spots on the backend.  It also has great python client library support, and integrates with App Engine nicely.


## Implementation

### The State Backend

First thing's first, I need to create a state backend for the Terraform, and create the project resource.  In my experience, it is important to keep this separate from other parts of the terraform, so they were given their own folder, `00-backend`. Placing it together with other resources creates issues when trying to tear down other environments and configurations, since it will also try to tear down the bucket it is storing the state in.

This was my first time using Terraform with GCP, and there were some challenges here. Notably, there's a chicken and egg problem when using a GCS state backend.  The Terraform needs to create the project the bucket will reside in first, without using backend state. Then the user needs to set their gcloud project to the new project, authenticate using their default application credentials, create the state bucket, then update the config to use the backend bucket, and export the local state to the remote backend.  I attempted to write a `bootstrap.sh` script to handle all of this.

First set the variables in `terraform.tfvars`, and double check to make sure your org ID and billing account name are correct.  Then, execute `bootstrap.sh`. Part of it will require you to authenticate your Google account, please do so.

If you run into errors and need to start over, you will need to delete any remaining `*.tfstate*` files and the `.terraform` directory first.

Ensure that it runs successfully and outputs the `project` resource.  This is required for the other Terraform resources.  They will also use the project_id set here, so you won't have to change it in multiple places.

### The GAE Application

Before we get into the terraform for the application, we need to write the application itself.  The code for the Python application is located in `01-hello-world/app`.  It is a simple Flask app that uses gunicorn WSGI for the http service/entrypoint. It checks Firestore to see if the greeting data is present, and if not, it writes the "Hello World!" message to the database, and attempts to read from it again.  Once present, it will display the contents of the greeting entity in the database on a simple webpage.  I confirmed that this worked locally before moving on to GAE. After confirming that it worked with GAE using the command-line instructions provided in the docs, I started a new project and attempted to implement this using terraform.  Then all of the problems started to happen.



### Terraform/GAE Problems

Although there are terraform resources available for managing GAE and deploying the application code to new services/versions, in practice it doesn't work very well.

To start, there are rules for GAE that aren't conducive to Terraform IaC.  Namely, there can only be one `google_app_engine_application` per project, and once created, it cannot be deleted (you have to delete the entire project). Second, no service can be created without first deploying the `default` service, which also can't be deleted. Third, the oldest version for each service also can't be removed, which terraform will try to do if certain changes are made to the version resource.

I tried to get around this by creating a separate resource for the default service, and another resource for a user-managed `helloworld` service, which depends on the `default` service being created first.  In theory this should work, but I experienced a host of different issues and errors when running it for the first time.  Many of the API errors aren't clear about what the problem is, and I eventually figured out that the real error messages are hidden in Cloud Build and Cloud Logging for the "behind the scenes" build and deployment steps.

Furthermore, most of the issues appear to either be transient in nature and go away on subsequent runs of the terraform code, or require that the app be deployed once using the gcloud command line tool to "set up" whatever needs to be initialized on the backend.

If you see errors when applying the terraform here, waiting 5-10 minutes after creation of the `google_app_engine_application.helloworld` resource and running:
```bash
gcloud app deploy --version init
```
in the `app` directory seems to fix many of the transient issues, and subsequent runs of the terraform will work.  Not ideal, but I'm at the point where I would be reaching out to GCloud support to better understand what the problem is, or potentially abandoning this approach and starting over with GKE, or something else more simple and direct.

There's probably a way to make this work in one go using terraform, but I'm afraid I might burn through a lot more time that I could have used to just do something different.  I was advised not to start over, so I'm presenting the project as-is, with the hope that we can discuss these issues in person. 

## Monitoring
The good news is that once the app has been deployed, a world of monitoring metrics are ready to go.  They can be viewed in the Cloud Monitoring tool, and provide access to common metrics like CPU and Memory usage (good for spotting load or memory leaks), but also other really useful metrics like http response codes, and request latency, which is probably the most useful of the bunch.

There is also Cloud Trace, which tracks requests through the application and measures the latency at each hop and service, which helps identify bottlenecks.  There is cloud debugging for debugging purposes, and you can also set up memcache to reduce load on the DB and serve common requests quicker.  Cloud Logging aggregates the application and request/health check logs, providing a powerful search interface. Alerts can be set up for both metrics and logs.  There's a lot to work with here.

## Final thoughts
Ultimately this is a project that can potentially go on ad infintum, constantly adding more features, monitoring, and production-hardening.  It also needs a CI/CD system for testing and deployments, which I did not have the time to implement here.

However, when trying to implement everything at once, it becomes easy to get lost, resulting in a lot of work expended on premature optimization and personal rabbit-holes that lead to dead-ends.  It is better to start with simple solutions, and to gradually improve upon them in incremental steps.

I wanted to save time and deliver a robust solution using pre-baked technology, but I ended up spending more time trying to fix bugs than I might have by implementing something simpler first.

## Author
Garrett Anderson <garrett@devnull.rip>
