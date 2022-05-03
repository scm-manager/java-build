<p align="center">
  <a href="https://scm-manager.org/">
    <img alt="SCM-Manager" src="https://download.scm-manager.org/images/logo/scm-manager_logo.png" width="500" />
  </a>
</p>
<h1 align="center">
  scmmanager/java-build
</h1>

OCI Image which contains all tools, sdks and libraries which are required to build and test SCM-Manager and its plugins.

## Install

The image is available on [Docker Hub](https://hub.docker.com/r/scmmanager/java-build) and can be pulled with the following command:

```bash
docker pull scmmanager/java-build:tag
```

Note: `tag` must be replaced with a [available tag](https://hub.docker.com/r/scmmanager/java-build/tags?page=1&ordering=last_updated).

## Build

In order to build the image just call:

```bash
docker build -t scmmanager/java-build
```

## Release

Just push a release branch with the new version (e.g.: `release/11.0.15_10`).

## Need help?

Looking for more guidance? Full documentation lives on our [homepage](https://scm-manager.org/docs/) or the dedicated pages for our [plugins](https://scm-manager.org/plugins/). Do you have further ideas or need support?

- **Community Support** - Contact the SCM-Manager support team for questions about SCM-Manager, to report bugs or to request features through the official channels. [Find more about this here](https://scm-manager.org/support/).

- **Enterprise Support** - Do you require support with the integration of SCM-Manager into your processes, with the customization of the tool or simply a service level agreement (SLA)? **Contact our development partner Cloudogu! Their team is looking forward to discussing your individual requirements with you and will be more than happy to give you a quote.** [Request Enterprise Support](https://cloudogu.com/en/scm-manager-enterprise/).
