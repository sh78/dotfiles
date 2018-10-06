# See https://developers.google.com/speed/docs/insights/OptimizeImages
function strip --description "Losslessly compress a PNG, JPG, or GIF for web"
  for file in $argv
    # TODO: this will barf on file names with .
    set name (echo $file|cut -d '.' -f1)
    set extension (echo $file|cut -d '.' -f2)
    set outfile (echo $name"_converted."$extension)
    echo $outfile
    if [ "$extension" = "jpeg" ]
      convert $file -sampling-factor 4:2:0 -strip -quality 85 -interlace JPEG -color space sRGB $outfile
    else if [ "$extension" = "jpg" ]
      convert $file -sampling-factor 4:2:0 -strip -quality 85 -interlace JPEG -colorspace sRGB $outfile
    else if [ "$extension" = "png" ]
      convert $file -strip $outfile
    else if [ "$extension" = "gif" ]
      gifsicle -O3 $file -o $outfile
    end
  end
end
