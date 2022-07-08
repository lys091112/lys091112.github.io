
server:
	hugo server -D

deploy:
	hugo -t even
	git checkout master
	rm -rf ./docs
	mv ./hugo/public ./docs
	git add .
	git commit -m "deploy"
	git push origin master