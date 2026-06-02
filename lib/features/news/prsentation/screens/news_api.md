1.get video news api
method -> get
https://rozgaradda.com/api/video-news
response
{
    "status": true,
    "message": "Video News List",
    "data": [
        {
            "id": 4,
            "title": "Test",
            "subject": "Test",
            "video": "videos\/1773694090.mp4", //THIS WILL BE A VIDEO URL
            "added_by": 4,
            "status": "approved",
            "created_at": "2026-03-16 20:48:10"
        },
        {
            "id": 2,
            "title": "test",
            "subject": "sub 2",
            "video": "videos\/1773680841.mp4",
            "added_by": 15,
            "status": "approved",
            "created_at": "2026-03-16 17:07:21"
        }
    ]
}


2.get youtube video news api
method -> get
https://rozgaradda.com/api/videos-news

response :-
[
    {
        "id": 4,
        "title": "ggggg",
        "youtube_url": "https://www.youtube.com/watch?v=TMbSp5Gb1JQ",
        "description": "vdfvfd",
        "thumbnail_url": "https://img.youtube.com/vi/TMbSp5Gb1JQ/hqdefault.jpg",
        "youtube_id": "TMbSp5Gb1JQ",
        "created_at": "2026-02-06T18:43:34.000000Z",
        "updated_at": "2026-02-06T18:43:34.000000Z"
    }
]

2.get text news api
method -> get

https://rozgaradda.com/api/text-news
response:-
{
    "status": true,
    "message": "Text News List",
    "data": [
        {
            "id": 1,
            "title": "Latest Political News: “Cockroach Janta Party” Goes Viral in India",
            "category": "politics",
            "description": "A satirical online movement called the “Cockroach Janta Party” has become one of the most talked-about political trends in India this week. The movement reportedly started after controversial comments about unemployed youth triggered massive reactions on social media. Within days, the parody party gained millions of followers online and became a symbol of frustration among Gen Z regarding unemployment, inflation, and politics.",
            "image": "news/1779446371.png",
            "status": "approved",
            "is_seen": 1,
            "added_by": 7,
            "created_at": "2026-05-22 10:39:31",
            "image_url": "https://rozgaradda.com/news/1779446371.png"
        }
    ]
}