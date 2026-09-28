// 由 scripts/build_photo_library.py 生成，逐张保留原作者及许可。
export interface LibraryPhoto {
  id: string; name: string; aliases: string[]; methods: string[]; ingredientGroups: string[][];
  file: string; author: string; license: string; licenseUrl: string; sourcePage: string;
}
export const PHOTO_LIBRARY: LibraryPhoto[] = [
  {
    "id": "garlic",
    "name": "蒜香上海青",
    "aliases": [
      "蒜蓉上海青",
      "清炒上海青",
      "蒜炒小青菜"
    ],
    "methods": [
      "清炒",
      "快炒"
    ],
    "ingredientGroups": [
      [
        "上海青",
        "青梗菜",
        "小青菜",
        "油菜",
        "小白菜"
      ],
      [
        "大蒜",
        "蒜",
        "蒜瓣",
        "蒜末"
      ]
    ],
    "file": "library/garlic.jpg",
    "author": "Ralff Nestor Nacor",
    "license": "CC BY-SA 4.0",
    "licenseUrl": "https://creativecommons.org/licenses/by-sa/4.0",
    "sourcePage": "https://commons.wikimedia.org/wiki/File:Stir_Fried_Bok_Choy,_Aug_2025.jpg"
  },
  {
    "id": "tomato-egg",
    "name": "番茄炒蛋",
    "aliases": [
      "西红柿炒鸡蛋",
      "番茄炒鸡蛋"
    ],
    "methods": [
      "快炒",
      "清炒"
    ],
    "ingredientGroups": [
      [
        "番茄",
        "西红柿"
      ],
      [
        "鸡蛋"
      ]
    ],
    "file": "library/tomato-egg.jpg",
    "author": "Ggsldwt",
    "license": "CC BY-SA 3.0",
    "licenseUrl": "https://creativecommons.org/licenses/by-sa/3.0",
    "sourcePage": "https://commons.wikimedia.org/wiki/File:TOMATOANDEGG_GGSLDWT.jpg"
  },
  {
    "id": "tomato-noodles",
    "name": "番茄鸡蛋面",
    "aliases": [
      "西红柿鸡蛋面",
      "番茄鸡蛋汤面"
    ],
    "methods": [
      "汤面"
    ],
    "ingredientGroups": [
      [
        "番茄",
        "西红柿"
      ],
      [
        "鸡蛋"
      ],
      [
        "面条",
        "挂面",
        "鲜面条",
        "手擀面",
        "宽面"
      ]
    ],
    "file": "library/tomato-noodles.jpg",
    "author": "Fumikas Sagisavas",
    "license": "CC0",
    "licenseUrl": "https://creativecommons.org/publicdomain/zero/1.0/deed.en",
    "sourcePage": "https://commons.wikimedia.org/wiki/File:Tomato_scrambled_eggs_noodles.jpg"
  },
  {
    "id": "potato-pan",
    "name": "香煎土豆块",
    "aliases": [
      "煎土豆",
      "煎土豆块"
    ],
    "methods": [
      "香煎"
    ],
    "ingredientGroups": [
      [
        "土豆",
        "马铃薯"
      ]
    ],
    "file": "library/potato-pan.jpg",
    "author": "Infrogmation of New Orleans",
    "license": "CC BY-SA 2.0",
    "licenseUrl": "https://creativecommons.org/licenses/by-sa/2.0",
    "sourcePage": "https://commons.wikimedia.org/wiki/File:Home_fries_in_pan_on_range,_New_Orleans_September_2024.jpg"
  },
  {
    "id": "egg-scallion",
    "name": "葱花炒蛋",
    "aliases": [
      "小葱炒鸡蛋",
      "葱花炒鸡蛋"
    ],
    "methods": [
      "快炒",
      "清炒"
    ],
    "ingredientGroups": [
      [
        "鸡蛋"
      ],
      [
        "小葱",
        "香葱",
        "葱花",
        "葱"
      ]
    ],
    "file": "library/egg-scallion.jpg",
    "author": "Daderot",
    "license": "CC0",
    "licenseUrl": "https://creativecommons.org/publicdomain/zero/1.0/deed.en",
    "sourcePage": "https://commons.wikimedia.org/wiki/File:Egg_and_scallion_-_Arlington,_MA.jpg"
  },
  {
    "id": "mapo",
    "name": "麻婆豆腐",
    "aliases": [],
    "methods": [
      "焖烧"
    ],
    "ingredientGroups": [
      [
        "豆腐",
        "嫩豆腐",
        "北豆腐",
        "南豆腐"
      ],
      [
        "肉末",
        "猪肉末",
        "牛肉末",
        "猪肉馅",
        "牛肉馅"
      ]
    ],
    "file": "library/mapo.jpg",
    "author": "Sichuanfoodlover",
    "license": "CC BY-SA 4.0",
    "licenseUrl": "https://creativecommons.org/licenses/by-sa/4.0",
    "sourcePage": "https://commons.wikimedia.org/wiki/File:Authentic_Mapo_Tofu.jpg"
  },
  {
    "id": "eggplant",
    "name": "鱼香茄子",
    "aliases": [
      "鱼香肉末茄子"
    ],
    "methods": [
      "焖烧",
      "快炒"
    ],
    "ingredientGroups": [
      [
        "茄子",
        "长茄子",
        "紫茄子"
      ]
    ],
    "file": "library/eggplant.jpg",
    "author": "Popo le Chien",
    "license": "CC0",
    "licenseUrl": "https://creativecommons.org/publicdomain/zero/1.0/deed.en",
    "sourcePage": "https://commons.wikimedia.org/wiki/File:Qiezi.jpg"
  },
  {
    "id": "disanxian",
    "name": "地三鲜",
    "aliases": [],
    "methods": [
      "快炒",
      "焖烧"
    ],
    "ingredientGroups": [
      [
        "茄子",
        "长茄子"
      ],
      [
        "土豆",
        "马铃薯"
      ],
      [
        "青椒",
        "甜椒"
      ]
    ],
    "file": "library/disanxian.jpg",
    "author": "1700-talet",
    "license": "CC BY 3.0",
    "licenseUrl": "https://creativecommons.org/licenses/by/3.0",
    "sourcePage": "https://commons.wikimedia.org/wiki/File:Di_san_xian_(home-made).jpg"
  },
  {
    "id": "cucumber",
    "name": "拍黄瓜",
    "aliases": [
      "蒜泥拍黄瓜",
      "凉拌拍黄瓜"
    ],
    "methods": [
      "凉拌"
    ],
    "ingredientGroups": [
      [
        "黄瓜"
      ]
    ],
    "file": "library/cucumber.jpg",
    "author": "N509FZ",
    "license": "CC BY-SA 4.0",
    "licenseUrl": "https://creativecommons.org/licenses/by-sa/4.0",
    "sourcePage": "https://commons.wikimedia.org/wiki/File:Smashed_cucumbers_(20220219174336).jpg"
  },
  {
    "id": "beef-broccoli",
    "name": "西兰花炒牛肉",
    "aliases": [
      "西兰花牛肉",
      "牛肉炒西兰花"
    ],
    "methods": [
      "快炒",
      "清炒"
    ],
    "ingredientGroups": [
      [
        "西兰花"
      ],
      [
        "牛肉",
        "牛里脊",
        "牛肉片"
      ]
    ],
    "file": "library/beef-broccoli.jpg",
    "author": "Laurel F",
    "license": "CC BY-SA 2.0",
    "licenseUrl": "https://creativecommons.org/licenses/by-sa/2.0",
    "sourcePage": "https://commons.wikimedia.org/wiki/File:Beef_and_Broccoli.jpg"
  },
  {
    "id": "cabbage-bacon",
    "name": "培根炒包菜",
    "aliases": [
      "培根包菜",
      "包菜炒培根"
    ],
    "methods": [
      "快炒",
      "清炒"
    ],
    "ingredientGroups": [
      [
        "包菜",
        "卷心菜",
        "圆白菜",
        "高丽菜"
      ],
      [
        "培根"
      ]
    ],
    "file": "library/cabbage-bacon.jpg",
    "author": "Christopher",
    "license": "CC BY 2.0",
    "licenseUrl": "https://creativecommons.org/licenses/by/2.0",
    "sourcePage": "https://commons.wikimedia.org/wiki/File:Stir_Fried_Cabbage_and_Bacon_%E5%9F%B9%E6%A0%B9%E9%AB%98%E4%B8%BD%E8%8F%9C.jpg"
  },
  {
    "id": "beans",
    "name": "肉末干煸四季豆",
    "aliases": [
      "干煸四季豆"
    ],
    "methods": [
      "快炒"
    ],
    "ingredientGroups": [
      [
        "四季豆",
        "菜豆"
      ],
      [
        "猪肉末",
        "猪肉馅",
        "肉末"
      ]
    ],
    "file": "library/beans.jpg",
    "author": "Andy Li",
    "license": "CC0",
    "licenseUrl": "https://creativecommons.org/publicdomain/zero/1.0/deed.en",
    "sourcePage": "https://commons.wikimedia.org/wiki/File:Sichuan-style-dried_fried_Green_Beans_with_Minced_Pork_-_Aberdeen_Seafood,_Brighton_2026-07-19.jpg"
  },
  {
    "id": "kungpao",
    "name": "宫保鸡丁",
    "aliases": [],
    "methods": [
      "快炒"
    ],
    "ingredientGroups": [
      [
        "鸡肉",
        "鸡胸肉",
        "鸡腿肉",
        "鸡丁"
      ],
      [
        "花生",
        "花生米",
        "熟花生米"
      ]
    ],
    "file": "library/kungpao.jpg",
    "author": "N509FZ",
    "license": "CC BY-SA 4.0",
    "licenseUrl": "https://creativecommons.org/licenses/by-sa/4.0",
    "sourcePage": "https://commons.wikimedia.org/wiki/File:Kung_Pao_Chicken_at_Yujiayan_Restaurant_(20230510123120).jpg"
  },
  {
    "id": "pork",
    "name": "红烧肉",
    "aliases": [
      "家常红烧肉"
    ],
    "methods": [
      "焖烧"
    ],
    "ingredientGroups": [
      [
        "五花肉",
        "猪五花肉"
      ]
    ],
    "file": "library/pork.jpg",
    "author": "lazy fri13th",
    "license": "CC BY 2.0",
    "licenseUrl": "https://creativecommons.org/licenses/by/2.0",
    "sourcePage": "https://commons.wikimedia.org/wiki/File:Red_braised_pork_belly.jpg"
  },
  {
    "id": "ribs",
    "name": "糖醋排骨",
    "aliases": [
      "糖醋小排"
    ],
    "methods": [
      "焖烧"
    ],
    "ingredientGroups": [
      [
        "排骨",
        "猪排骨",
        "猪小排",
        "小排"
      ]
    ],
    "file": "library/ribs.jpg",
    "author": "Lim Ashley",
    "license": "CC BY 2.0",
    "licenseUrl": "https://creativecommons.org/licenses/by/2.0",
    "sourcePage": "https://commons.wikimedia.org/wiki/File:T%C3%A1ngc%C3%B9_p%C3%A1ig%C7%94.jpg"
  },
  {
    "id": "fish-head",
    "name": "剁椒鱼头",
    "aliases": [],
    "methods": [
      "清蒸"
    ],
    "ingredientGroups": [
      [
        "鱼头",
        "鲢鱼头",
        "胖头鱼头",
        "花鲢鱼头"
      ],
      [
        "剁椒",
        "红剁椒"
      ]
    ],
    "file": "library/fish-head.jpg",
    "author": "Huangdan2060",
    "license": "CC BY 3.0",
    "licenseUrl": "https://creativecommons.org/licenses/by/3.0",
    "sourcePage": "https://commons.wikimedia.org/wiki/File:Steamed_Fish_Head_with_Diced_Hot_Red_Peppers_20210711.jpg"
  },
  {
    "id": "shrimp",
    "name": "龙井虾仁",
    "aliases": [],
    "methods": [
      "快炒",
      "清炒"
    ],
    "ingredientGroups": [
      [
        "虾仁",
        "鲜虾仁"
      ],
      [
        "龙井茶",
        "龙井茶叶",
        "茶叶"
      ]
    ],
    "file": "library/shrimp.jpg",
    "author": "Zheng Zhou",
    "license": "CC BY-SA 4.0",
    "licenseUrl": "https://creativecommons.org/licenses/by-sa/4.0",
    "sourcePage": "https://commons.wikimedia.org/wiki/File:Shrimp_Stir-fried_with_Dragon_Well_Tea.jpg"
  },
  {
    "id": "rice",
    "name": "蛋炒饭",
    "aliases": [
      "鸡蛋炒饭",
      "家常蛋炒饭"
    ],
    "methods": [
      "快炒"
    ],
    "ingredientGroups": [
      [
        "鸡蛋"
      ],
      [
        "米饭",
        "剩米饭",
        "隔夜米饭",
        "熟米饭"
      ]
    ],
    "file": "library/rice.jpg",
    "author": "Gaurav Dhwaj Khadka",
    "license": "CC BY-SA 4.0",
    "licenseUrl": "https://creativecommons.org/licenses/by-sa/4.0",
    "sourcePage": "https://commons.wikimedia.org/wiki/File:Egg_Fried_Rice.jpg"
  },
  {
    "id": "noodles",
    "name": "葱油拌面",
    "aliases": [],
    "methods": [
      "汤面",
      "凉拌",
      "快炒"
    ],
    "ingredientGroups": [
      [
        "面条",
        "挂面",
        "鲜面条",
        "手擀面"
      ],
      [
        "小葱",
        "香葱",
        "葱"
      ]
    ],
    "file": "library/noodles.jpg",
    "author": "HanWei's EXP from (optional)",
    "license": "CC BY-SA 2.0",
    "licenseUrl": "https://creativecommons.org/licenses/by-sa/2.0",
    "sourcePage": "https://commons.wikimedia.org/wiki/File:Shanghai_oil_noodle.jpg"
  },
  {
    "id": "lotus",
    "name": "莲藕排骨汤",
    "aliases": [
      "排骨莲藕汤",
      "藕炖排骨"
    ],
    "methods": [
      "煮汤",
      "焖烧"
    ],
    "ingredientGroups": [
      [
        "莲藕",
        "藕"
      ],
      [
        "排骨",
        "猪排骨",
        "猪小排"
      ]
    ],
    "file": "library/lotus.jpg",
    "author": "Zheng Zhou",
    "license": "CC BY-SA 4.0",
    "licenseUrl": "https://creativecommons.org/licenses/by-sa/4.0",
    "sourcePage": "https://commons.wikimedia.org/wiki/File:Lotus_Root_Soup.jpg"
  },
  {
    "id": "mushroom-fry",
    "name": "洋葱炒平菇",
    "aliases": [
      "平菇炒洋葱"
    ],
    "methods": [
      "快炒",
      "清炒"
    ],
    "ingredientGroups": [
      [
        "平菇",
        "秀珍菇"
      ],
      [
        "洋葱"
      ]
    ],
    "file": "library/mushroom-fry.jpg",
    "author": "Hyeon-Jeong Suk",
    "license": "CC BY 2.0",
    "licenseUrl": "https://creativecommons.org/licenses/by/2.0",
    "sourcePage": "https://commons.wikimedia.org/wiki/File:Neutaribokkeum_(stir-fried_oyster_mushrooms).jpg"
  },
  {
    "id": "spinach-pork",
    "name": "肉末炒菠菜",
    "aliases": [
      "肉末菠菜",
      "菠菜炒肉末"
    ],
    "methods": [
      "快炒",
      "清炒"
    ],
    "ingredientGroups": [
      [
        "菠菜"
      ],
      [
        "猪肉末",
        "猪肉馅",
        "肉末"
      ]
    ],
    "file": "library/spinach-pork.jpg",
    "author": "NeoBatfreak",
    "license": "CC BY-SA 4.0",
    "licenseUrl": "https://creativecommons.org/licenses/by-sa/4.0",
    "sourcePage": "https://commons.wikimedia.org/wiki/File:Stir-fried_spinach_and_ground_pork(1).jpg"
  },
  {
    "id": "chicken",
    "name": "豉油鸡",
    "aliases": [
      "酱油鸡"
    ],
    "methods": [
      "焖烧"
    ],
    "ingredientGroups": [
      [
        "鸡",
        "整鸡",
        "三黄鸡",
        "鸡腿",
        "鸡肉"
      ]
    ],
    "file": "library/chicken.jpg",
    "author": "Dennis Wong from Hong Kong, Hong Kong",
    "license": "CC BY 2.0",
    "licenseUrl": "https://creativecommons.org/licenses/by/2.0",
    "sourcePage": "https://commons.wikimedia.org/wiki/File:Soy_Sauce_Chicken.jpg"
  },
  {
    "id": "cauliflower",
    "name": "清炒花菜",
    "aliases": [
      "清炒菜花",
      "素炒花菜"
    ],
    "methods": [
      "快炒",
      "清炒"
    ],
    "ingredientGroups": [
      [
        "花菜",
        "菜花",
        "花椰菜"
      ]
    ],
    "file": "library/cauliflower.jpg",
    "author": "Tbatb",
    "license": "CC BY-SA 4.0",
    "licenseUrl": "https://creativecommons.org/licenses/by-sa/4.0",
    "sourcePage": "https://commons.wikimedia.org/wiki/File:Stir-fried_Cauliflower.jpg"
  },
  {
    "id": "eggplain",
    "name": "三色蒸蛋",
    "aliases": [
      "蒸三色蛋",
      "三色水蛋"
    ],
    "methods": [
      "清蒸"
    ],
    "ingredientGroups": [
      [
        "鸡蛋"
      ],
      [
        "皮蛋",
        "松花蛋"
      ],
      [
        "咸鸭蛋",
        "咸蛋"
      ]
    ],
    "file": "library/eggplain.jpg",
    "author": "Tam3415 from (optional)",
    "license": "CC BY-SA 2.0",
    "licenseUrl": "https://creativecommons.org/licenses/by-sa/2.0",
    "sourcePage": "https://commons.wikimedia.org/wiki/File:ChineseSteamedEgg.jpg"
  },
  {
    "id": "water-spinach",
    "name": "蒜蓉空心菜",
    "aliases": [
      "蒜香空心菜",
      "清炒空心菜"
    ],
    "methods": [
      "快炒",
      "清炒"
    ],
    "ingredientGroups": [
      [
        "空心菜"
      ],
      [
        "蒜",
        "大蒜",
        "蒜末",
        "蒜瓣"
      ]
    ],
    "file": "library/water-spinach.jpg",
    "author": "NeoBatfreak",
    "license": "CC BY-SA 4.0",
    "licenseUrl": "https://creativecommons.org/licenses/by-sa/4.0",
    "sourcePage": "https://commons.wikimedia.org/wiki/File:Stir-fried_Water_Convolvulus_(%E7%82%92%E7%A9%BA%E5%BF%83%E8%8F%9C).jpg"
  },
  {
    "id": "twice-pork",
    "name": "回锅肉",
    "aliases": [
      "家常回锅肉"
    ],
    "methods": [
      "快炒"
    ],
    "ingredientGroups": [
      [
        "五花肉",
        "猪五花肉",
        "猪肉"
      ]
    ],
    "file": "library/twice-pork.jpg",
    "author": "pelican from Tokyo, Japan",
    "license": "CC BY-SA 2.0",
    "licenseUrl": "https://creativecommons.org/licenses/by-sa/2.0",
    "sourcePage": "https://commons.wikimedia.org/wiki/File:H%C3%BAi_g%C5%ABo_r%C3%B2u_(3958649396).jpg"
  },
  {
    "id": "shredded-pork",
    "name": "鱼香肉丝",
    "aliases": [],
    "methods": [
      "快炒"
    ],
    "ingredientGroups": [
      [
        "猪肉",
        "猪里脊",
        "里脊肉",
        "猪里脊肉",
        "瘦猪肉"
      ],
      [
        "木耳",
        "黑木耳",
        "干木耳"
      ]
    ],
    "file": "library/shredded-pork.jpg",
    "author": "Дмитрий Журавлев (dejur)",
    "license": "CC BY-SA 3.0",
    "licenseUrl": "https://creativecommons.org/licenses/by-sa/3.0",
    "sourcePage": "https://commons.wikimedia.org/wiki/File:%E9%B1%BC%E9%A6%99%E8%82%89%E4%B8%9D.jpg"
  },
  {
    "id": "sweet-pork",
    "name": "咕噜肉",
    "aliases": [
      "古老肉",
      "菠萝咕噜肉",
      "糖醋咕噜肉"
    ],
    "methods": [
      "快炒",
      "焖烧"
    ],
    "ingredientGroups": [
      [
        "猪肉",
        "猪里脊",
        "里脊肉",
        "猪里脊肉"
      ],
      [
        "菠萝",
        "凤梨"
      ]
    ],
    "file": "library/sweet-pork.jpg",
    "author": "BorgQueen",
    "license": "CC BY-SA 4.0",
    "licenseUrl": "https://creativecommons.org/licenses/by-sa/4.0",
    "sourcePage": "https://commons.wikimedia.org/wiki/File:Sweet_sour_pork.jpg"
  },
  {
    "id": "cabbage-tofu",
    "name": "白菜豆腐汤",
    "aliases": [
      "白菜炖豆腐"
    ],
    "methods": [
      "煮汤",
      "焖烧"
    ],
    "ingredientGroups": [
      [
        "白菜",
        "大白菜",
        "娃娃菜"
      ],
      [
        "豆腐",
        "嫩豆腐",
        "北豆腐",
        "南豆腐"
      ]
    ],
    "file": "library/cabbage-tofu.jpg",
    "author": "NeoBatfreak",
    "license": "CC BY-SA 4.0",
    "licenseUrl": "https://creativecommons.org/licenses/by-sa/4.0",
    "sourcePage": "https://commons.wikimedia.org/wiki/File:Napa_Cabbage_%26_Tofu_soup_(%E7%99%BD%E8%8F%9C%E8%B1%86%E8%85%90%E6%B9%AF).jpg"
  }
];
