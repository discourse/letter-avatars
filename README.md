This is the "Letter Avatar" microservice, a means of generating a simple
coloured letter image, for use as a generic avatar.  It was first
implemented for use as part of the [Discourse](http://discourse.org)
platform, however it can be used for any service which requires a simple,
distinctive avatar for users who haven't set one themselves.


# API

The only resource which this service will respond to is the path:

    /letter/[a-z]

The variable part indicates which letter to render.  It can be specified as
uppercase or lowercase, and will be rendered in uppercase in all
circumstances.

From version 4 onwards, the requested letter can be any unicode character, 
URL encoded or not. If the character can't be draw using any of the fonts
availiable in the fonts directory, the response will be 404.

The URL can take the following query parameters.  All are optional, and
have halfway-reasonable defaults.

* `r` (default: 0) the "red" component of the background colour to use in
  the image.

* `g` (default: 0) the "green" component of the background colour to use in
  the image.

* `b` (default: 0) the "blue" component of the background colour to use in
  the image.

* `size` (default: 50) the number of pixels wide and high to make the image. 
  All avatar images are squares.

* `v` (default: 1) which version of the API to use.  Version 4 has unicode support.


# Deployment

Dockerfile ftw!
