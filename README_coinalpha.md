## Included Changes

- [Fix Unclosed AIOKafkaConnection when connecting to semi-broken broker](https://github.com/aio-libs/aiokafka/pull/739)
- [Fix asyncio.CancelledError handling in Sender.\_fail\_all()](https://github.com/aio-libs/aiokafka/pull/711)
  - Note: merged by upstream with some changes


## Setup to run tests on Ubuntu 20.04

```
sudo apt install libkrb5-dev krb5-user
```
