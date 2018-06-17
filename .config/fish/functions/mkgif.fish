# make a .gif from a .mov
function mkgif --description "Create a GIF file from a QuickTime Movie"
  set args (count $argv)
  if math "$args < 3" > /dev/null
    echo "USAGE: mkgif 000x000 in.mov out.gif [delay=4]"
  else
    if test -n $argv[4]
      set delay $argv[4]
    else
      set delay 4
    end
    ffmpeg -i $argv[2] -s $argv[1] -pix_fmt rgb24 -r 10 -f gif - | gifsicle --optimize=3 --delay=$delay > $argv[3]
  end
end
