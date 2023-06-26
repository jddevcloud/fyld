# 5. Messaging System

Date: 2019-09-30

## Status

Accepted

## Context

We need to think about a structured and consistent way of communication
between the clients and our backend. In particular not the structured
backend aka the API but more the maestro (Data Science piece).

## Decision

We've decided to create a event based system. 
This system consists of:
- **Socketing connection** for direct messages.
- A **publisher function**, which is a lambda function that is subscribed to
  a set of events.
- An **SQS queue**.
- An **orchestrator function**, which receives the messages and calls the
  correct lambda task-function. 
  
More of this is explained in the maestro repository.

## Consequences

Whenever we want to add a new task to the AI we need to follow this
structure.
