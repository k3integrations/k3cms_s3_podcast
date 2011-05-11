K3cms S3 Podcast
================

Simple podcast functionality for K3cms.

You can store your podcast assets on any server. Just choose a naming convention for your asset files
(for example, all episodes will be in a folder with the **year** and their filename will be based on a unique **code** that you give each episode)
and enter that information in your podcast in the list of episode source URLs (for example, `http://my_podcast.s3.amazonaws.com/{year}/episode_{**code**}.mp4`).
This gem will take care of interpolating values from each episode into your source URL pattern, in this example replacing `{code}` with the actual code that you entered for that episode and `{year}` with the year from the date you entered for that episode.
As long as you are consistent in organizing and naming your files, this makes things really simple! 

You can use any scheme that you want for your source URLs, using any combination of the following placeholders:
* `{code}`
* `{year}`
* `{month}`
* `{day}`

You have the same flexibility for specifying the URLs of the poster image for your episodes as you do for the video/audio sources themselves.

About the name
--------------

This gem was named "S3 Podcast" after Amazon S3, but you can use any other hosting service that you want for your asset files, not just Amazon S3.

Troubleshooting
===============

303: Failed to load a resource: Unable to load resources: Error #2035
---------------------------------------------------------------------

Even if your video URL is correct, you might still see this error.

If your video player gives you this message, it could mean that your podcast's *image* URL is to blame. Double check that you entered the correct image URL.

Unfortunately, any time the image URL is broken, it will prevent playing of the video itself. This appears to be a bug with the VideoJS video player library that was used. We hope to find a solution to this.

Running Tests
=============

    rake test_app
    rake spec

License
=======

Copyright 2011 [K3 Integrations, LLC](http://www.k3integrations.com/)

k3cms_s3_podcast is free software, distributed under the terms of the [GNU Lesser General Public License](http://www.gnu.org/copyleft/lesser.html), Version 3 (see License.txt).
