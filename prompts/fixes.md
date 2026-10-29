---
description: Address review comments without resolving them
argument-hint: "[PR numbers]"
---
PR numbers: $ARGUMENTS

Address the review comments on the PRs named in this request. If none is named, ask which.

The PR numbers in this request are the only ones to use. Never reuse a number from an
earlier round or another conversation.

Check the branch out and read it from the working tree. Do not review file-by-file through
the forge API.

You are the builder this round. Follow `reviewing-changes` in fix mode, and the
repository's own review skill if it has one.
