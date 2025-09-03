# The Indie Beat Television 

A liquidsoap implementation of a music video 24x7 broadcast channel for https://theindiebeat.fm

## Features:
- Scheduled program slots for Rock, Pop, Jazz, Electronic, Ambient music
- Scheduled program slots for Animation Array and NHAM curated shows
- Remainder of time is shuffle play of all music videos
- Plays station jingle, followed by several program slot music videos, an eye candy video, followed by few more program slot music videos, repeat.
- Plays a program slot title periodically during the program slot 
- Supports a live insert for scheduled live programs
- Supports a local telnet server for cmd injection during live playback (like reload playlists without restart)
- Can output to multiple rtmp owncast or peertube, etc. targets at once if needed
- Can run as an auto-restart init.d daemon
- Displays station logo, artist, title, album metadata and a qr code to the artist WWW link pulled from the MP4 video metadata during playback
- Also writes a nowplaying.json file for each new video from MP4 metadata
- Also exposes an http /nowplaying endpoint for json nowplaying info

Really good quality running on a contabo 6 core VPS Ubuntu 24.04LTS with 1080p MP4 videos and 720p output stream directed at Owncast server running on the same VPS. Struggles with 4k videos.

Copy all files into /media/tibrtv/ 

## Directory structure
```
/media
   /tibrtv
	  tibr.liq
      nohup.out
	  /genQR
	     genQR.sh
		 tibrQR.png
		 <wwwlink>.png files
	  /videos
         /safe
            tibr.mp4 (safe fallback station id)
            tibrcatellite.png (safe fallback logo for cover art)		    
         /animato
		    <list of mp4 files for Animation Array>
         /candy
		    <list of mp4 files for periodic Eye Candy>
         /jingles 
		    <list of mp4 files for station ID jingles>
		 /outofrotation 
		    <list of mp4 files not to be aired, move files here when out of rotation>
         /showTitles		 
		    /ambient
		       <list of mp4 files>
			/electronic
		       <list of mp4 files>
			/jazz
		       <list of mp4 files>
			/nham
		       <list of mp4 files>
			/pop
		       <list of mp4 files>
			/rock 
   		       <list of mp4 files>
         /musicVideos
		    /ambient
		       <list of mp4 files>
			/electronic
		       <list of mp4 files>
			/jazz
		       <list of mp4 files>
			/nham
		       <list of mp4 files>
			/pop
		       <list of mp4 files>
			/rock 
   		       <list of mp4 files>
			/misc
   		       <list of mp4 files for general rotation not in any program slot>
```

## QR Code Generation
Use cron job every 4 hours to run genQR.sh (trailing / is important):
```
    ./media/tibrtv/genQR/genQR.sh /media/tibrtv/
```

## Misc
Requires liquidsoap 2.3.3 or greater to support add_cover() - use OCAML 4 version for Noble on 24.04 LTS
-  https://github.com/savonet/liquidsoap/releases/tag/v2.3.3
Download and install 2.3.3 deb package: 
```
sudo dpkg -i liquidsoap_2.3.3-ubuntu-noble-ocaml4.14.2-1_amd64.deb
```

Useful links:
- https://github.com/savonet/liquidsoap/discussions/4630 handle leak
- https://github.com/savonet/liquidsoap/discussions/4606 recursion watch
- https://github.com/savonet/liquidsoap/discussions/4607 rtmp security
- https://github.com/savonet/liquidsoap/discussions/4611 add_cover() for video files
- https://github.com/savonet/liquidsoap/discussions/4649 daemon restart
- https://www.liquidsoap.info/doc-2.3.3/reference.html# reference 
- https://github.com/savonet/liquidsoap/discussions discussion
- https://github.com/savonet/liquidsoap/releases/tag/v2.3.3 v2.3.3 release (not in apt yet)
- https://www.liquidsoap.info/doc-2.3.3/reference.html#url.encode 
- https://mikulski.rocks/creating-a-24-7-lofi-like-stream-part-2/ tutorial
- https://www.liquidsoap.info/blog/2024-02-10-video-canvas-and-ai/ overlays 
- https://installati.one/install-liquidsoap-ubuntu-20-04/ apt install
- https://medium.com/@moniruzzamanshimul/how-to-set-up-and-automount-an-oci-object-storage-on-ubuntu-using-s3fs-fb0b7f26eaa4 s3 object storage mounting
- https://mikulski.rocks/buffer-for-overlays-liquidsoap/ buffer for overlays for async performance
- https://www.liquidsoap.info/blog/2023-03-10-how-to-run-a-http-server-with-liquidsoap/ exposing a simple http server



