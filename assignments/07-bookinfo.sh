git clone -b dev git@github.com:WSBoos/itkmitl-bookinfo-details.git ~/62070166/itkmitl-bookinfo-details
docker build -t image_details ~/62070166/itkmitl-bookinfo-details/
docker run -d --name details -p 8081:8081 image_details

git clone -b dev git@github.com:WSBoos/itkmitl-bookinfo-ratings.git ~/62070166/ratings
docker build -t ratings ~/62070166/ratings/
# Run MongoDB with initial data in database
docker run -d --name mongodb -p 27017:27017 \
  -v ~/62070166/ratings/databases:/docker-entrypoint-initdb.d bitnami/mongodb:5.0.2-debian-10-r2 
# Run ratings service on port 8080
docker run -d --name ratings -p 8080:8080 --link mongodb:mongodb \
  -e SERVICE_VERSION=v2 -e 'MONGO_DB_URL=mongodb://mongodb:27017/ratings' ratings

git clone -b dev git@github.com:WSBoos/itkmitl-bookinfo-reviews.git ~/62070166/itkmitl-bookinfo-reviews
docker build -t image_reviews ~/62070166/itkmitl-bookinfo-reviews/
docker run -d --name reviews -p 8082:8082 --link ratings:ratings -e ENABLE_RATINGS=true -e STAR_COLOR=LemonChiffon -e RATINGS_SERVICE=http://ratings:8080 image_reviews

git clone -b dev git@github.com:WSBoos/itkmitl-bookinfo-productpage.git ~/62070166/itkmitl-bookinfo-productpage
docker build -t image_productpage ~/62070166/itkmitl-bookinfo-productpage/ 
docker run -d --name productpage -p 8083:8083 --link details:image_details --link reviews:image_reviews --link ratings:ratings -e DETAILS_HOSTNAME=http://image_details:8081 -e RATINGS_HOSTNAME=http://ratings:8080 -e REVIEWS_HOSTNAME=http://image_reviews:8082  image_productpage  