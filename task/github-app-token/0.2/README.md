# GitHub app token

A task to get a user token from a github application

## Workspaces

- **secrets**: A workspace containing the private key of the application.

## Secret

This GitHub applications needs a private key to sign your request with JWT. 

[This](../0.2/samples/secret.yaml) example can be referred to create the secret

Refer [this](https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/setup-credentials.html) guide for setting up AWS Credentials and Region.


## Params

* **installation_id:** The GitHub app installation ID _eg:_ `123456`
* **application_id:** The GitHub application ID. _e.g:_ `123456`
* **private_key_path:** The path to the key inside the secret workspace, _default:_
  `private.key`
* **application_id_path:** The path to installation_id inside the secret workspace, it will use it if it can find it or use the params.application_id instead, _default:_ `application_id_path`

* **token_expiration_minutes:**: The time to expirations of the token in minutes _default:_ `10`


### Install the Task

```
kubectl apply -f https://raw.githubusercontent.com/tektoncd/catalog/main/task/github-app-token/0.2/github-app-token.yaml
```


## Usage

After creating the task with the parameters, you should have the token as result in the task which can
be used in your pipeline to do github operations from the app as the target user.

See [this](../0.2/samples/run.yaml) taskrun example on how to start the task directly.

