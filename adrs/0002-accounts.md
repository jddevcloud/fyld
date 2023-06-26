# 3. Accounts

Date: 2019-09-30

## Status

Accepted

## Context

Using AWS we could either just create a single account under BCG or
create a new detached account and then have the possibility to have
sub-accounts and a more well-structured and secure infrastructure.

## Decision

We've decided to move away from BCG account and use a detached one and
create a structure of accounts. So we have now a root account that ows
three sub-accounts: identity, staging and production.

## Consequences

We need to onboard users and give them assumed permissions and also we
need to pay for the root account ourselves. But we don't need to follow
the detaching procedure when the venture ends.
