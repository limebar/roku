#
# targeting 720p, if changed, re-calc overlay x & y positions below
#
settings.frame.video.width := 1280
settings.frame.video.height := 720

#
# setup sources
#
allMusic =        playlist(mode="randomize", reload_mode="watch", "./videos/musicVideos")            # path to all videos to play
electronicMusic = playlist(mode="randomize", reload_mode="watch", "./videos/musicVideos/electronic") # path to electronic videos to play
ambientMusic =    playlist(mode="randomize", reload_mode="watch", "./videos/musicVideos/ambient")    # path to ambient videos to play
popMusic =        playlist(mode="randomize", reload_mode="watch", "./videos/musicVideos/pop")        # path to pop videos to play
rockMusic =       playlist(mode="randomize", reload_mode="watch", "./videos/musicVideos/rock")       # path to rock videos to play
jazzMusic =       playlist(mode="randomize", reload_mode="watch", "./videos/musicVideos/jazz")       # path to jazz videos to play
jingles =         playlist(mode="randomize", reload_mode="watch", "./videos/jingles/")               # path to station break videos
candy =           playlist(mode="randomize", reload_mode="watch", "./videos/candy/")                 # path to eye candy
safe =            single("./videos/safe/tibr.mp4")                                                   # path to known good video in case of failure
live =            input.rtmp("rtmp://localhost:8081/live",listen=true)                               # start an rtmp server to listen for live stream

#
# setup schedule and rotation and fallback
#
schedule = switch(
	[
	  ( {04h00-05h00}, jazzMusic), 
	  ( {05h00-06h00}, electronicMusic), 
	  ( {06h00-07h00}, rockMusic), 
	  ( {07h00-08h00}, popMusic), 
	  ( {08h00-10h00}, ambientMusic),
	  ( {16h00-17h00}, jazzMusic), 
	  ( {17h00-18h00}, electronicMusic), 
	  ( {18h00-19h00}, rockMusic), 
	  ( {19h00-20h00}, popMusic), 
	  ( {20h00-22h00}, ambientMusic),
	  ( {true}, allMusic )
    ] )	
s = rotate(weights=[1, 4, 1, 2], [jingles, schedule, candy, schedule])  # play 1 jingle, 4 videos, 1 candy, 2 videos
s = fallback(track_sensitive = false, [live, s, safe])                  # play live, else, videos/jingles, else known good station id

#
# setup metadata extraction for overlays and qr code
#
current_title = ref("")            # define globals for metadata overlay
current_artist = ref("")
current_album = ref("")
current_www = ref("")
current_qr = ref("")

def update_current_song(m) =
  current_title := m["title"]      # pull out metadata and populate globals
  current_artist := m["artist"] 
  current_album := m["album"] 
  current_www := m["www"] 
  current_qr := "https://api.qrserver.com/v1/create-qr-code/?size=180x180&data=#{current_www()}"  
end

s.on_metadata(update_current_song) # when track changes, update globals from mp4 metadata

#
# add overlays for metadata and images at bottom of screen
#
s = video.add_rectangle( color=0x333333, alpha=0.5, x=0, y=616, width=1280, height=108, s) # transparent band across bottom
s = video.add_cover( x=20, y=636, width=64, height=64, default="https://theindiebeat.fm/wp-content/uploads/2025/01/cropped-Catellite-TIBR-lime-1500x1500-1-192x192.png", s ) # tibr logo unless cover
s = video.add_image( x=1196, y=636, width=64, height=64, file=current_qr, s ) # qr code for artist link
s = video.add_text(color=0x000000, speed=0, x=96, y=638, size=18, current_artist, s) # drop shadow hack
s = video.add_text(color=0xb4fb51, speed=0, x=94, y=636, size=18, current_artist, s)
s = video.add_text(color=0x000000, speed=0, x=96, y=661, size=18, current_title, s)  # drop shadow hack
s = video.add_text(color=0xb4fb51, speed=0, x=94, y=659, size=18, current_title, s)
s = video.add_text(color=0x000000, speed=0, x=96, y=684, size=18, current_album, s)  # drop shadow hack
s = video.add_text(color=0xb4fb51, speed=0, x=94, y=682, size=18, current_album, s)
s = video.rectangle(color=0xb4fb51, x=0, y=718, height=2, width={int(1280.0*source.elapsed(s) / source.duration(s))}, s) # progress bar at bottom

#
# encode for owncast streaming via rtmp
#
encoder3k = %ffmpeg(
    format="flv", 
    %video(codec="libx264", "x264-params"="keyint=60:min-keyint=60:scenecut=0:tune=zerolatency", hwaccel="auto", pixel_format="yuv420p", b="3000k", preset="veryfast", r=25, g=50),
    %audio( codec="aac", b="128k", samplerate=48000 )
)				 
encoder1k = %ffmpeg(
    format="flv", 
    %video(codec="libx264", "x264-params"="keyint=60:min-keyint=60:scenecut=0:tune=zerolatency", hwaccel="auto", pixel_format="yuv420p", b="1000k", preset="veryfast", r=25, g=50),
    %audio( codec="aac", b="128k", samplerate=48000 )
)
#
# output via rtmp to owncast or peertube servers (multiple at once if needed)
#
#output.url(fallible=true,url="rtmp://live.theindiebeat.fm/live/STREAM_KEY",encoder3k,s)
#output.url(fallible=true,url="rtmp://communitymedia.video:1935/live/STREAM_KEY",encoder1k,s)
output.url(fallible=true,url="rtmp://localhost/live/abc123",encoder3k,s)
