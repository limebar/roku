#
# targeting 720p, if changed, re-calc overlay x & y positions below
#
settings.frame.video.width := 1280
settings.frame.video.height := 720
settings.init.allow_root := true       
settings.server.telnet := true         # telnet localhost 1234 - send help for list of cmds

tibrtv = "/media/tibrtv"               # path to root of the station assets

#
# setup sources
#
safe =     single( id="safe","#{tibrtv}/videos/safe/tibr.mp4" )                                                         # path to known good video in case of failure
live =     input.rtmp( id="live","rtmp://live.theindiebeat.fm:1936/live/STREAM_KEY",listen=true )                       # start a rtmp server to listen for live stream - TODO update SERVER PORT STREAM_KEY
jingles =  playlist( id="jingles",  mode="randomize", reload_mode="watch", "#{tibrtv}/videos/jingles" )                 # path to station break videos
candy =    playlist( id="candy",    mode="randomize", reload_mode="watch", "#{tibrtv}/videos/candy" )                   # path to eye candy
allMusic = playlist( id="allMusic", mode="randomize", reload_mode="watch", "#{tibrtv}/videos/musicVideos/" )            # path to all videos 
eleMusic = playlist( id="eleMusic", mode="randomize", reload_mode="watch", "#{tibrtv}/videos/musicVideos/electronic/" ) # path to program videos
ambMusic = playlist( id="ambMusic", mode="randomize", reload_mode="watch", "#{tibrtv}/videos/musicVideos/ambient/" )    # 
popMusic = playlist( id="popMusic", mode="randomize", reload_mode="watch", "#{tibrtv}/videos/musicVideos/pop/" )        # 
rocMusic = playlist( id="rocMusic", mode="randomize", reload_mode="watch", "#{tibrtv}/videos/musicVideos/rock/" )       # 
jazMusic = playlist( id="jazMusic", mode="randomize", reload_mode="watch", "#{tibrtv}/videos/musicVideos/jazz/" )       # 
nhaMusic = playlist( id="nhaMusic", mode="randomize", reload_mode="watch", "#{tibrtv}/videos/musicVideos/nham/" )       # 
aniVideo = playlist( id="aniVideo", mode="randomize", reload_mode="watch", "#{tibrtv}/videos/animato/" )                # path to animation hour videos
eleTitle = playlist( id="eleTitle", mode="randomize", reload_mode="watch", "#{tibrtv}/videos/showTitles/electronic/" )  # path to program hour titles
ambTitle = playlist( id="ambTitle", mode="randomize", reload_mode="watch", "#{tibrtv}/videos/showTitles/ambient/" )     #
popTitle = playlist( id="popTitle", mode="randomize", reload_mode="watch", "#{tibrtv}/videos/showTitles/pop/" )         #
rocTitle = playlist( id="rocTitle", mode="randomize", reload_mode="watch", "#{tibrtv}/videos/showTitles/rock/" )        #
jazTitle = playlist( id="jazTitle", mode="randomize", reload_mode="watch", "#{tibrtv}/videos/showTitles/jazz/" )        # 
nhaTitle = playlist( id="nhaTitle", mode="randomize", reload_mode="watch", "#{tibrtv}/videos/showTitles/nham/" )        #
aniTitle = playlist( id="aniTitle", mode="randomize", reload_mode="watch", "#{tibrtv}/videos/showTitles/animato/" )     #

#
# setup schedule and rotation and fallback
#
schedule = switch( id="schedule",
	[
	  ( {16h00-17h00}, rotate(id="jazHour",weights=[1, 5], [jazTitle, jazMusic]) ), # 2pm UTC, 4pm CEST,  3pm BST,  10am EST
 	  ( {17h00-18h00}, rotate(id="eleHour",weights=[1, 5], [eleTitle, eleMusic]) ), # 3        5          4         11
	  ( {18h00-19h00}, rotate(id="rocHour",weights=[1, 5], [rocTitle, rocMusic]) ), # 4        6          5         12
	  ( {19h00-20h00}, rotate(id="popHour",weights=[1, 5], [popTitle, popMusic]) ), # 5        7          6         1
	  ( {20h00-21h00}, rotate(id="ambHour",weights=[1, 5], [ambTitle, ambMusic]) ), # 6        8          7         2
	  ( {21h00-22h00}, rotate(id="nhaHour",weights=[1, 5], [nhaTitle, nhaMusic]) ), # 7        9          8         3
	  ( {22h00-23h00}, rotate(id="aniHour",weights=[1, 5], [aniTitle, aniVideo]) ), # 8        10         9         4
	  ( {23h00-00h00}, rotate(id="jazHour",weights=[1, 5], [jazTitle, jazMusic]) ), # 9pm UTC, 11pm CEST, 10pm BST, 5pm EST
	  ( {00h00-01h00}, rotate(id="eleHour",weights=[1, 5], [eleTitle, eleMusic]) ), # 10       12         11        6
	  ( {01h00-02h00}, rotate(id="rocHour",weights=[1, 5], [rocTitle, rocMusic]) ), # 11       1          12        7
	  ( {02h00-03h00}, rotate(id="popHour",weights=[1, 5], [popTitle, popMusic]) ), # 12       2          1         8
	  ( {03h00-04h00}, rotate(id="ambHour",weights=[1, 5], [ambTitle, ambMusic]) ), # 1        3          2         9
	  ( {04h00-05h00}, rotate(id="nhaHour",weights=[1, 5], [nhaTitle, nhaMusic]) ), # 2        4          3         10
	  ( {05h00-06h00}, rotate(id="aniHour",weights=[1, 5], [aniTitle, aniVideo]) ), # 3        5          4         11
	  ( {true}, allMusic )
    ] )		
s = rotate( id="fullrotation",weights=[1, 7, 1, 5], [jingles, schedule, candy, schedule] )  

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
  #
  # select the cached qr code or default to tibrQR.png
  #
  if current_www() == "" then
     current_www := "https://theindiebeat.fm"
  end
  r = regexp(flags=["g"], "[:&?|*\"<>.\/]")
  cleanurl = r.replace((fun(_)->""),current_www())
  current_qr := "#{tibrtv}/genQR/" ^ cleanurl ^ ".png"
  if file.exists(current_qr())==false then 
     current_qr := "#{tibrtv}/genQR/tibrQR.png"
  end  
  
  #
  # write a now playing file
  #
  ignore(file.write(data="{\"song\":{\"link\":\"#{current_www()}\",\"artist\":\"#{current_artist()}\",\"title\":\"#{current_title()}\",\"album\":\"#{current_album()}\"}}", append=false, "#{tibrtv}/nowplaying.json"))  
end

s.on_metadata(update_current_song) # when track changes, update globals from mp4 metadata

#
# expose nowplaying info via http
#
def get_meta(_, response) =
  response.json(current_np())
end
harbor.http.register(port=8081, method="GET", "/nowplaying", get_meta)

#
# add overlays for metadata and images at bottom of screen 
#
overlay = blank()

overlay = video.add_rectangle( color=0x333333, alpha=0.5, x=35, y=611, width=1210, height=94, overlay)      # transparent band across bottom
#overlay = video.add_cover( fallible=true, x=40,   y=616, width=84, height=84, default="#{tibrtv}/videos/safe/tibrcatellite.png", overlay )  # mp4 cover not working yet
overlay = video.add_image( fallible=true, x=40,   y=616, width=84, height=84, file="#{tibrtv}/videos/safe/tibrcatellite.png", overlay )     
overlay = video.add_image( fallible=true, x=1156, y=616, width=84, height=84, file=current_qr, overlay )     # qr code for artist link
overlay = video.add_text(color=0x000000, speed=0, x=136, y=628, size=18, current_artist, overlay)            # drop shadow hack
overlay = video.add_text(color=0xb4fb51, speed=0, x=134, y=626, size=18, current_artist, overlay)
overlay = video.add_text(color=0x000000, speed=0, x=136, y=651, size=18, current_title, overlay)             # drop shadow hack
overlay = video.add_text(color=0xb4fb51, speed=0, x=134, y=649, size=18, current_title, overlay)
overlay = video.add_text(color=0x000000, speed=0, x=136, y=674, size=18, current_album, overlay)             # drop shadow hack
overlay = video.add_text(color=0xb4fb51, speed=0, x=134, y=672, size=18, current_album, overlay)
overlay = video.rectangle(color=0xb4fb51, x=35, y=701, height=2, width={int(1210.0*source.elapsed(s) / source.duration(s))}, overlay) # progress bar at bottom

overlay = buffer(max=2., overlay)
s = add( id="addOverlay",[s, overlay] )

#
# setup fallback order live->program->safe
#
s = fallback( id="fallback",track_sensitive = false, [live, s, safe] )      # with live insert        
#s = fallback( id="fallback",track_sensitive = false, [s, safe] )            # without live insert          

#
# encode for owncast streaming via rtmp
#
ffmpegRate = "3000k"         
ffmpegPreset = "veryfast"    # ultrafast superfast veryfast faster fast medium slow slower veryslow
encoder = %ffmpeg(
    format="flv", 
    %video(codec="libx264", "x264-params"="keyint=60:min-keyint=60:scenecut=0", hwaccel="auto", pixel_format="yuv420p", b="#{ffmpegRate}", preset="#{ffmpegPreset}", r=25, g=50),
    %audio( codec="aac", b="128k", samplerate=48000 )
)				 

#
# output via rtmp to owncast or peertube servers (multiple at once if needed)
#
#output.url(fallible=true,url="rtmp://communitymedia.video:1935/live/STREAM_KEY",encoder,s)    # peertube         TODO update STREAM_KEY
#output.url(fallible=true,url="rtmp://localhost/live/abc123",encoder,s)                        # local owncast    TODO update STREAM_KEY
output.url(fallible=true,url="rtmp://live.theindiebeat.fm/live/STREAM_KEY",encoder,s)          # tibr owncast     TODO update STREAM_KEY


