# API reference

This document shows how to suppress rules with inline comments.

## Overview

The API lets you manage resources. You can create, read, update, and
delete items with simple calls.

<!-- vale Ghalactic.Will = NO -->

In a future release, the API will support batch operations.

<!-- vale Ghalactic.Will = YES -->

## Authentication

To log in, send a POST request to the `/auth` endpoint. The server
returns a token that you include in later requests.
