# Nginx Fine Tuning

Configure nginx that will cache only images, that were requested at least twice.
Add the ability to drop nginx cache by request.
You should drop cache for a specific file only (not all cache).


Start server: ```docker-compose up```

# Results
1) Open http://localhost:8000/static/test_image_1.png in browser. You should see ```X-Cache-Status: MISS header```.
2) Refresh page 2 times and you see ```X-Cache-Status: HIT```
3) Purge image cache: curl -X PURGE http://localhost:8000/static/test_image_1.png
4) Open again http://localhost:8000/static/test_image_1.png in browser and you can see ```X-Cache-Status: MISS```


The results are located in the folder: ```results```