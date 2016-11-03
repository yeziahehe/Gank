# Gank API 文档

根据 [@代码家](https://github.com/daimajia) [API 文档](http://gank.io/api)以及本项目 Gank 模块进行整理，感谢他为开源做出的贡献。

# 今日

## #1 历史干货日期

### 接口说明

- 用于历史干货日期查询；
- 用于判断今日是否有干货；

### 请求方式

| 请求方式 | URL |
| :---: | --- |
| `GET` | `http://gank.io/api/day/history` |

### 返回示例

```
{
  error: false,
  results: [
    "2016-11-03",
    "2016-11-02",
    "2016-11-01",
    "2016-10-31",
    "2016-10-28",
    "2016-10-27",
    "2016-10-26"
  ]
}
```

| 返回参数 | 类型 | 描述 |
| :---: | :---:| --- |
| error | Bool | 错误类型：true \| false |
| results | Array[String] | 历史干货日期 |

## #2 某日干货

### 接口说明

- 获取某日干货数据；
- 判断今日是否有干货，可以用来获取最新一日干货；

### 请求方式

| 请求方式 | URL |
| :---: | --- |
| `GET` | `http://gank.io/api/day/{year}/{month}/{day}` |

### 返回示例

```
{
  category: [
    "Android",
    "休息视频",
    "福利",
    "iOS"
  ],
  error: false,
  results: {
    Android: [
      {
        _id: "5816e3e0421aa90e6f21b489",
        createdAt: "2016-10-31T14:25:36.974Z",
        desc: "dex文件结构解析以及其应用",
        publishedAt: "2016-11-03T11:48:43.342Z",
        source: "web",
        type: "Android",
        url: "http://www.zjutkz.net/2016/10/27/dex%E6%96%87%E4%BB%B6%E7%BB%93%E6%9E%84%E5%8F%8A%E5%85%B6%E5%BA%94%E7%94%A8/",
        used: true,
        who: null
      },
      {
        _id: "581aa212421aa91376974619",
        createdAt: "2016-11-03T10:33:54.162Z",
        desc: "Android 方块儿展开菜单，很有新意。",
        images: [
          "http://img.gank.io/c265503d-4cdb-4f1b-8998-008b20e01f9c"
        ],
        publishedAt: "2016-11-03T11:48:43.342Z",
        source: "chrome",
        type: "Android",
        url: "https://github.com/devsideal/SquareMenu",
        used: true,
        who: "代码家"
      }
    ],
    iOS: [
      {
        _id: "581aa2f2421aa9137697461a",
        createdAt: "2016-11-03T10:37:38.607Z",
        desc: "Swift Web Framework",
        images: [
          "http://img.gank.io/6defa0a8-aacd-4606-8a7a-a5bbda15b719"
        ],
        publishedAt: "2016-11-03T11:48:43.342Z",
        source: "chrome",
        type: "iOS",
        url: "https://github.com/vapor/vapor",
        used: true,
        who: "代码家"
      }
    ],
    休息视频: [
      {
        _id: "581967f1421aa9137697460a",
        createdAt: "2016-11-02T12:13:37.604Z",
        desc: "卷福来到上海，我们和他聊了聊",
        publishedAt: "2016-11-03T11:48:43.342Z",
        source: "chrome",
        type: "休息视频",
        url: "http://v.qq.com/x/page/r0342q3inxz.html",
        used: true,
        who: "lxxself"
      }
    ],
    福利: [
      {
        _id: "581a838a421aa90e799ec261",
        createdAt: "2016-11-03T08:23:38.560Z",
        desc: "11-3",
        publishedAt: "2016-11-03T11:48:43.342Z",
        source: "chrome",
        type: "福利",
        url:"http://ww3.sinaimg.cn/large/610dc034jw1f9em0sj3yvj20u00w4acj.jpg",
        used: true,
        who: "daimajia"
      }
    ]
  }
}
```

| 返回参数 | 类型 | 描述 |
| :---: | :---:| --- |
| category | Array[String] | 干货类型：Android \| iOS \| 休息视频 \| 福利 \| 拓展资源 \| 前端 \| 瞎推荐 \| App	|
| error | Bool | 错误类型：true \| false |
| results | JSON Object | 干货详情 |
| _id | String | 干货 id |
| createdAt | String | 干货创建时间 |
| desc | String | 描述 |
| images | String | 配图 url，**可能存在无数据的情况** |
| publishedAt | String | 干货发布时间 |
| source | String | 不详 |
| type | String | 干货类型 |
| url | String | 干货链接 |
| used | Bool | 干货有效类型 |
| who | String | 作者 |
