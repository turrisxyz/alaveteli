---
layout: page
title: File Storage
---

# File Storage

<p class="lead">
  Storage for raw emails and attachments.
</p>

<div class="attention-box">
  In Alaveteli 0.41 we switched from using our own bespoke storage for raw
  emails and attachments to use a third party library called
  <a href="{{ page.baseurl }}/docs/glossary/#activestorage" class="glossary__link">Active Storage</a>.
  This allows greater flexibility in where you store files.
</div>

The default approach to storing files is to store on the local disk but as your
install because larger this becomes less desirable as it means a lot of data to
be managed and backed up.

This guide will show you have to configure
<a href="{{ page.baseurl }}/docs/glossary/#activestorage" class="glossary__link">Active Storage</a>
to store your files on a cloud based service such as Amazon S3.

## Configuration

Unlike other Alaveteli's other
<a href="{{ page.base_url }}/docs/customising/config">configuration options</a>,
Active Storage uses a separate configuration file. An example configuration file
is shipped with Alaveteli: `config/storage.yml-example`. This gets copied to
`config/storing.yml` when using Alaveteli's install scripts.

This example file configures Alaveteli to use a local disk for storing files.
This will be good enough for new installations but you might want to store files
in the cloud.

## Cloud service

There are examples of the different cloud services (Amazon S3, Microsoft Azure,
Google Cloud) supported by Active Storage in the example configuration.

```
amazon:
  service: S3
  access_key_id: ''
  secret_access_key: ''
  region: ''
  bucket: ''

azure:
  service: AzureStorage
  storage_account_name: ''
  storage_access_key: ''
  container: ''

google:
  service: GCS
  credentials:
  project: ''
  bucket: ''
```

To use these you will need to set the `*_production` options with the relevant
cloud options from above. To use Amazon S3 you would set:

```
raw_emails_production: &raw_emails_production
  service: S3
  access_key_id: <<YOUR ACCESS KEY>>
  secret_access_key: <<YOUR SECRET ACCESS KEY>>
  region: <<YOUR REGION>>
  bucket: <<YOUR BUCKET>>

raw_emails:
  <<: *raw_emails_<%= Rails.env %>

attachments_production: &attachments_production
  service: S3
  access_key_id: <<YOUR ACCESS KEY>>
  secret_access_key: <<YOUR SECRET ACCESS KEY>>
  region: <<YOUR REGION>>
  bucket: <<YOUR BUCKET>>

attachments:
  <<: *attachments_<%= Rails.env %>
```

## Changing services

To change services you will need to migrate your files from your current service
to your new service.

This can be done by using a mirrored services.

## Mirrored services

To setup mirrored services you need to set a primary service and at least one
secondary service. In the example for raw emails below (which is taken from
whatdotheyknow.com) we use a local disk service as the primary and files are
mirrored to Amazon S3 automatically.

```
disk_raw_emails:
  service: Disk
  root: <%= Rails.root.join('storage/raw_emails') %>

cloud_raw_emails:
  service: S3
  access_key_id: <<YOUR ACCESS KEY>>
  secret_access_key: <<YOUR SECRET ACCESS KEY>>
  region: <<YOUR REGION>>
  bucket: <<YOUR BUCKET>>

raw_emails_production: &raw_emails_production
  service: Mirror
  primary: disk_raw_emails
  mirrors: [cloud_raw_emails]

raw_emails:
  <<: *raw_emails_<%= Rails.env %>
```

We would recommend using the local disk service as the primary as this will
allow use to use some `rake` tasks shipped with Alaveteli to

1. ensure files have been mirrored successfully
2. promote the cloud service to be the primary service for files older than 7
   days
3. remove files from the local disk service once they are being served directly
   from the cloud service.

To perform these tasks for all types of files you can run:
```
bundle exec rails storage:mirror storage:promote storage:unlink
```

In case you choose different approaches for `raw emails` and `attachments`, you
can run these tasks for a single file type. For raw emails run:
```
bundle exec rails storage:raw_emails:mirror storage:raw_emails:promote storage:raw_emails:unlink
```

For attachments run:
```
bundle exec rails storage:attachments:mirror storage:attachments:promote storage:attachments:unlink
```
