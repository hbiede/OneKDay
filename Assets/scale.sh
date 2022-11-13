for image in *.png;
do
    filename=$(basename -- "$image");
    filename="${filename%.*}";
    ffmpeg -i $image -vf scale=60:60 "$filename-Preview.png";
    ffmpeg -i $image -vf scale=120:120 "$filename-Preview@2x.png";
    ffmpeg -i $image -vf scale=180:180 "$filename-Preview@3x.png";
done
