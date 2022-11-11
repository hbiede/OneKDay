for image in *.png;
do
    filename=$(basename -- "$image");
    filename="${filename%.*}";
    ffmpeg -i $image -vf scale=60:60 "$image-Preview.png";
    ffmpeg -i $image -vf scale=120:120 "$image-Preview@2x.png";
    ffmpeg -i $image -vf scale=180:180 "$image-Preview@3x.png";
done
