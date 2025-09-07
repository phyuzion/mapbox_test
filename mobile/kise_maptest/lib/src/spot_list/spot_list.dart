const spotList = [
  {
    "name": "경복궁",
    "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/0/06/%EA%B2%BD%EB%B3%B5%EA%B6%81_%EA%B7%BC%EC%A0%95%EC%A0%84%28%E5%8B%A4%E6%94%BF%E6%AE%BF%29.jpg",
    "Lat": 37.580467,
    "Lon": 126.976944
  },
  {
    "name": "창덕궁",
    "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/b/b6/Changdeok_Palace_%28%EC%B0%BD%EB%8D%95%EA%B6%81%29_Seoul%2C_South_Korea.jpg",
    "Lat": 37.58256,
    "Lon": 126.99093
  },
  {
    "name": "창경궁",
    "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4b/%EC%B0%BD%EA%B2%BD%EA%B6%81_%EB%AA%85%EC%A0%95%EC%A0%84.jpg/960px-%EC%B0%BD%EA%B2%BD%EA%B6%81_%EB%AA%85%EC%A0%95%EC%A0%84.jpg",
    "Lat": 37.58035,
    "Lon": 126.995702
  },
  {
    "name": "덕수궁",
    "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/thumb/3/35/%EB%8D%95%EC%88%98%EA%B6%81.jpg/960px-%EB%8D%95%EC%88%98%EA%B6%81.jpg",
    "Lat": 37.56561,
    "Lon": 126.97479
  },
  {
    "name": "경희궁",
    "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/%EA%B2%BD%ED%9D%AC%EA%B6%81_%EC%88%AD%EC%A0%95%EC%A0%84_2.jpg/960px-%EA%B2%BD%ED%9D%AC%EA%B6%81_%EC%88%AD%EC%A0%95%EC%A0%84_2.jpg",
    "Lat": 37.57091,
    "Lon": 126.96812
  },
  {
    "name": "독립문",
    "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b9/Seodaemun_Monument%2C_Seoul.jpg/330px-Seodaemun_Monument%2C_Seoul.jpg",
    "Lat": 37.5722,
    "Lon": 126.9594
  },
  {
    "name": "환구단",
    "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/%ED%99%98%EA%B5%AC%EB%8B%A8_%EC%84%9D%EA%B3%A0_%282021%29.jpg/2560px-%ED%99%98%EA%B5%AC%EB%8B%A8_%EC%84%9D%EA%B3%A0_%282021%29.jpg",
    "Lat": 37.56516,
    "Lon": 126.97998
  },
  {
    "name": "장충단",
    "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/e/e7/%EC%9E%A5%EC%B6%A9%EB%8B%A8%EA%B0%95%EC%97%B0%ED%9A%8C.JPG",
    "Lat": 37.5594,
    "Lon": 126.9945
  },
  {
    "name": "서대문 형무소",
    "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/8/8c/%EC%84%9C%EB%8C%80%EB%AC%B8_%ED%98%95%EB%AC%B4%EC%86%8C.jpg",
    "Lat": 37.5746,
    "Lon": 126.9578
  },
  {
    "name": "광화문 광장",
    "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/e/e2/Gwanghwamun_Square_20220806_06.jpg",
    "Lat": 37.5717,
    "Lon": 126.9769
  },
  {
    "name": "명동",
    "imageUrl": "https://i.namu.wiki/i/M83Ei62MPIAgTNSbMk6xIiyO-a6kJF5YosvCWUXxyp-Mrv775zs37MIyZbgBojjWNlKQLXsMyxn6bXN5eySBezCLgdZ-1tX2MMn_gLbjze7u7B1rSL2vAAfODo2a4vAiABFOR-6gqTs_CP_ZdV5Jpw.webp",
    "Lat": 37.5642,
    "Lon": 126.9850
  },
  {
    "name": "인사동",
    "imageUrl": "https://a.travel-assets.com/findyours-php/viewfinder/images/res70/249000/249996-Insadong.jpg",
    "Lat": 37.5740,
    "Lon": 126.9817
  },
  {
    "name": "북촌 한옥마을",
    "imageUrl": "https://i.namu.wiki/i/DEvKxYg-TEz6O53jeZyS9kndJSgSQnFysm3T-R70yXIyWi9-HknJZXoK1ghHFMwB365TyyMj7MlIebAKMrLSFA.webp",
    "Lat": 37.5824,
    "Lon": 126.9830
  },
  {
    "name": "남산골 한옥마을",
    "imageUrl": "https://mediahub.seoul.go.kr/uploads/mediahub/2022/04/yIXkzRUCsXyqqmcczutxvWdWHtFDTttb.jpg",
    "Lat": 37.5590,
    "Lon": 126.9935
  },
  {
    "name": "삼청동",
    "imageUrl": "https://love.seoul.go.kr/tmda/image/upload/content/8menu01_03.jpg",
    "Lat": 37.5800,
    "Lon": 126.9795
  },
  {
    "name": "청계천",
    "imageUrl": "https://i.namu.wiki/i/sBDtojpRqIiDG0azCYkJeD2XCynDM4WI5tBUyS239Fq-_AGWtB8KqhUHRnfJTs1GmVZy16Wh0YfADAHULowdbA.webp",
    "Lat": 37.5700,
    "Lon": 126.9784
  },
  {
    "name": "청계광장",
    "imageUrl": "https://cdn.visitkorea.or.kr/img/call?cmd=VIEW&id=6ffb70ad-81b8-4de0-8804-91a09ef078f4",
    "Lat": 37.5705,
    "Lon": 126.9788
  },
  {
    "name": "종로 일대",
    "imageUrl": "https://i.namu.wiki/i/fi7yjBT9wUxoXKaqkL6-KL-QFXUa-T8TA1bA0U3i6KLnriaYmHRkO15wFsBJKqdNuEdt35ECMY9QydYhm-269A.webp",
    "Lat": 37.5700,
    "Lon": 126.9850
  },
  {
    "name": "YTN서울타워 (남산타워)",
    "imageUrl": "https://i.namu.wiki/i/qTqoDGvx4eOUW3-vEdhVP9PGpw2xc23x9-e5PoNDBOdYOLo2SaH0V2lbL1CE55oMafeGSfpnGbK159Atp8gY4w.webp",
    "Lat": 37.5512,
    "Lon": 126.9882
  },
  {
    "name": "63빌딩",
    "imageUrl": "https://i.namu.wiki/i/SNQawu1WTChcxWGgesG1QCoW-pcyuCrHkcmeyQGugwc0h_6XlN5rYJkHUbqrLBsMvseveC2hHZotmfPz016-Tw.webp",
    "Lat": 37.5260,
    "Lon": 126.9380
  },
  {
    "name": "롯데월드",
    "imageUrl": "https://i.namu.wiki/i/1x-j9vNlZuyIYUUbvD4t4tSyZl42XCH4c1EoeXXvO3FdxGijUATt_1Uxv697oMU-sr5hgoKUFkCoHnmSSrX-zQ.webp",
    "Lat": 37.5112,
    "Lon": 127.0983
  },
  {
    "name": "롯데월드타워",
    "imageUrl": "https://www.songpa.go.kr/upload/DATA/resrce/abf81ae0-4d26-40a6-9da2-8dfcbff81c7e79D9AGAA178F1GAC.jpg",
    "Lat": 37.5132,
    "Lon": 127.1022
  },
  {
    "name": "롯데월드몰",
    "imageUrl": "https://tnnews.co.kr/wp-content/uploads/2022/12/%EB%A1%AF%EB%8D%B0%EC%9B%94%EB%93%9C%EC%A0%90-1.jpg",
    "Lat": 37.5119,
    "Lon": 127.0987
  },
  {
    "name": "이태원",
    "imageUrl": "https://minio.nculture.org/amsweb-opt/multimedia_assets/165/85860/94088/c/%EC%9D%B4%ED%83%9C%EC%9B%90%EA%B1%B0%EB%A6%AC-%282%29_rev-medium-size.jpg",
    "Lat": 37.5340,
    "Lon": 126.9985
  },
  {
    "name": "강남역 사거리",
    "imageUrl": "https://www.gangnam.go.kr//upload/portal/bbs/2021/05/25/thumb_default_e2454d4d-fd66-4d28-9629-35ed25d0640a.jpg",
    "Lat": 37.4979,
    "Lon": 127.0276
  },
  {
    "name": "대학로",
    "imageUrl": "https://mediahub.seoul.go.kr/uploads/mediahub/2021/02/f3da95acc3494bb4a848615d8f395ba2.jpg",
    "Lat": 37.5826,
    "Lon": 127.0007
  },
  {
    "name": "동대문디자인플라자 (DDP)",
    "imageUrl": "https://www.seoul.go.kr/upload/policy/images/234f4226-0b46-4e7f-a833-32bcb097be41.jpg",
    "Lat": 37.5665,
    "Lon": 127.0095
  },
  {
    "name": "COEX",
    "imageUrl": "https://visitgangnam.net/wp-content/uploads/2022/08/2-%E1%84%8F%E1%85%A9%E1%84%8B%E1%85%A6%E1%86%A8%E1%84%89%E1%85%B3-2-scaled.jpg",
    "Lat": 37.5113,
    "Lon": 127.0583
  },
  {
    "name": "타임스퀘어 (영등포)",
    "imageUrl": "https://mediahub.seoul.go.kr/wp-content/uploads/editor/images/000410/1_1.jpg",
    "Lat": 37.5265,
    "Lon": 126.8958
  },
  {
    "name": "DMC (Digital Media City)",
    "imageUrl": "https://i.namu.wiki/i/Ern_6_5SXLp6RQjy9vJDW8Vlxx0Inpsqn78G3KA0PqJTdM8d2hx8G_EHq9QiRkbCV6b2bWZ0bMXefznN89GGEQ.webp",
    "Lat": 37.5774,
    "Lon": 126.9000
  },
  {
    "name": "한강시민공원",
    "imageUrl": "https://hangang.seoul.go.kr/www/file/down.do?fkey=1818ddb7181d931c0abbf34abc39fe69499176970e6cecf0d8a9b7f7516d3dfb6f50af2d64bbe2469f94bd5359908993d70f06737ea6a3e66445375aeb201b8f",
    "Lat": 37.5200,
    "Lon": 126.9000
  },
  {
    "name": "서울 올림픽공원",
    "imageUrl": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT_MnhWybQ5LdHbLSeIGUR8wJF9MDKQT1XeFA&s",
    "Lat": 37.5200,
    "Lon": 127.1210
  },
  {
    "name": "탑골공원",
    "imageUrl": "https://i.namu.wiki/i/ccy-LzqqlqDrMhNuDBK_iYh_6YMcQdZ5omdaKZLJoXyxnd5ZkH7Xh2L2eHNUACWD1dChRbcT3Mivp2m7eCY6Hg.webp",
    "Lat": 37.5700,
    "Lon": 126.9810
  },
  {
    "name": "월드컵공원",
    "imageUrl": "https://parks.seoul.go.kr/file/info/view.do?fIdx=1888",
    "Lat": 37.5665,
    "Lon": 126.8980
  },
  {
    "name": "어린이대공원",
    "imageUrl": "https://img.hankyung.com/photo/202404/AA.36504525.1.jpg",
    "Lat": 37.5400,
    "Lon": 127.0800
  },
  {
    "name": "선유도 공원",
    "imageUrl": "https://parks.seoul.go.kr/images/egovframework/com/template/seonyudo5.jpg",
    "Lat": 37.5400,
    "Lon": 126.9000
  },
  {
    "name": "뚝섬 서울숲",
    "imageUrl": "https://www.sd.go.kr/site/main/images/contents/cts1463_img1.jpg",
    "Lat": 37.5500,
    "Lon": 127.0400
  },
  {
    "name": "서울로 7017",
    "imageUrl": "https://i.namu.wiki/i/eOVv43UHs3HFPClUXvnv8Iw5DpAN8GX3FTIQLni-ieCsTqlQYc0t0NleDTgdROwuLriKFm4DDOxw85YM5AU4zg.webp",
    "Lat": 37.5600,
    "Lon": 126.9780
  },
  {
    "name": "보라매 공원",
    "imageUrl": "https://parks.seoul.go.kr/images/egovframework/com/template/1-1.boramae.jpg",
    "Lat": 37.4900,
    "Lon": 126.9400
  },
  {
    "name": "북서울 꿈의 숲",
    "imageUrl": "https://parks.seoul.go.kr/images/egovframework/com/template/df08.jpg",
    "Lat": 37.6400,
    "Lon": 127.0300
  },
  {
    "name": "명동성당",
    "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/9/93/Myeongdongchurch2025.jpg",
    "Lat": 37.5645,
    "Lon": 126.9850
  },
  {
    "name": "조계사",
    "imageUrl": "https://www.jogyesa.kr/images/contents/aboutBg.png",
    "Lat": 37.5700,
    "Lon": 126.9810
  },
  {
    "name": "대한성공회 서울주교좌대성당",
    "imageUrl": "https://i.namu.wiki/i/0kU3knjFb01xbwOR8EjqQ6QQEkJ_Ag7_ziTQqId34VCnkDZzRNug8s9jzV8nT71pJt26SUCbvL6CloK3pDA78g.webp",
    "Lat": 37.5700,
    "Lon": 126.9800
  },
  {
    "name": "정동제일교회",
    "imageUrl": "https://i.namu.wiki/i/H9ybOHOsR47IC-KEz0Tr0Z98LfmegQGZJTV56uSL8oOnnLHKSaOIICtGDPS-vDWI4wYc7L1cfTDKX9zG6Wb2vg.webp",
    "Lat": 37.5650,
    "Lon": 126.9780
  },
  {
    "name": "정교회 성 니콜라스 대성당",
    "imageUrl": "https://i.namu.wiki/i/hMADE8nJFJHn_tGA9GLacLcZQXtK9Orrl2KHnvqams760fVok6QGEhTrnt-1vRUFgrFBGQ5i0sgbJs0g5ydTVg.webp",
    "Lat": 37.5700,
    "Lon": 126.9800
  },
  {
    "name": "천도교 중앙대교당",
    "imageUrl": "https://i.namu.wiki/i/kl_yHxFe7dqi41DE5CoQ4jaP_0blJJbhXv21cBCjN7gZqJmqbIeZJBcMey9mLXDk_QBC119E1jDdU7Y_ElHyjA.webp",
    "Lat": 37.5700,
    "Lon": 126.9800
  },
  {
    "name": "봉은사",
    "imageUrl": "https://mediahub.seoul.go.kr/uploads/mediahub/2023/03/yltrtCTsSlpweOMZifABSQOgCGvZjPOW.jpg",
    "Lat": 37.5140,
    "Lon": 127.0630
  },
  {
    "name": "정릉 (신덕왕후 강씨 능)",
    "imageUrl": "https://upload.wikimedia.org/wikipedia/commons/thumb/0/0f/Jeongneung_fullview2.jpg/1200px-Jeongneung_fullview2.jpg",
    "Lat": 37.6100,
    "Lon": 127.0450
  },
  {
    "name": "서촌 지역 일대",
    "imageUrl": "https://korean.visitseoul.net/data/kukudocs/seoul2133/20220519/202205191143567571.jpg",
    "Lat": 37.5770,
    "Lon": 126.9400
  }
];

