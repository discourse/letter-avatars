This is the "Letter Avatar" microservice, a means of generating a simple
coloured letter image, for use as a generic avatar.  It was first
implemented for use as part of the [Discourse](http://discourse.org)
platform, however it can be used for any service which requires a simple,
distinctive avatar for users who haven't set one themselves.


# API

The only resource which this service will respond to is the path:

    /v[VERSION_NUMBER]/letter/[CHARACTER]/[HEX_COLOR]/[SIZE].png

`CHARACTER` indicates which letter to render.  It can be specified as
uppercase or lowercase, and will be rendered in uppercase in all
circumstances.

`HEX_COLOR` defines the background color.

From `VERSION_NUMBER` 4 onwards, the requested letter can be any unicode character, 
URL encoded or not. If the character can't be draw using any of the fonts
availiable in the fonts directory, the response will be 404.

* All avatar images are square.

* Maximum size is 360px (FULLSIZE)

* Images are cached.

# Deployment

`docker compose up`
