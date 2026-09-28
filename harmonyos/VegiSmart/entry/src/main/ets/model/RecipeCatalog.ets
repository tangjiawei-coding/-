// 由 scripts/sync-recipe-catalog.cjs 同步固定示例；AI 结果通过 KitchenService 动态追加。
export interface IngredientInfo { name: string; category: string; description: string; preparation: string; }
export interface RecipeItem { name: string; amount: string; group: string; }
export interface RecipeStep { title: string; description: string; }
export interface PhotoCredit { name: string; author: string; license: string; licenseUrl: string; sourcePage: string; }
export interface Recipe {
  id: string; name: string; subtitle: string; pairing: string; image: string; time: string; method: string;
  ingredientInfos?: IngredientInfo[]; photoCredit?: PhotoCredit;
  items: RecipeItem[]; steps: RecipeStep[]; story: string; source: string; sourceName: string;
}
export interface FoodExample {
  id: string; name: string; aliases: string[]; subtitle: string; summary: string; image: string;
  recipeIds: string[]; storage: string; pairing: string; description: string; preparation: string;
}

export const INGREDIENTS: IngredientInfo[] = [
  {
    "name": "上海青",
    "category": "绿叶蔬菜 · 又称青梗菜",
    "description": "菜梗清脆，叶片柔嫩，梗与叶都可以食用。",
    "preparation": "掰开叶片冲洗，尤其洗净叶柄根部；沥水后将较大的菜梗与叶片分开。"
  },
  {
    "name": "大蒜",
    "category": "葱蒜类 · 辅料",
    "description": "提供鲜明蒜香。",
    "preparation": "剥皮切末，炒香时避免炒焦。"
  },
  {
    "name": "食用油",
    "category": "油脂 · 调料",
    "description": "帮助传热，让食材受热均匀。",
    "preparation": "使用日常炒菜油即可。"
  },
  {
    "name": "盐",
    "category": "调味品",
    "description": "用于调节咸味。",
    "preparation": "先少放，出锅前尝味调整。"
  },
  {
    "name": "干香菇",
    "category": "菌菇 · 主料",
    "description": "泡发后香气浓郁，口感厚实。",
    "preparation": "泡软后洗净去硬蒂；泡发水过滤后可入菜。"
  },
  {
    "name": "生抽",
    "category": "酿造酱油 · 调料",
    "description": "为汤汁增加咸鲜味。",
    "preparation": "本身含盐，搭配盐时适当减少用量。"
  },
  {
    "name": "蚝油",
    "category": "复合调味品",
    "description": "让汤汁更浓郁。",
    "preparation": "含蚝类成分，忌食者可选择相应的素食调味汁。"
  },
  {
    "name": "淀粉",
    "category": "增稠辅料",
    "description": "让薄芡附着在菜上。",
    "preparation": "先与凉水调匀，再少量倒入热汤汁。"
  },
  {
    "name": "水",
    "category": "烹饪用水",
    "description": "用于煮汤、焖煮或调开淀粉。",
    "preparation": "使用饮用水。"
  },
  {
    "name": "豆腐",
    "category": "豆制品 · 主料",
    "description": "口感柔软，适合与青菜一起煮汤。",
    "preparation": "沥水后切块，入锅后轻推，避免搅碎。"
  },
  {
    "name": "姜",
    "category": "根茎类 · 辅料",
    "description": "为汤底增加清香。",
    "preparation": "洗净切细丝。"
  },
  {
    "name": "香油",
    "category": "芝麻油 · 调料",
    "description": "少量即可增加芝麻香气。",
    "preparation": "临出锅时加入。"
  },
  {
    "name": "番茄",
    "category": "茄果类 · 又称西红柿",
    "description": "汁水丰富，酸甜柔和，加热后容易形成汤汁。",
    "preparation": "洗净去蒂，切成大小均匀的块；是否去皮按口感喜好决定。"
  },
  {
    "name": "土豆",
    "category": "薯类 · 又称马铃薯",
    "description": "切丝可以炒出脆口感，切块焖煮则更绵软。",
    "preparation": "洗净去皮后切块或切丝。明显发绿、发芽或腐烂的土豆不要用于这些菜谱。"
  },
  {
    "name": "鸡蛋",
    "category": "蛋类 · 主料",
    "description": "打散可炒、蒸或淋入汤中，适合多种家常做法。",
    "preparation": "打入单独的小碗检查后再使用；这些示例均需将蛋液充分做熟。"
  },
  {
    "name": "小葱",
    "category": "葱蒜类 · 辅料",
    "description": "葱白用于增香，葱绿可在临出锅时加入。",
    "preparation": "洗净去根，切成葱花。"
  },
  {
    "name": "白糖",
    "category": "调味品",
    "description": "少量用于平衡菜肴的酸味。",
    "preparation": "按番茄本身的酸甜程度调整，也可省略。"
  },
  {
    "name": "面条",
    "category": "谷物制品 · 主食",
    "description": "吸附汤汁，适合与蔬菜和鸡蛋一起煮。",
    "preparation": "按包装说明煮熟；粗细不同，所需时间也不同。"
  },
  {
    "name": "米醋",
    "category": "调味品",
    "description": "带来清爽的酸味。",
    "preparation": "分少量加入，再按口味调整。"
  },
  {
    "name": "青椒",
    "category": "茄果类 · 配菜",
    "description": "切丝炒制口感清脆，增加蔬菜香气。",
    "preparation": "洗净去蒂和籽，切丝。"
  },
  {
    "name": "黑胡椒",
    "category": "香辛料",
    "description": "带来温和的辛香。",
    "preparation": "临出锅少量加入。"
  },
  {
    "name": "胡萝卜",
    "category": "根菜类 · 配菜",
    "description": "熟后口感柔软，带有自然甜味。",
    "preparation": "洗净，切成小丁以便与米饭一起熟透。"
  },
  {
    "name": "大米",
    "category": "谷物 · 主食",
    "description": "蒸煮后作为餐桌主食，也可加入蔬菜焖饭。",
    "preparation": "淘洗后沥水，按电饭煲刻度加入相应用量的水。"
  },
  {
    "name": "鲜香菇",
    "category": "菌菇 · 配菜",
    "description": "带有菇香，切碎后适合加入蒸蛋。",
    "preparation": "洗净去硬蒂，切小丁并充分做熟。"
  },
  {
    "name": "紫菜",
    "category": "藻类 · 配菜",
    "description": "遇水舒展，适合与蛋花一起煮汤。",
    "preparation": "按包装说明处理，留意去除杂质。"
  }
];

export const RECIPES: Recipe[] = [
  {
    "id": "garlic",
    "name": "蒜香上海青",
    "subtitle": "一口清脆，是最简单的家常滋味。",
    "pairing": "上海青 × 大蒜",
    "image": "library/garlic.jpg",
    "time": "约 15 分钟",
    "method": "清炒",
    "items": [
      {
        "name": "上海青",
        "amount": "350 克",
        "group": "主料"
      },
      {
        "name": "大蒜",
        "amount": "3 瓣",
        "group": "辅料"
      },
      {
        "name": "食用油",
        "amount": "15 毫升",
        "group": "调料"
      },
      {
        "name": "盐",
        "amount": "约 2 克",
        "group": "调料"
      }
    ],
    "steps": [
      {
        "title": "洗净、沥水",
        "description": "上海青逐片洗净，大棵切成均匀的小块；大蒜切末。"
      },
      {
        "title": "炒出蒜香",
        "description": "锅中放油，中火下蒜末，闻到香味后立即放入菜梗。"
      },
      {
        "title": "炒熟青菜",
        "description": "翻炒菜梗约 1 分钟，再下菜叶翻炒至断生、菜梗熟透。"
      },
      {
        "title": "调味装盘",
        "description": "加入盐拌匀，尝味后调整，趁热装盘。"
      }
    ],
    "story": "这道菜的吸引力来自简单的蒜香与青菜口感。参考作者把它作为日常餐桌上的蔬菜配菜；这里呈现的是简化的两人份家常版本。",
    "source": "https://thewoksoflife.com/garlic-baby-bok-choy/",
    "sourceName": "The Woks of Life · 蒜炒小青菜",
    "photoCredit": {
      "name": "蒜香上海青",
      "author": "Ralff Nestor Nacor",
      "license": "CC BY-SA 4.0",
      "licenseUrl": "https://creativecommons.org/licenses/by-sa/4.0",
      "sourcePage": "https://commons.wikimedia.org/wiki/File:Stir_Fried_Bok_Choy,_Aug_2025.jpg"
    }
  },
  {
    "id": "mushroom",
    "name": "香菇上海青",
    "subtitle": "浓郁菇香，配上青菜的清甜。",
    "pairing": "上海青 × 干香菇",
    "image": "recipe-placeholder.svg",
    "time": "约 25 分钟 · 另需泡发",
    "method": "焖烧",
    "items": [
      {
        "name": "上海青",
        "amount": "300 克",
        "group": "主料"
      },
      {
        "name": "干香菇",
        "amount": "20 克",
        "group": "主料"
      },
      {
        "name": "大蒜",
        "amount": "2 瓣",
        "group": "辅料"
      },
      {
        "name": "食用油",
        "amount": "10 毫升",
        "group": "调料"
      },
      {
        "name": "生抽",
        "amount": "10 毫升",
        "group": "调料"
      },
      {
        "name": "蚝油",
        "amount": "5 毫升",
        "group": "调料"
      },
      {
        "name": "淀粉",
        "amount": "3 克",
        "group": "调料"
      },
      {
        "name": "水",
        "amount": "150 毫升，另备焯菜用水",
        "group": "辅料"
      }
    ],
    "steps": [
      {
        "title": "备好食材",
        "description": "香菇提前泡软，洗净去硬蒂；上海青洗净对半切，蒜切末。"
      },
      {
        "title": "焯熟青菜",
        "description": "烧一锅水，放入上海青，煮至菜梗熟透后捞出沥水摆盘。"
      },
      {
        "title": "焖香菇",
        "description": "锅中放油炒香蒜末，加入香菇、生抽、蚝油和 130 毫升水，小火焖约 10 分钟至香菇熟软。"
      },
      {
        "title": "收汁装盘",
        "description": "淀粉与剩余 20 毫升凉水调匀，缓缓倒入锅中搅拌，煮至薄芡形成，连同香菇浇在青菜上。"
      }
    ],
    "story": "香菇与青菜的组合也见于上海家常菜。参考作者介绍了上海家庭年节餐桌上的香菇菜心；此处保留这组搭配，简化调味用于日常做饭。",
    "source": "https://thewoksoflife.com/braised-chinese-mushrooms-bok-choy/",
    "sourceName": "The Woks of Life · 香菇菜心"
  },
  {
    "id": "tofu",
    "name": "青菜豆腐汤",
    "subtitle": "柔软豆腐与青菜，煮一碗清淡热汤。",
    "pairing": "上海青 × 豆腐",
    "image": "recipe-placeholder.svg",
    "time": "约 15 分钟",
    "method": "煮汤",
    "items": [
      {
        "name": "上海青",
        "amount": "200 克",
        "group": "主料"
      },
      {
        "name": "豆腐",
        "amount": "250 克",
        "group": "主料"
      },
      {
        "name": "姜",
        "amount": "2 片",
        "group": "辅料"
      },
      {
        "name": "水",
        "amount": "800 毫升",
        "group": "辅料"
      },
      {
        "name": "盐",
        "amount": "约 2 克",
        "group": "调料"
      },
      {
        "name": "香油",
        "amount": "2 毫升",
        "group": "调料"
      }
    ],
    "steps": [
      {
        "title": "切好食材",
        "description": "上海青洗净，较大的切段；豆腐切块，姜切丝。"
      },
      {
        "title": "煮豆腐",
        "description": "锅中加入水和姜丝，煮开后放入豆腐，保持小火煮约 5 分钟。"
      },
      {
        "title": "放入青菜",
        "description": "加入菜梗，稍煮后加入菜叶，继续煮至菜梗熟透。"
      },
      {
        "title": "调味盛出",
        "description": "加盐调味，滴入香油，轻轻推动拌匀后盛出。"
      }
    ],
    "story": "青菜和豆腐可以用很少的调味组成一碗日常汤。参考做法用姜丝和香油增加香气。没有查到足以确认其起源的材料，因此不附会历史传说。",
    "source": "https://www.chinasichuanfood.com/tofu-soup/",
    "sourceName": "China Sichuan Food · 青菜豆腐汤"
  },
  {
    "id": "tomato-egg",
    "name": "番茄炒蛋",
    "subtitle": "酸甜的番茄汁，裹住柔软鸡蛋。",
    "pairing": "番茄 × 鸡蛋",
    "image": "library/tomato-egg.jpg",
    "time": "约 15 分钟",
    "method": "快炒",
    "items": [
      {
        "name": "番茄",
        "amount": "2 个，约 350 克",
        "group": "主料"
      },
      {
        "name": "鸡蛋",
        "amount": "3 个",
        "group": "主料"
      },
      {
        "name": "小葱",
        "amount": "1 根",
        "group": "辅料"
      },
      {
        "name": "食用油",
        "amount": "15 毫升",
        "group": "调料"
      },
      {
        "name": "盐",
        "amount": "约 2 克",
        "group": "调料"
      },
      {
        "name": "白糖",
        "amount": "少许，可不放",
        "group": "调料"
      }
    ],
    "steps": [
      {
        "title": "备好食材",
        "description": "番茄洗净切块，鸡蛋打散，小葱切成葱花。"
      },
      {
        "title": "先炒鸡蛋",
        "description": "锅中放一半油，倒入蛋液，中火推炒至凝固后盛出。"
      },
      {
        "title": "炒出番茄汁",
        "description": "补入余油，下葱白和番茄翻炒，转中火焖约 3 分钟至出汁。"
      },
      {
        "title": "合炒调味",
        "description": "倒回鸡蛋，加入盐和少许糖，翻炒至蛋液完全凝固，撒葱花装盘。"
      }
    ],
    "story": "这道家常菜适合用来熟悉先炒蛋、再炒菜的顺序。番茄炒得久一些，汤汁更浓；保留一些完整果肉，则更有层次。",
    "source": "",
    "sourceName": "家常做法示例",
    "photoCredit": {
      "name": "番茄炒蛋",
      "author": "Ggsldwt",
      "license": "CC BY-SA 3.0",
      "licenseUrl": "https://creativecommons.org/licenses/by-sa/3.0",
      "sourcePage": "https://commons.wikimedia.org/wiki/File:TOMATOANDEGG_GGSLDWT.jpg"
    }
  },
  {
    "id": "tomato-tofu",
    "name": "番茄豆腐汤",
    "subtitle": "一碗带着微酸的暖汤，清爽又家常。",
    "pairing": "番茄 × 豆腐",
    "image": "tomato-tofu.svg",
    "time": "约 20 分钟",
    "method": "煮汤",
    "items": [
      {
        "name": "番茄",
        "amount": "2 个，约 300 克",
        "group": "主料"
      },
      {
        "name": "豆腐",
        "amount": "250 克",
        "group": "主料"
      },
      {
        "name": "小葱",
        "amount": "1 根",
        "group": "辅料"
      },
      {
        "name": "水",
        "amount": "700 毫升",
        "group": "辅料"
      },
      {
        "name": "食用油",
        "amount": "10 毫升",
        "group": "调料"
      },
      {
        "name": "盐",
        "amount": "约 2 克",
        "group": "调料"
      }
    ],
    "steps": [
      {
        "title": "切成小块",
        "description": "番茄洗净切块，豆腐切成约 2 厘米的小块，小葱切碎。"
      },
      {
        "title": "炒软番茄",
        "description": "锅中放油，炒香葱白，再下番茄翻炒至软、汁水渗出。"
      },
      {
        "title": "加入豆腐",
        "description": "倒入水煮开，轻轻加入豆腐，转小火煮约 8 分钟。"
      },
      {
        "title": "调味盛出",
        "description": "加盐调味，轻推拌匀，撒入葱绿后盛出。"
      }
    ],
    "story": "先炒番茄再加水，可以让汤底的番茄味更明显。豆腐下锅后轻轻推动，能保留完整的小块。",
    "source": "",
    "sourceName": "家常做法示例"
  },
  {
    "id": "tomato-noodles",
    "name": "番茄鸡蛋面",
    "subtitle": "让一碗热汤，把主食也一起照顾好。",
    "pairing": "番茄 × 鸡蛋 × 面条",
    "image": "library/tomato-noodles.jpg",
    "time": "约 20 分钟",
    "method": "汤面",
    "items": [
      {
        "name": "番茄",
        "amount": "2 个，约 300 克",
        "group": "主料"
      },
      {
        "name": "鸡蛋",
        "amount": "2 个",
        "group": "主料"
      },
      {
        "name": "面条",
        "amount": "180 克",
        "group": "主料"
      },
      {
        "name": "水",
        "amount": "1000 毫升",
        "group": "辅料"
      },
      {
        "name": "食用油",
        "amount": "10 毫升",
        "group": "调料"
      },
      {
        "name": "盐",
        "amount": "约 2 克",
        "group": "调料"
      },
      {
        "name": "小葱",
        "amount": "1 根",
        "group": "辅料"
      }
    ],
    "steps": [
      {
        "title": "备好配料",
        "description": "番茄切块，鸡蛋打散，小葱切碎。"
      },
      {
        "title": "炒蛋炒番茄",
        "description": "锅中热油，将鸡蛋炒至凝固盛出；下番茄翻炒至出汁。"
      },
      {
        "title": "煮熟面条",
        "description": "锅中加水煮开，下入面条，按包装时间煮至没有硬芯。水不足时适量补入热水。"
      },
      {
        "title": "加蛋调味",
        "description": "放回炒蛋，加盐，继续煮开并确认鸡蛋熟透，撒葱花盛出。"
      }
    ],
    "story": "把番茄炒蛋的搭配放进一碗面里，便有了简单的家常主食。不同面条吸水量不同，汤量可以边煮边调整。",
    "source": "",
    "sourceName": "家常做法示例",
    "photoCredit": {
      "name": "番茄鸡蛋面",
      "author": "Fumikas Sagisavas",
      "license": "CC0",
      "licenseUrl": "https://creativecommons.org/publicdomain/zero/1.0/deed.en",
      "sourcePage": "https://commons.wikimedia.org/wiki/File:Tomato_scrambled_eggs_noodles.jpg"
    }
  },
  {
    "id": "potato-shreds",
    "name": "醋溜土豆丝",
    "subtitle": "细细的土豆丝，炒出清爽的酸香。",
    "pairing": "土豆 × 青椒",
    "image": "potato-shreds.svg",
    "time": "约 20 分钟",
    "method": "快炒",
    "items": [
      {
        "name": "土豆",
        "amount": "2 个，约 350 克",
        "group": "主料"
      },
      {
        "name": "青椒",
        "amount": "半个",
        "group": "配菜"
      },
      {
        "name": "大蒜",
        "amount": "2 瓣",
        "group": "辅料"
      },
      {
        "name": "食用油",
        "amount": "15 毫升",
        "group": "调料"
      },
      {
        "name": "米醋",
        "amount": "10 毫升",
        "group": "调料"
      },
      {
        "name": "盐",
        "amount": "约 2 克",
        "group": "调料"
      }
    ],
    "steps": [
      {
        "title": "切丝冲洗",
        "description": "土豆洗净去皮切细丝，用清水冲去表面淀粉后沥干；青椒切丝，蒜切末。"
      },
      {
        "title": "炒香蒜末",
        "description": "锅中放油，中火炒香蒜末，放入土豆丝翻炒。"
      },
      {
        "title": "炒熟土豆丝",
        "description": "加入青椒丝，持续翻炒至土豆丝熟透、没有生硬芯；锅太干时沿边加少量水。"
      },
      {
        "title": "加醋调味",
        "description": "加入米醋和盐，迅速翻匀后出锅。"
      }
    ],
    "story": "土豆丝粗细尽量一致，炒制时更容易同时熟透。冲去表面淀粉后再沥水，是这道菜保持利落口感的小技巧。",
    "source": "",
    "sourceName": "家常做法示例"
  },
  {
    "id": "potato-pan",
    "name": "香煎土豆块",
    "subtitle": "外层微微金黄，里面柔软绵密。",
    "pairing": "土豆 × 黑胡椒",
    "image": "library/potato-pan.jpg",
    "time": "约 25 分钟",
    "method": "香煎",
    "items": [
      {
        "name": "土豆",
        "amount": "400 克",
        "group": "主料"
      },
      {
        "name": "食用油",
        "amount": "15 毫升",
        "group": "调料"
      },
      {
        "name": "盐",
        "amount": "约 2 克",
        "group": "调料"
      },
      {
        "name": "黑胡椒",
        "amount": "少许",
        "group": "调料"
      },
      {
        "name": "小葱",
        "amount": "1 根",
        "group": "辅料"
      }
    ],
    "steps": [
      {
        "title": "土豆切块",
        "description": "土豆洗净去皮，切成约 2 厘米的均匀小块。"
      },
      {
        "title": "先煮至熟",
        "description": "土豆放入水中煮至筷子可轻松穿透，捞出并充分沥水。"
      },
      {
        "title": "煎出金黄",
        "description": "平底锅放油，中小火铺入土豆，待一面定型再翻面，煎至几面微黄。"
      },
      {
        "title": "撒料装盘",
        "description": "加盐、黑胡椒和葱花，轻轻翻匀，趁热装盘。"
      }
    ],
    "story": "先煮后煎，可以更容易兼顾内部柔软和外层微焦。土豆入油锅前沥干水分，翻面也不必太频繁。",
    "source": "",
    "sourceName": "家常做法示例",
    "photoCredit": {
      "name": "香煎土豆块",
      "author": "Infrogmation of New Orleans",
      "license": "CC BY-SA 2.0",
      "licenseUrl": "https://creativecommons.org/licenses/by-sa/2.0",
      "sourcePage": "https://commons.wikimedia.org/wiki/File:Home_fries_in_pan_on_range,_New_Orleans_September_2024.jpg"
    }
  },
  {
    "id": "potato-rice",
    "name": "土豆胡萝卜焖饭",
    "subtitle": "把蔬菜切成小丁，交给电饭煲慢慢焖香。",
    "pairing": "土豆 × 胡萝卜 × 大米",
    "image": "potato-rice.svg",
    "time": "约 40 分钟",
    "method": "焖饭",
    "items": [
      {
        "name": "土豆",
        "amount": "200 克",
        "group": "主料"
      },
      {
        "name": "胡萝卜",
        "amount": "100 克",
        "group": "配菜"
      },
      {
        "name": "大米",
        "amount": "180 克",
        "group": "主料"
      },
      {
        "name": "生抽",
        "amount": "10 毫升",
        "group": "调料"
      },
      {
        "name": "食用油",
        "amount": "5 毫升",
        "group": "调料"
      },
      {
        "name": "水",
        "amount": "按电饭煲米量刻度",
        "group": "辅料"
      }
    ],
    "steps": [
      {
        "title": "淘米切丁",
        "description": "大米淘洗沥水；土豆去皮，和胡萝卜一起切成约 1 厘米的小丁。"
      },
      {
        "title": "加水调味",
        "description": "大米放入电饭煲，按对应米量刻度加水，加入生抽和食用油拌匀。"
      },
      {
        "title": "铺菜煮饭",
        "description": "把蔬菜丁均匀铺在大米上，按下正常煮饭程序。"
      },
      {
        "title": "焖好拌匀",
        "description": "程序结束后焖 5 分钟，检查土豆熟软、米饭无硬芯，翻松拌匀盛出。"
      }
    ],
    "story": "这份焖饭把备菜集中在切小丁这一步。各家电饭煲和大米吸水量不同，用自己平时煮饭的水量作为起点更方便。",
    "source": "",
    "sourceName": "家常做法示例"
  },
  {
    "id": "egg-scallion",
    "name": "葱花炒蛋",
    "subtitle": "一把葱花，给柔软鸡蛋添一点清香。",
    "pairing": "鸡蛋 × 小葱",
    "image": "library/egg-scallion.jpg",
    "time": "约 10 分钟",
    "method": "快炒",
    "items": [
      {
        "name": "鸡蛋",
        "amount": "4 个",
        "group": "主料"
      },
      {
        "name": "小葱",
        "amount": "2 根",
        "group": "辅料"
      },
      {
        "name": "食用油",
        "amount": "15 毫升",
        "group": "调料"
      },
      {
        "name": "盐",
        "amount": "约 1 克",
        "group": "调料"
      }
    ],
    "steps": [
      {
        "title": "切好葱花",
        "description": "小葱洗净切碎，葱白和葱绿分开放。"
      },
      {
        "title": "打散鸡蛋",
        "description": "鸡蛋逐个打入小碗检查，再倒入大碗，加盐与葱绿打匀。"
      },
      {
        "title": "下锅推炒",
        "description": "锅中放油，中火炒香葱白，倒入蛋液，待底部凝固后用锅铲轻轻推开。"
      },
      {
        "title": "熟透出锅",
        "description": "继续推炒至蛋液完全凝固、没有流动的生蛋液，立即盛出。"
      }
    ],
    "story": "少量食材也能成为一盘下饭菜。火力适中、及时盛出，可以让鸡蛋熟透的同时保留柔软口感。",
    "source": "",
    "sourceName": "家常做法示例",
    "photoCredit": {
      "name": "葱花炒蛋",
      "author": "Daderot",
      "license": "CC0",
      "licenseUrl": "https://creativecommons.org/publicdomain/zero/1.0/deed.en",
      "sourcePage": "https://commons.wikimedia.org/wiki/File:Egg_and_scallion_-_Arlington,_MA.jpg"
    }
  },
  {
    "id": "egg-steamed",
    "name": "香菇蒸蛋",
    "subtitle": "细腻蒸蛋上，留一点温柔的菇香。",
    "pairing": "鸡蛋 × 鲜香菇",
    "image": "egg-steamed.svg",
    "time": "约 25 分钟",
    "method": "清蒸",
    "items": [
      {
        "name": "鸡蛋",
        "amount": "3 个",
        "group": "主料"
      },
      {
        "name": "鲜香菇",
        "amount": "2 朵",
        "group": "配菜"
      },
      {
        "name": "水",
        "amount": "蛋液体积的约 1.5 倍",
        "group": "辅料"
      },
      {
        "name": "盐",
        "amount": "约 1 克",
        "group": "调料"
      },
      {
        "name": "生抽",
        "amount": "5 毫升",
        "group": "调料"
      },
      {
        "name": "香油",
        "amount": "2 毫升",
        "group": "调料"
      }
    ],
    "steps": [
      {
        "title": "备好香菇",
        "description": "鲜香菇洗净去硬蒂，切成小丁，放沸水中煮熟后沥出。"
      },
      {
        "title": "调匀蛋液",
        "description": "鸡蛋打散，加盐与约 1.5 倍体积的温水搅匀，撇去表面泡沫。"
      },
      {
        "title": "小火蒸熟",
        "description": "蛋液倒入耐热浅碗，放入香菇丁，用盘子盖住碗。水开上锅，小火蒸约 12–15 分钟。"
      },
      {
        "title": "检查调味",
        "description": "确认中心凝固、没有流动蛋液；未熟则继续蒸。取出后淋生抽和香油。"
      }
    ],
    "story": "蒸蛋的细腻来自温和的火力和合适的水量。浅碗更容易受热均匀，碗大小不同，蒸制时间也要相应调整。",
    "source": "",
    "sourceName": "家常做法示例"
  },
  {
    "id": "egg-seaweed",
    "name": "紫菜蛋花汤",
    "subtitle": "轻轻一圈蛋花，煮成清爽的家常汤。",
    "pairing": "鸡蛋 × 紫菜",
    "image": "egg-seaweed.svg",
    "time": "约 10 分钟",
    "method": "煮汤",
    "items": [
      {
        "name": "鸡蛋",
        "amount": "2 个",
        "group": "主料"
      },
      {
        "name": "紫菜",
        "amount": "5 克",
        "group": "配菜"
      },
      {
        "name": "水",
        "amount": "800 毫升",
        "group": "辅料"
      },
      {
        "name": "盐",
        "amount": "约 2 克",
        "group": "调料"
      },
      {
        "name": "香油",
        "amount": "2 毫升",
        "group": "调料"
      },
      {
        "name": "小葱",
        "amount": "1 根",
        "group": "辅料"
      }
    ],
    "steps": [
      {
        "title": "准备材料",
        "description": "鸡蛋打散，小葱切碎，紫菜按包装说明处理并去掉杂质。"
      },
      {
        "title": "煮开汤底",
        "description": "锅中加水煮开，放入紫菜，煮至充分舒展。"
      },
      {
        "title": "淋入蛋液",
        "description": "保持汤微沸，将蛋液细细地绕圈淋入，稍待凝固后轻推，继续煮至蛋花熟透。"
      },
      {
        "title": "调味出锅",
        "description": "加入盐和香油，撒上葱花，拌匀盛出。"
      }
    ],
    "story": "蛋液淋得细一些、凝固前少搅动，蛋花就容易形成柔软的薄片。紫菜与鸡蛋的组合，很适合搭配一餐热饭。",
    "source": "",
    "sourceName": "家常做法示例"
  }
];

export const FOODS: FoodExample[] = [
  {
    "id": "bok-choy",
    "name": "上海青",
    "aliases": [
      "青梗菜"
    ],
    "subtitle": "青梗菜 · 绿叶蔬菜",
    "summary": "菜梗清脆，叶片柔嫩。清炒、煮汤都合适。",
    "image": "library/garlic.jpg",
    "recipeIds": [
      "garlic",
      "mushroom",
      "tofu"
    ],
    "storage": "保持干爽，包好后冷藏，洗净后及时烹饪。",
    "pairing": "与主食、豆制品或肉蛋一起搭配，让餐桌更丰富。",
    "description": "菜梗清脆，叶片柔嫩，梗与叶都可以食用。",
    "preparation": "掰开叶片冲洗，尤其洗净叶柄根部；沥水后将较大的菜梗与叶片分开。"
  },
  {
    "id": "tomato",
    "name": "番茄",
    "aliases": [
      "西红柿"
    ],
    "subtitle": "西红柿 · 茄果类",
    "summary": "酸甜多汁。炒鸡蛋、煮汤或做汤面都合适。",
    "image": "library/tomato-egg.jpg",
    "recipeIds": [
      "tomato-egg",
      "tomato-tofu",
      "tomato-noodles"
    ],
    "storage": "完整番茄放阴凉通风处，切开后密封冷藏并及时使用。",
    "pairing": "搭配鸡蛋、豆腐或面条，做成一道菜，也能变成一餐。",
    "description": "汁水丰富，酸甜柔和，加热后容易形成汤汁。",
    "preparation": "洗净去蒂，切成大小均匀的块；是否去皮按口感喜好决定。"
  },
  {
    "id": "potato",
    "name": "土豆",
    "aliases": [
      "马铃薯",
      "洋芋"
    ],
    "subtitle": "马铃薯 · 薯类",
    "summary": "切丝清脆，切块绵软。炒、煎、焖各有滋味。",
    "image": "potato-shreds.svg",
    "recipeIds": [
      "potato-shreds",
      "potato-pan",
      "potato-rice"
    ],
    "storage": "放阴凉、避光、通风处；明显发绿、发芽或腐烂时不要食用。",
    "pairing": "搭配青椒炒丝，配胡萝卜焖饭，或简单煎成金黄小块。",
    "description": "切丝可以炒出脆口感，切块焖煮则更绵软。",
    "preparation": "洗净去皮后切块或切丝。明显发绿、发芽或腐烂的土豆不要用于这些菜谱。"
  },
  {
    "id": "egg",
    "name": "鸡蛋",
    "aliases": [
      "鸡子"
    ],
    "subtitle": "常见蛋类 · 家常食材",
    "summary": "炒得香、蒸得嫩，也能变成一碗轻盈蛋花汤。",
    "image": "library/egg-scallion.jpg",
    "recipeIds": [
      "egg-scallion",
      "egg-steamed",
      "egg-seaweed"
    ],
    "storage": "按包装储存要求保存，避免忽冷忽热；破损或有异味时不要使用。",
    "pairing": "小葱、香菇与紫菜，分别带来三种简单的家常灵感。",
    "description": "打散可炒、蒸或淋入汤中，适合多种家常做法。",
    "preparation": "打入单独的小碗检查后再使用；这些示例均需将蛋液充分做熟。"
  }
];

export function recipeById(id: string): Recipe {
  return RECIPES.find((recipe: Recipe) => recipe.id === id) || RECIPES[0];
}
