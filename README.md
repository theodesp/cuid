# CUID: Collision-resistant ids optimized for horizontal scaling and performance.

[![Build Status](https://travis-ci.org/theodesp/cuid.svg?branch=master)](https://travis-ci.org/theodesp/cuid)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Implementation of https://github.com/ericelliott/cuid in Racket/Scheme.

A `cuid` is a portable and sequentially-ordered unique identifier designed for horizontal scalability and speed -- this version is ported from the reference implementation in Javascript.



Example

```
> (cuid)
"c0JU1BP7VK0000JENK2MF8ZMHN"
> (slug)
"LH0001EK8R"
```


## Broken down
** c - 0JU1BP7VK - 0000 - JENK - 2MF8ZMHN **

The groups, in order, are:

**`c`** - identifies this as a cuid, and allows you to use it in html entity ids.
**Timestamp**
**Counter** - a single process might generate the same random string. The weaker the pseudo-random source, the higher the probability. That problem gets worse as processors get faster. The counter will roll over if the value gets too big.
**Client fingerprint**
**Random** (using cryptographically secure libraries where available).

## Short URLs
Need a smaller ID? `slug` is for you. With 10 characters, `slug` is a great solution for short urls. 
They're good for things like URL slug disambiguation (i.e., example.com/some-post-title-<slug>) but absolutely not recommended for database unique IDs. Stick to the full `cuid` for database keys.

## License
MIT License © 2019 Theo Despoudis