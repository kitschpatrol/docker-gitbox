IMAGE_NAME=kitschpatrol/gitbox
CONTAINER_NAME=gitbox

docker stop $CONTAINER_NAME
docker rm $CONTAINER_NAME
docker build --rm=true -t $IMAGE_NAME .
docker run -d -it --name $CONTAINER_NAME -p 80:80 -v "$PWD/repos:/repos" $IMAGE_NAME
